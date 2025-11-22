import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meeting.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../widgets/custom_buttons.dart';

/// Chat room screen for communicating about meetup
class ChatRoomScreen extends StatefulWidget {
  final ChatRoom? chatRoom;
  final Invitation? invitation;

  const ChatRoomScreen({super.key, this.chatRoom, this.invitation});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-refresh when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Refresh messages for current chat room
  Future<void> _refreshMessages() async {
    if (widget.chatRoom == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final storage = context.read<StorageService>();
      await storage.refreshChatRoomMessages(widget.chatRoom!.id);
    } catch (e) {
      // NEW: Handle 404 gracefully
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat room not available yet. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        print('Error refreshing messages: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh messages: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final storage = context.read<StorageService>();
    ChatRoom? currentChatRoom;
    
    if (widget.chatRoom != null) {
      currentChatRoom = storage.chatRooms.firstWhere(
        (c) => c.id == widget.chatRoom!.id,
        orElse: () => widget.chatRoom!,
      );
    } else if (widget.invitation != null) {
      // Find chat room by user pair
      final currentUserId = storage.currentProfile?.id ?? '';
      currentChatRoom = storage.chatRooms
          .where((cr) => cr.containsUser(currentUserId) && 
                        cr.containsUser(widget.invitation!.peerId))
          .firstOrNull;
    }
    
    if (currentChatRoom != null) {
      storage.sendMessage(
        currentChatRoom.id,
        _messageController.text.trim(),
      ).catchError((e) {
        // NEW: Handle send errors gracefully
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      // NEW: Handle case where chat room doesn't exist
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat room not available. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    _messageController.clear();

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    ChatRoom? chatRoom;
    
    if (widget.chatRoom != null) {
      chatRoom = storage.chatRooms.firstWhere(
        (c) => c.id == widget.chatRoom!.id,
        orElse: () => widget.chatRoom!,
      );
    } else if (widget.invitation != null) {
      // Try to find existing chat room for this invitation by user pair
      final currentUserId = storage.currentProfile?.id ?? '';
      chatRoom = storage.chatRooms
          .where((cr) => cr.containsUser(currentUserId) && 
                        cr.containsUser(widget.invitation!.peerId))
          .firstOrNull;
    }

    // Auto-scroll to bottom when new messages arrive
    if (chatRoom != null && chatRoom!.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    // Get peer name using the new user pair structure
    final currentUserId = storage.currentProfile?.id ?? '';
    String otherUserId = '';
    String initialPeerName = widget.invitation?.peerName ?? 'Unknown';
    
    if (chatRoom != null) {
      otherUserId = chatRoom.getOtherUserId(currentUserId);
    } else if (widget.invitation != null) {
      otherUserId = widget.invitation!.peerId;
    }
    
    final restaurant = chatRoom?.restaurant ?? widget.invitation?.restaurant ?? '';

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Profile?>(
          future: otherUserId.isNotEmpty ? storage.getProfileById(otherUserId) : Future.value(null),
          builder: (context, snapshot) {
            String peerName = initialPeerName;
            
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              peerName = snapshot.data!.userName;
            } else if (otherUserId.isNotEmpty) {
              // Fallback to nearby peers if profile not found
              final peer = storage.getPeerById(otherUserId);
              if (peer != null) {
                peerName = peer.name;
              }
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(peerName),
                if (restaurant.isNotEmpty)
                  Text(
                    restaurant,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMessages,
            tooltip: 'Refresh messages',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FutureBuilder<Profile?>(
                  future: otherUserId.isNotEmpty ? storage.getProfileById(otherUserId) : Future.value(null),
                  builder: (context, snapshot) {
                    String dialogPeerName = initialPeerName;
                    
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      dialogPeerName = snapshot.data!.userName;
                    } else if (otherUserId.isNotEmpty) {
                      final peer = storage.getPeerById(otherUserId);
                      if (peer != null) {
                        dialogPeerName = peer.name;
                      }
                    }
                    
                    return AlertDialog(
                      title: const Text('Meetup Details'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person),
                              const SizedBox(width: 8),
                              Text(dialogPeerName),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.restaurant),
                              const SizedBox(width: 8),
                              Text(restaurant),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Invitation card (if pending invitation)
          if (widget.invitation != null && widget.invitation!.isPending)
            _buildInvitationCard(context, widget.invitation!, storage),
          // Info banner (for accepted invitations)
          if (chatRoom != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ready to meet up at $restaurant',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // Messages
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: (chatRoom?.messages.isEmpty ?? true) && widget.invitation == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start chatting about your meetup!',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: (chatRoom?.messages.length ?? 0),
                      itemBuilder: (context, index) {
                        return _buildMessage(chatRoom!.messages[index]);
                      },
                    ),
            ),
          ),
          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                PrimaryIconButton(
                  icon: Icons.send,
                  onPressed: _sendMessage,
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(BuildContext context, Invitation invitation, StorageService storage) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and name
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: invitation.sentByMe ? Colors.blue : Colors.orange,
                child: Text(
                  _getInitials(invitation.peerName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.peerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      invitation.sentByMe ? 'Invitation Sent' : 'Wants to connect',
                      style: TextStyle(
                        fontSize: 12,
                        color: invitation.sentByMe ? Colors.blue : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (invitation.sentByMe ? Colors.blue : Colors.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    color: invitation.sentByMe ? Colors.blue : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          // Restaurant info
          if (invitation.restaurant.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  invitation.restaurant,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
          
          // Action buttons for received invitations
          if (!invitation.sentByMe && invitation.isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await storage.declineInvitation(invitation.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invitation declined')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to decline: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await storage.acceptInvitation(invitation.id);
                        if (context.mounted) {
                          // Refresh the screen to show chat room
                          Navigator.pop(context);
                          // Find the new chat room and navigate back
                          final currentUserId = storage.currentProfile?.id ?? '';
                          final newChatRoom = storage.chatRooms
                              .where((cr) => cr.containsUser(currentUserId) && 
                                            cr.containsUser(invitation.peerId))
                              .firstOrNull;
                          if (newChatRoom != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomScreen(chatRoom: newChatRoom),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to accept: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
          
          // Options for sent invitations
          if (invitation.sentByMe && invitation.isPending) ...[
            const SizedBox(height: 16),
            Text(
              'Waiting for response...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _buildMessage(ChatMessage message) {
    // Special styling for system messages (invitation cards)
    if (message.isSystemMessage) {
      // Different styling for invitation vs acceptance messages
      final isInvitationMessage = message.text.contains('Invitation sent') || 
                                  message.text.contains('wants to connect');
      final isAcceptanceMessage = message.text.contains('Invitation accepted');
      
      Color bgColor = Colors.green.withValues(alpha: 0.1);
      Color borderColor = Colors.green.withValues(alpha: 0.3);
      Color textColor = Colors.green[700]!;
      IconData icon = Icons.celebration;
      
      if (isInvitationMessage) {
        bgColor = Colors.blue.withValues(alpha: 0.1);
        borderColor = Colors.blue.withValues(alpha: 0.3);
        textColor = Colors.blue[700]!;
        icon = Icons.mail_outline;
      } else if (isAcceptanceMessage) {
        bgColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green.withValues(alpha: 0.3);
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
      }
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regular message styling
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: message.isMine
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isMine ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: message.isMine
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
