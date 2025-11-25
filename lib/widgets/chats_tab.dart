import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/chat_service.dart';
import '../models/meeting.dart';
import '../screens/chat_room_screen.dart';
import '../widgets/profile_avatar.dart';

/// Tab showing chat rooms as a contacts list with chat-style interface
class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;
  bool _hasInitialized = false;

  /// Expose refresh method for external calls
  void refreshChats() {
    if (!_isRefreshing) {
      _refreshChats();
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-refresh when the tab is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a small delay to ensure providers are fully initialized
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_hasInitialized) {
          _hasInitialized = true;
          _refreshChats();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final chatService = context.watch<ChatService>();

    // Get chat rooms
    final chatRooms = chatService.chatRooms;
    final currentUserId = storage.currentProfile?.id ?? '';

    // Sort by most recent first
    final sortedChatRooms = List<ChatRoom>.from(chatRooms)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
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
              onPressed: _refreshChats,
              tooltip: 'Refresh chats',
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
        onRefresh: _refreshChats,
        child: sortedChatRooms.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: sortedChatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = sortedChatRooms[index];
                  return _buildChatRoomContact(
                    context,
                    chatRoom,
                    storage,
                    currentUserId,
                  );
                },
              ),
      ),
    );
  }

  /// Refresh chats from server
  Future<void> _refreshChats() async {
    if (!mounted) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final chatService = context.read<ChatService>();
      await chatService.refreshChatRooms();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh chats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
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
              'No Chats Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accept invitations to start chatting here',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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

  Widget _buildChatRoomContact(
    BuildContext context,
    ChatRoom chatRoom,
    StorageService storage,
    String currentUserId,
  ) {
    // Get the other user's information
    final otherUserId = chatRoom.getOtherUserId(currentUserId);

    // Get profile synchronously
    final profile = storage.getCacheProfileById(otherUserId);

    // Get last message for preview
    String lastMessage = 'Start chatting!';
    DateTime lastMessageTime = chatRoom.createdAt;
    if (chatRoom.messages.isNotEmpty) {
      final lastMsg = chatRoom.messages.last;
      if (!lastMsg.isSystemMessage) {
        lastMessage = lastMsg.text;
        lastMessageTime = lastMsg.timestamp;
      }
    }

    return Column(
      children: [
        InkWell(
          onTap: () => _handleChatRoomTap(context, chatRoom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAvatar(
                  name: profile?.userName ?? 'Unknown',
                  imagePath: profile?.profileImagePath,
                  size: 56,
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
                              profile?.userName ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Last message preview
                      Text(
                        lastMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Restaurant info (if available)
                      if (chatRoom.restaurant.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '📍 ${chatRoom.restaurant}',
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

  Future<void> _handleChatRoomTap(
    BuildContext context,
    ChatRoom chatRoom,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(chatRoom: chatRoom),
      ),
    );
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
