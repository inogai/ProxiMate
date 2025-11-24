import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:playground/models/meeting.dart';
import 'package:playground/services/api_service.dart';

/// ChatService: owner of chat state and polling. Intended to replace
/// the previous PollService+storage-based chat polling flow.
class ChatService extends ChangeNotifier {
  int userId;
  bool _isDisposed = false;

  final ApiService _apiService = ApiService();
  // Optional overrides (used by tests or advanced mocking)
  final Future<List<ChatRoom>> Function()? getChatRoomsOverride;
  final Future<void> Function(String)? refreshChatRoomMessagesOverride;
  final Future<void> Function()? refreshChatRoomsOverride;
  final void Function(String)? debugLog;

  List<ChatRoom> _chatRooms = [];
  bool _isLoading = false;

  Timer? _messagePollTimer;
  Timer? _chatRoomPollTimer;

  // Track last message fetch per room (optional, used to reduce churn)
  final Map<String, DateTime> _lastMessageFetch = {};

  ChatService({
    required this.userId,
    this.getChatRoomsOverride,
    this.refreshChatRoomMessagesOverride,
    this.refreshChatRoomsOverride,
    this.debugLog,
  });

  /// Update the service to a new user id (used by provider update to reuse
  /// a single ChatService instance across logins). This clears state when
  /// the user id changes.
  void updateUser(int newUserId) {
    if (_isDisposed) return;
    if (userId == newUserId) return;
    userId = newUserId;
    // Reset state when user becomes unauthenticated
    if (newUserId == 0) {
      _chatRooms = [];
      _lastMessageFetch.clear();
      stopMessagePolling();
      stopChatRoomPolling();
    }
    notifyListeners();
  }

  List<ChatRoom> get chatRooms => _chatRooms;

  bool get isLoading => _isLoading;

  /// Refresh list of chat rooms from API and notify listeners.
  Future<void> refreshChatRooms() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (getChatRoomsOverride != null) {
        // test or mock path: override returns List<ChatRoom>
        final rooms = await getChatRoomsOverride!();
        _chatRooms = rooms;
      } else {
        final roomsRead = await _apiService.getChatRooms(userId);
        _chatRooms = roomsRead
            .map((it) => _apiService.chatRoomReadToChatRoom(it))
            .toList();
      }
      // (already assigned above / or assigned from override)

      _chatRooms.sort(
        (ChatRoom a, ChatRoom b) =>
            b.lastMessageTime.compareTo(a.lastMessageTime),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch messages for a single chat room and merge into local state.
  Future<void> refreshChatRoomMessages(String chatRoomId) async {
    final index = _chatRooms.indexWhere((c) => c.id == chatRoomId);
    if (index == -1) return;

    try {
      if (refreshChatRoomMessagesOverride != null) {
        await refreshChatRoomMessagesOverride!(chatRoomId);
        return;
      }

      final messagesRead = await _apiService.getChatMessages(chatRoomId);

      final converted = messagesRead
          .map(
            (m) => _apiService.chatMessageReadToChatMessage(
              m,
              m.senderId == userId,
            ),
          )
          .toList();

      // Update last fetch time
      _lastMessageFetch[chatRoomId] = DateTime.now();

      _chatRooms[index] = _chatRooms[index].copyWith(messages: converted);
      notifyListeners();
    } catch (e) {
      // Keep local messages if API fails - just log in debug mode
      if (kDebugMode) debugPrint('refreshChatRoomMessages failed: $e');
    }
  }

  /// Send message with optimistic UI update. Errors won't remove optimistic
  /// message - polling will keep state consistent.
  Future<void> sendMessage(String chatRoomId, String text) async {
    final index = _chatRooms.indexWhere((c) => c.id == chatRoomId);
    if (index == -1) return;

    final localTimestamp = DateTime.now();
    final message = ChatMessage(
      id: localTimestamp.millisecondsSinceEpoch.toString(),
      text: text,
      isMine: true,
      timestamp: localTimestamp,
      messageType: MessageType.text,
    );

    final updatedMessages = [..._chatRooms[index].messages, message];
    _chatRooms[index] = _chatRooms[index].copyWith(messages: updatedMessages);
    notifyListeners();

    try {
      await _apiService.sendChatMessage(chatRoomId, userId, text);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to send message: $e');
      // Keep optimistic message; polling will reconcile
    }
  }

  /// Get chat room between two users if present locally.
  ChatRoom? getChatRoomBetweenUsers(String user1Id, String user2Id) {
    try {
      return _chatRooms.firstWhere(
        (c) => c.containsUser(user1Id) && c.containsUser(user2Id),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get or create a chatroom (uses backend create-or-get endpoint).
  Future<ChatRoom?> getOrCreateChatRoomBetweenUsers(
    int user1Id,
    int user2Id,
    String restaurant,
  ) async {
    final chatRoomRead = await _apiService.findChatRoomBetweenUsers(
      user1Id,
      user2Id,
      restaurant,
    );

    if (chatRoomRead == null) return null;

    final chatRoom = _apiService.chatRoomReadToChatRoom(chatRoomRead);
    // Add or replace
    final idx = _chatRooms.indexWhere((c) => c.id == chatRoom.id);
    if (idx == -1) {
      _chatRooms.add(chatRoom);
    } else {
      _chatRooms[idx] = chatRoom;
    }

    notifyListeners();
    return chatRoom;
  }

  /// Pull invitations from messages (derived). Useful for UI that needs
  /// invitations list. This is a best-effort sync using locally cached
  /// messages.
  List<Invitation> fetchInvitations() {
    final Map<String, Invitation> byId = {};

    for (final chatRoom in _chatRooms) {
      final peerId = chatRoom.user1Id == userId.toString()
          ? chatRoom.user2Id
          : chatRoom.user1Id;

      for (final msg in chatRoom.messages) {
        if (!msg.isInvitation) continue;

        final id = msg.invitationId ?? msg.id;
        final status = (msg.invitationStatus ?? 'pending').toLowerCase();

        final invitation = Invitation(
          id: id,
          peerId: peerId,
          peerName: '',
          restaurant: msg.invitationData?['restaurant']?.toString() ?? msg.text,
          activityId: msg.invitationData?['activityId']?.toString() ?? '',
          createdAt: msg.timestamp,
          sentByMe: msg.isMine,
          status: _parseInvitationStatus(status),
          iceBreakers: msg.iceBreakers ?? [],
          nameCardCollected: msg.isNameCardCollected ?? false,
          chatOpened: true,
        );

        byId[id] = invitation;
      }
    }

    final invitations = byId.values.toList();
    return invitations;
  }

  InvitationStatus _parseInvitationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return InvitationStatus.pending;
      case 'accepted':
        return InvitationStatus.accepted;
      case 'declined':
        return InvitationStatus.declined;
      default:
        return InvitationStatus.pending;
    }
  }

  /// Start periodic polling which refreshes messages for every chat room.
  void startMessagePolling({Duration interval = const Duration(seconds: 5)}) {
    if (_isDisposed) return;
    _messagePollTimer?.cancel();
    _messagePollTimer = Timer.periodic(interval, (_) async {
      // Refresh messages for each room sequentially to avoid storms
      for (final room in List<ChatRoom>.from(_chatRooms)) {
        try {
          if (refreshChatRoomMessagesOverride != null) {
            await refreshChatRoomMessagesOverride!(room.id);
          } else {
            await refreshChatRoomMessages(room.id);
          }
        } catch (_) {
          // ignore per-room errors
        }
      }
    });
  }

  void stopMessagePolling() {
    _messagePollTimer?.cancel();
    _messagePollTimer = null;
  }

  /// Start periodic polling for chat room list (new rooms, ordering, etc.)
  void startChatRoomPolling({Duration interval = const Duration(seconds: 10)}) {
    if (_isDisposed) return;
    _chatRoomPollTimer?.cancel();
    _chatRoomPollTimer = Timer.periodic(interval, (_) async {
      try {
        if (refreshChatRoomsOverride != null) {
          await refreshChatRoomsOverride!();
        } else {
          await refreshChatRooms();
        }
      } catch (_) {}
    });
  }

  void stopChatRoomPolling() {
    _chatRoomPollTimer?.cancel();
    _chatRoomPollTimer = null;
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    stopMessagePolling();
    stopChatRoomPolling();
    _isDisposed = true;
    super.dispose();
  }
}
