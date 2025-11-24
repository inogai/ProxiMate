import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../models/meeting.dart';
import '../models/profile.dart';
import '../screens/chat_room_screen.dart';
import 'dart:async';
import 'package:dio/dio.dart';

/// Tab showing chat rooms as a contacts list with chat-style interface
class InvitationsTab extends StatefulWidget {
  const InvitationsTab({super.key});

  @override
  State<InvitationsTab> createState() => _InvitationsTabState();
}

class _InvitationsTabState extends State<InvitationsTab>
    with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;
  bool _isOffline = false;
  // _autoRefreshTimer removed: invitations will rely on StorageService's
  // centralized polling instead of starting an independent timer here.
  int _currentRetryInterval = 5; // kept for offline/backoff UI only

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start chatroom polling when the invitations tab is created (visible)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final storage = context.read<StorageService>();
        storage.startChatRoomPolling();
      } catch (e) {
        debugPrint('Failed to start chatroom polling for InvitationsTab: $e');
      }
    });
  }

  @override
  void dispose() {
    // Ensure we stop chatroom polling when the tab is disposed
    try {
      final storage = context.read<StorageService>();
      storage.stopChatRoomPolling();
    } catch (e) {
      debugPrint('Failed to stop chatroom polling for InvitationsTab: $e');
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Invitations_tab no longer manages periodic timers — we keep lifecycle
    // hook here for future use but do not start/stop any timers.
  }

  // The invitations tab no longer starts its own periodic timer.
  // Polling for invitations/chatrooms/messages is centralized in
  // StorageService/PollService (message polling); invitation polling
  // as a separate timer has been removed.
  // We keep the retry/backoff logic for offline state UI only.

  void _increaseRetryInterval() {
    if (_currentRetryInterval < 30) {
      _currentRetryInterval = (_currentRetryInterval * 2).clamp(5, 30);
    }
    // No timer to restart - the UI uses this value for offline banner only
  }

  void _resetRetryIntervals() {
    _currentRetryInterval = 5;
    // No timer to restart
  }

  // _restartAutoRefresh removed - no local timer to restart

  bool _isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.unknown;
    }
    return error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused') ||
        error.toString().contains('Network is unreachable');
  }

  void _showOfflineBanner() {
    if (!_isOffline) {
      setState(() {
        _isOffline = true;
      });
    }
  }

  void _hideOfflineBanner() {
    if (_isOffline) {
      setState(() {
        _isOffline = false;
      });
    }
  }

  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline - Retrying every ${_currentRetryInterval}s...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    // Get chat rooms
    final chatRooms = storage.chatRooms;
    final currentUserId = storage.currentProfile?.id ?? '';

    // Sort by most recent first
    final sortedChatRooms = List<ChatRoom>.from(chatRooms)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Offline banner (if needed)
          if (_isOffline) _buildOfflineBanner(),
          // Main content
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: const Text('Chats'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  floating: false,
                  pinned: true,
                  actions: [
                    if (_isRefreshing)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => _refreshChats(isAutoRefresh: false),
                        tooltip: 'Refresh chats',
                      ),
                  ],
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(height: 1, thickness: 1),
                  ),
                ),
                SliverFillRemaining(
                  child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () => _refreshChats(isAutoRefresh: false),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Refresh chats from server
  Future<void> _refreshChats({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      final storage = context.read<StorageService>();
      // await storage.refreshChatRooms();

      // If we were offline and now succeeded, hide offline banner
      if (_isOffline) {
        _hideOfflineBanner();
        _resetRetryIntervals();
      }
    } catch (e) {
      debugPrint('Error refreshing chats: $e');

      // Check if this is a network error
      if (_isNetworkError(e)) {
        _showOfflineBanner();
        _increaseRetryInterval();
      }
    } finally {
      if (!isAutoRefresh) {
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

    // Use FutureBuilder to handle async profile fetching
    return FutureBuilder<Profile?>(
      future: storage.getProfileById(otherUserId),
      builder: (context, snapshot) {
        String peerName = 'Unknown User';

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          peerName = snapshot.data!.userName;
        } else {
          // Fallback to nearby peers if profile not found
          final peer = storage.getPeerById(otherUserId);
          if (peer != null) {
            peerName = peer.name;
          }
        }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green,
                      child: Text(
                        _getInitials(peerName),
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
                                  peerName,
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
      },
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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
