import 'package:anyhow/rust.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meeting.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/invitation_message_card.dart';

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
  bool _isChatRoomClosed = false;

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
          .where(
            (cr) =>
                cr.containsUser(currentUserId) &&
                cr.containsUser(widget.invitation!.peerId),
          )
          .firstOrNull;
    }

    if (currentChatRoom != null) {
      storage
          .sendMessage(currentChatRoom.id, _messageController.text.trim())
          .catchError((e) {
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
          .where(
            (cr) =>
                cr.containsUser(currentUserId) &&
                cr.containsUser(widget.invitation!.peerId),
          )
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

    final restaurant =
        chatRoom?.restaurant ?? widget.invitation?.restaurant ?? '';

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Profile?>(
          future: otherUserId.isNotEmpty
              ? storage.getProfileById(otherUserId)
              : Future.value(null),
          builder: (context, snapshot) {
            String peerName = initialPeerName;

            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
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
                  future: otherUserId.isNotEmpty
                      ? storage.getProfileById(otherUserId)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    String dialogPeerName = initialPeerName;

                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                _isChatRoomClosed
                                    ? Icons.lock
                                    : Icons.lock_open,
                                color: _isChatRoomClosed
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isChatRoomClosed
                                    ? 'Chat room closed'
                                    : 'Chat room open',
                                style: TextStyle(
                                  color: _isChatRoomClosed
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
          // Chat room closed banner
          if (_isChatRoomClosed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Colors.red[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Chat room closed - Read only mode',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          // Invitation card (if pending invitation)
          if (widget.invitation != null && widget.invitation!.isPending)
            _buildInvitationCard(context, widget.invitation!, storage),
          // Info banner (for accepted invitations)
          if (chatRoom != null && !_isChatRoomClosed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
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
              child:
                  (chatRoom?.messages.isEmpty ?? true) &&
                      widget.invitation == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isChatRoomClosed
                                ? Icons.lock
                                : Icons.chat_bubble_outline,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isChatRoomClosed
                                ? 'This chat room has been closed'
                                : 'Start chatting about your meetup!',
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
          // Input field (disabled if chat room is closed)
          if (!_isChatRoomClosed)
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
              child: Column(
                children: [
                  // Action buttons area - show different buttons based on state
                  _buildActionButtons(),
                  Row(
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
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(
    BuildContext context,
    Invitation invitation,
    StorageService storage,
  ) {
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
                backgroundColor: invitation.sentByMe
                    ? Colors.blue
                    : Colors.orange,
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
                      invitation.sentByMe
                          ? 'Invitation Sent'
                          : 'Wants to connect',
                      style: TextStyle(
                        fontSize: 12,
                        color: invitation.sentByMe
                            ? Colors.blue
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (invitation.sentByMe ? Colors.blue : Colors.orange)
                      .withValues(alpha: 0.1),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                            const SnackBar(
                              content: Text('Invitation declined'),
                            ),
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
                          final currentUserId =
                              storage.currentProfile?.id ?? '';
                          final newChatRoom = storage.chatRooms
                              .where(
                                (cr) =>
                                    cr.containsUser(currentUserId) &&
                                    cr.containsUser(invitation.peerId),
                              )
                              .firstOrNull;
                          if (newChatRoom != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatRoomScreen(chatRoom: newChatRoom),
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

  /// Handle connection response (accept/decline)
  Future<void> _handleConnectionResponse(String messageId, bool accept) async {
    try {
      final storage = context.read<StorageService>();

      if (accept) {
        await storage.respondToConnectionRequest(messageId, 'accept');

        // Immediately update local message status after successful API call
        _updateLocalConnectionResponseStatus(messageId, 'accepted');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Name card request accepted!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await storage.respondToConnectionRequest(messageId, 'decline');

        // Immediately update local message status after successful API call
        _updateLocalConnectionResponseStatus(messageId, 'declined');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Name card request declined'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to respond to request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Update local connection request status immediately after successful API call
  void _updateLocalConnectionResponseStatus(
    String messageId,
    String newStatus,
  ) {
    final storage = context.read<StorageService>();

    // Find the chat room containing this message
    ChatRoom? targetChatRoom;
    int chatRoomIndex = -1;

    for (int i = 0; i < storage.chatRooms.length; i++) {
      final chatRoom = storage.chatRooms[i];
      if (chatRoom.messages.any((msg) => msg.id == messageId)) {
        targetChatRoom = chatRoom;
        chatRoomIndex = i;
        break;
      }
    }

    if (targetChatRoom != null && chatRoomIndex != -1) {
      final messageIndex = targetChatRoom.messages.indexWhere(
        (msg) => msg.id == messageId,
      );

      if (messageIndex != -1) {
        // Create updated message with new status
        final originalMessage = targetChatRoom.messages[messageIndex];
        final updatedMessage = originalMessage.copyWith(
          invitationData: {
            ...originalMessage.invitationData ?? {},
            'status': newStatus,
          },
        );

        // Update messages list
        final updatedMessages = [...targetChatRoom.messages];
        updatedMessages[messageIndex] = updatedMessage;

        // Update chat room in storage
        storage.chatRooms[chatRoomIndex] = targetChatRoom.copyWith(
          messages: updatedMessages,
        );

        // Trigger UI update by refreshing messages
        _refreshMessages();
      }
    }
  }

  /// Handle invitation response (accept/decline)
  Future<void> _handleInvitationResponse(String messageId, bool accept) async {
    try {
      final storage = context.read<StorageService>();

      if (accept) {
        await storage.respondToInvitationByMessageId(messageId, 'accept');

        // Immediately update local message status after successful API call
        _updateLocalMessageStatus(messageId, 'accepted');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitation accepted!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await storage.respondToInvitationByMessageId(messageId, 'decline');

        // Immediately update local message status after successful API call
        _updateLocalMessageStatus(messageId, 'declined');

        // Close chat room when invitation is declined
        setState(() {
          _isChatRoomClosed = true;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invitation declined. Chat room closed.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Also refresh messages from server to ensure consistency
      await _refreshMessages();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to respond to invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Update local message status immediately after successful API call
  void _updateLocalMessageStatus(String messageId, String newStatus) {
    final storage = context.read<StorageService>();

    // Find the chat room containing this message
    ChatRoom? targetChatRoom;
    int chatRoomIndex = -1;

    for (int i = 0; i < storage.chatRooms.length; i++) {
      final chatRoom = storage.chatRooms[i];
      if (chatRoom.messages.any((msg) => msg.id == messageId)) {
        targetChatRoom = chatRoom;
        chatRoomIndex = i;
        break;
      }
    }

    if (targetChatRoom != null && chatRoomIndex != -1) {
      final messageIndex = targetChatRoom.messages.indexWhere(
        (msg) => msg.id == messageId,
      );

      if (messageIndex != -1) {
        // Create updated message with new status
        final originalMessage = targetChatRoom.messages[messageIndex];
        final updatedMessage = originalMessage.copyWith(
          invitationData: {
            ...originalMessage.invitationData ?? {},
            'status': newStatus,
          },
        );

        // Update messages list
        final updatedMessages = [...targetChatRoom.messages];
        updatedMessages[messageIndex] = updatedMessage;

        // Update chat room in storage
        storage.chatRooms[chatRoomIndex] = targetChatRoom.copyWith(
          messages: updatedMessages,
        );

        // Trigger UI update by refreshing messages
        _refreshMessages();
      }
    }
  }

  /// Handle name card collection
  Future<void> _handleCollectNameCard(String messageId) async {
    final storage = context.read<StorageService>();
    final currentUserId = storage.currentProfile?.id ?? '';
    final otherUserId = widget.chatRoom?.getOtherUserId(currentUserId) ?? '';

    print('!! Collecting name card for user: $otherUserId');

    final result = await storage.collectNameCard(otherUserId);

    switch (result) {
      case Err(v: final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $error'),
            backgroundColor: Colors.red,
          ),
        );
      case Ok():
        // Immediately update local message status after successful API call
        _updateLocalMessageNameCardCollected(messageId);
        await _refreshMessages();
    }
  }

  /// Update local message name card collection status immediately after successful API call
  void _updateLocalMessageNameCardCollected(String messageId) {
    final storage = context.read<StorageService>();

    // Find the chat room containing this message
    ChatRoom? targetChatRoom;
    int chatRoomIndex = -1;

    for (int i = 0; i < storage.chatRooms.length; i++) {
      final chatRoom = storage.chatRooms[i];
      if (chatRoom.messages.any((msg) => msg.id == messageId)) {
        targetChatRoom = chatRoom;
        chatRoomIndex = i;
        break;
      }
    }

    if (targetChatRoom != null && chatRoomIndex != -1) {
      final messageIndex = targetChatRoom.messages.indexWhere(
        (msg) => msg.id == messageId,
      );

      if (messageIndex != -1) {
        // Create updated message with name card collected flag
        final originalMessage = targetChatRoom.messages[messageIndex];
        final updatedMessage = originalMessage.copyWith(
          invitationData: {
            ...originalMessage.invitationData ?? {},
            'name_card_collected': true,
          },
        );

        // Update messages list
        final updatedMessages = [...targetChatRoom.messages];
        updatedMessages[messageIndex] = updatedMessage;

        // Update chat room in storage
        storage.chatRooms[chatRoomIndex] = targetChatRoom.copyWith(
          messages: updatedMessages,
        );

        // Trigger UI update by refreshing messages
        _refreshMessages();
      }
    }
  }

  /// Handle not good match (close connection)
  Future<void> _handleNotGoodMatch(String messageId) async {
    try {
      final storage = context.read<StorageService>();
      final currentUserId = storage.currentProfile?.id ?? '';
      final otherUserId = widget.chatRoom?.getOtherUserId(currentUserId) ?? '';

      // Call with peer ID instead of message ID
      await storage.markNotGoodMatch(otherUserId);

      // Close chat room
      setState(() {
        _isChatRoomClosed = true;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection closed. Chat room is now read-only.'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Refresh messages to update UI
      await _refreshMessages();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to close connection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Check if there's already a pending invitation in this chat
  bool _hasPendingInvitation() {
    final storage = context.read<StorageService>();
    final currentUserId = storage.currentProfile?.id ?? '';
    final otherUserId = widget.chatRoom?.getOtherUserId(currentUserId) ?? '';

    // Check if there are any pending invitations between these users
    return storage.invitations.any(
      (inv) =>
          inv.isPending &&
          ((inv.peerId == otherUserId && inv.sentByMe) ||
              (inv.peerId == currentUserId && !inv.sentByMe)),
    );
  }

  /// Build action buttons based on current state
  Widget _buildActionButtons() {
    final storage = context.watch<StorageService>();
    final currentUserId = storage.currentProfile?.id ?? '';
    final otherUserId = widget.chatRoom?.getOtherUserId(currentUserId) ?? '';

    // Check if there's an accepted invitation with uncollected name card
    ChatMessage? acceptedInvitationMessage;
    if (widget.chatRoom != null) {
      for (final message in widget.chatRoom!.messages) {
        if (message.isInvitation &&
            message.isAccepted &&
            !(message.isNameCardCollected ?? false)) {
          acceptedInvitationMessage = message;
          break;
        }
      }
    }

    final hasConnection = storage.connectedProfiles.any(
      (profile) => profile.id == otherUserId,
    );

    // Show collect name card / not good match buttons if there's an accepted invitation
    if (acceptedInvitationMessage != null && !hasConnection) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _handleCollectNameCard(acceptedInvitationMessage!.id),
              icon: const Icon(Icons.contacts),
              label: const Text('Collect Name Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _handleNotGoodMatch(acceptedInvitationMessage!.id),
              icon: const Icon(Icons.close),
              label: const Text('Not Good Match'),
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
          const SizedBox(height: 8),
        ],
      );
    }

    // Show send invitation button if no pending invitation
    if (!_hasPendingInvitation()) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton.icon(
          onPressed: () => _showInvitationDialog(context),
          icon: const Icon(Icons.restaurant_menu),
          label: const Text('Send Invitation'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).primaryColor),
            foregroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Otherwise show nothing (pending invitation or name card already collected)
    return const SizedBox.shrink();
  }

  /// Show invitation creation dialog
  void _showInvitationDialog(BuildContext context) {
    final storage = context.read<StorageService>();
    final currentUserId = storage.currentProfile?.id ?? '';
    final otherUserId = widget.chatRoom?.getOtherUserId(currentUserId) ?? '';
    final restaurantController = TextEditingController();
    String? selectedActivityId;
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Send Invitation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invite this person to meet up for a meal!',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: restaurantController,
                decoration: const InputDecoration(
                  labelText: 'Restaurant *',
                  hintText: 'e.g., Campus Cafe, Pizza Place',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<StorageService>(
                builder: (context, storage, child) {
                  return DropdownButtonFormField<String>(
                    initialValue: selectedActivityId,
                    decoration: const InputDecoration(
                      labelText: 'Activity *',
                      border: OutlineInputBorder(),
                    ),
                    items: storage.activities.map((activity) {
                      return DropdownMenuItem(
                        value: activity.id.toString(),
                        child: Text(activity.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedActivityId = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isCreating ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  (isCreating ||
                      restaurantController.text.trim().isEmpty ||
                      selectedActivityId == null)
                  ? null
                  : () async {
                      setState(() => isCreating = true);

                      try {
                        final storage = context.read<StorageService>();
                        final peer = storage.getPeerById(otherUserId);

                        if (peer != null) {
                          final activity = storage.activities.firstWhere(
                            (a) => a.id.toString() == selectedActivityId,
                          );

                          await storage.sendInvitation(peer, activity.name);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invitation sent!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }

                          // Refresh to show the new invitation
                          await _refreshMessages();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to send invitation: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        setState(() => isCreating = false);
                      }
                    },
              child: isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final storage = context.read<StorageService>();
    final currentUserId = storage.currentProfile?.id ?? '';
    final otherUserId = widget.chatRoom?.getOtherUserId(currentUserId) ?? '';

    // Handle connection request messages
    if (message.isConnectionRequest) {
      final isFromMe = message.isMine;

      // TODO: improve handling
      final status = message.invitationData?['status'] as String? ?? 'pending';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contact_page, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isFromMe
                          ? 'You sent a name card request'
                          : '${storage.getPeerById(otherUserId)?.name ?? 'Someone'} wants to collect your name card',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isFromMe && status == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          _handleConnectionResponse(message.id, true),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _handleConnectionResponse(message.id, false),
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
              if (status == 'accepted') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Connection request accepted',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (status == 'declined') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, color: Colors.red[700], size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Connection request declined',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[700]?.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Handle invitation messages with enhanced card
    if (message.isInvitation) {
      final isFromMe = message.isMine;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: InvitationMessageCard(
          message: message,
          senderName: isFromMe
              ? 'You'
              : otherUserId.isNotEmpty
              ? storage.getPeerById(otherUserId)?.name
              : 'Unknown',
          isFromMe: isFromMe,
          onAccept: !isFromMe && message.isPending
              ? () => _handleInvitationResponse(message.id, true)
              : null,
          onDecline: !isFromMe && message.isPending
              ? () => _handleInvitationResponse(message.id, false)
              : null,
          onCollectCard:
              message.isAccepted && !(message.isNameCardCollected ?? false)
              ? () => _handleCollectNameCard(message.id)
              : null,
          onNotGoodMatch: message.isAccepted
              ? () => _handleNotGoodMatch(message.id)
              : null,
        ),
      );
    }

    // Handle connection response messages (system messages)
    if (message.isConnectionResponse) {
      Color bgColor = Colors.green.withValues(alpha: 0.1);
      Color borderColor = Colors.green.withValues(alpha: 0.3);
      Color textColor = Colors.green[700]!;
      IconData icon = Icons.check_circle;

      if (message.text.contains('declined')) {
        bgColor = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red.withValues(alpha: 0.3);
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
      } else if (message.text.contains('accepted')) {
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
                  Icon(icon, color: textColor, size: 20),
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

    // Default message bubble for regular text messages
    final isFromMe = message.isMine;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isFromMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isFromMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: otherUserId.isNotEmpty
                  ? NetworkImage(
                      storage.getPeerById(otherUserId)?.profileImageUrl ?? '',
                    )
                  : null,
              child: otherUserId.isEmpty
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: isFromMe
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isFromMe ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (isFromMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: storage.currentProfile?.profileImagePath != null
                  ? NetworkImage(storage.currentProfile!.profileImagePath!)
                  : null,
              child: storage.currentProfile?.profileImagePath == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
