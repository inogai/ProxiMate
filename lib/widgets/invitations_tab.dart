import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/meeting.dart';
import '../screens/chat_room_screen.dart';

/// Tab showing invitations as a contacts list with chat-style interface
class InvitationsTab extends StatefulWidget {
  const InvitationsTab({super.key});

  @override
  State<InvitationsTab> createState() => _InvitationsTabState();
}

class _InvitationsTabState extends State<InvitationsTab> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    
    // Get all relevant invitations
    final receivedInvitations = storage.receivedInvitations;
    final sentInvitations = storage.sentInvitations;
    final acceptedInvitations = storage.acceptedInvitations;
    
    // Combine all invitations for the contacts list
    final allInvitations = [...receivedInvitations, ...sentInvitations, ...acceptedInvitations];
    
    // Sort by most recent first
    allInvitations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshInvitations,
              tooltip: 'Refresh invitations',
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshInvitations,
        child: allInvitations.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: allInvitations.length,
                itemBuilder: (context, index) {
                  final invitation = allInvitations[index];
                  return _buildInvitationContact(context, invitation, storage);
                },
              ),
      ),
    );
  }

  /// Refresh invitations from server
  Future<void> _refreshInvitations() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final storage = context.read<StorageService>();
      await storage.refreshInvitations();
    } catch (e) {
      print('Error refreshing invitations: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Invitations Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start connecting with peers to see invitations here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pull down to refresh',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationContact(
    BuildContext context,
    Invitation invitation,
    StorageService storage,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _handleInvitationTap(context, invitation, storage),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _getAvatarColor(invitation),
                  child: Text(
                    _getInitials(invitation.peerName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              invitation.peerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(invitation.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Status message
                      Text(
                        _getStatusMessage(invitation),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(invitation),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      // Restaurant info (if available)
                      if (invitation.restaurant.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '📍 ${invitation.restaurant}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, indent: 72, thickness: 0.5),
      ],
    );
  }

  Future<void> _handleInvitationTap(
    BuildContext context,
    Invitation invitation,
    StorageService storage,
  ) async {
    if (invitation.isAccepted) {
      // Open chat room for accepted invitations
      final currentUserId = storage.currentProfile?.id ?? '';
      
      // Refresh chat rooms before opening
      await storage.refreshChatRooms();
      
      final chatRoom = storage.chatRooms
          .where((cr) => cr.containsUser(currentUserId) && 
                        cr.containsUser(invitation.peerId))
          .firstOrNull;
      
      if (chatRoom != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
          ),
        );
      }
    } else if (invitation.isPending) {
      // Open chat view with invitation card for all pending invitations
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(invitation: invitation),
        ),
      );
    }
  }

  

  

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _getAvatarColor(Invitation invitation) {
    if (invitation.isAccepted) {
      return Colors.green;
    } else if (invitation.isPending) {
      return invitation.sentByMe ? Colors.blue : Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String _getStatusMessage(Invitation invitation) {
    if (invitation.isAccepted) {
      return invitation.chatOpened ? 'Chat available' : 'Invitation accepted 💬';
    } else if (invitation.isPending) {
      return invitation.sentByMe 
          ? 'Invitation sent ⏳' 
          : 'Wants to connect 🤝';
    } else {
      return 'Invitation declined';
    }
  }

  Color _getStatusColor(Invitation invitation) {
    if (invitation.isAccepted) {
      return Colors.green;
    } else if (invitation.isPending) {
      return invitation.sentByMe ? Colors.blue : Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}