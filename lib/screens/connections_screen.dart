import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/connection.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import 'chat_room_screen.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Connections'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<StorageService>(
        builder: (context, storage, child) {
          final connections = storage.connections;
          
          if (connections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No connections yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accept invitations and collect name cards\nto build your network',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final connection = connections[index];
              return _buildConnectionCard(context, connection, storage);
            },
          );
        },
      ),
    );
  }

  Widget _buildConnectionCard(BuildContext context, Connection connection, StorageService storage) {
    final otherProfileId = connection.toProfileId;
    
    return FutureBuilder<Profile?>(
      future: storage.getProfileById(otherProfileId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Profile avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      backgroundImage: profile?.profileImagePath != null
                          ? NetworkImage(profile!.profileImagePath!)
                          : null,
                      child: profile?.profileImagePath == null
                          ? Text(
                              _getInitials(profile?.userName ?? 'Unknown'),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Profile info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.userName ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (profile?.school != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              profile!.school!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          if (profile?.major != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              profile!.major!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Connection status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[700],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Connected',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Connection details
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            'Met at: ${connection.restaurant}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            'Connected: ${_formatDate(connection.collectedAt)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Interests section
                if (profile?.interests != null && profile!.interests!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Interests:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: profile.interests!.split(',').map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          interest.trim(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                // Action buttons
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openChat(context, connection, storage),
                        icon: const Icon(Icons.chat),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewProfile(context, profile),
                        icon: const Icon(Icons.person),
                        label: const Text('View Profile'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openChat(BuildContext context, Connection connection, StorageService storage) {
    final currentUserId = storage.currentProfile?.id ?? '';
    final otherUserId = connection.toProfileId;
    
    // Find existing chat room
    final chatRoom = storage.getChatRoomBetweenUsers(currentUserId, otherUserId);
    
    if (chatRoom != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat room not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewProfile(BuildContext context, Profile? profile) {
    if (profile == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(profile.userName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profile.profileImagePath != null) ...[
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profile.profileImagePath!),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (profile.school != null) ...[
                _buildProfileDetail('School', profile.school!),
                const SizedBox(height: 8),
              ],
              if (profile.major != null) ...[
                _buildProfileDetail('Major', profile.major!),
                const SizedBox(height: 8),
              ],
              if (profile.interests != null) ...[
                _buildProfileDetail('Interests', profile.interests!),
                const SizedBox(height: 8),
              ],
              if (profile.background != null) ...[
                _buildProfileDetail('About', profile.background!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}