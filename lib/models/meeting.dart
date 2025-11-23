/// Model class representing an invitation to eat
class Invitation {
  final String id;
  final String peerId;
  final String peerName;
  final String restaurant;
  final String activityId; // ID of the activity this invitation belongs to
  final DateTime createdAt;
  final InvitationStatus status;
  final bool sentByMe; // true if user sent, false if received
  final List<IceBreaker> iceBreakers; // Ice-breaking questions
  final bool nameCardCollected; // Whether name card was collected
  final bool chatOpened; // Whether the chat has been opened at least once

  Invitation({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.restaurant,
    required this.activityId,
    required this.createdAt,
    this.status = InvitationStatus.pending,
    required this.sentByMe,
    List<IceBreaker>? iceBreakers,
    this.nameCardCollected = false,
    this.chatOpened = false,
  }) : iceBreakers = iceBreakers ?? [];

  Invitation copyWith({
    String? id,
    String? peerId,
    String? peerName,
    String? restaurant,
    String? activityId,
    DateTime? createdAt,
    InvitationStatus? status,
    bool? sentByMe,
    List<IceBreaker>? iceBreakers,
    bool? nameCardCollected,
    bool? chatOpened,
  }) {
    return Invitation(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      restaurant: restaurant ?? this.restaurant,
      activityId: activityId ?? this.activityId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      sentByMe: sentByMe ?? this.sentByMe,
      iceBreakers: iceBreakers ?? this.iceBreakers,
      nameCardCollected: nameCardCollected ?? this.nameCardCollected,
      chatOpened: chatOpened ?? this.chatOpened,
    );
  }

  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isPending => status == InvitationStatus.pending;
}

/// Ice-breaking question for conversation starters
class IceBreaker {
  final String question;
  final String answer;

  IceBreaker({required this.question, required this.answer});
}

enum InvitationStatus { pending, accepted, declined }

/// Model class representing a chat room for accepted meetups
class ChatRoom {
  final String id;
  final String user1Id;
  final String user2Id;
  final String restaurant;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.restaurant,
    List<ChatMessage>? messages,
    required this.createdAt,
  }) : messages = messages ?? [];

  ChatRoom copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    String? restaurant,
    List<ChatMessage>? messages,
    DateTime? createdAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      restaurant: restaurant ?? this.restaurant,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get the other user's ID in the chat room
  String getOtherUserId(String currentUserId) {
    if (currentUserId == user1Id) return user2Id;
    if (currentUserId == user2Id) return user1Id;
    throw Exception('User $currentUserId is not part of this chat room');
  }

  /// Check if current user is part of this chat room
  bool containsUser(String userId) {
    return userId == user1Id || userId == user2Id;
  }

  /// Get the other user's name (requires profile lookup)
  String getOtherUserName(
    String currentUserId,
    Map<String, String> userIdToName,
  ) {
    final otherUserId = getOtherUserId(currentUserId);
    return userIdToName[otherUserId] ?? 'Unknown User';
  }
}

/// Message types for chat system
enum MessageType {
  text,
  invitation,
  invitationResponse,
  connectionRequest,
  connectionResponse,
  system,
}

/// Model for chat messages
class ChatMessage {
  final String id;
  final String text;
  final bool isMine;
  final DateTime timestamp;
  final MessageType messageType; // Type of message
  final Map<String, dynamic>?
  invitationData; // Invitation data for invitation messages
  final List<IceBreaker>? iceBreakers; // Ice breakers for invitation messages
  final bool? isNameCardCollected; // Name card collection status
  final DateTime? responseDeadline; // Response deadline for invitations
  final String? invitationId; // Reference to invitation ID

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.invitationData,
    this.iceBreakers,
    this.isNameCardCollected,
    this.responseDeadline,
    this.invitationId,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isMine,
    DateTime? timestamp,
    MessageType? messageType,
    Map<String, dynamic>? invitationData,
    List<IceBreaker>? iceBreakers,
    bool? isNameCardCollected,
    DateTime? responseDeadline,
    String? invitationId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isMine: isMine ?? this.isMine,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      invitationData: invitationData ?? this.invitationData,
      iceBreakers: iceBreakers ?? this.iceBreakers,
      isNameCardCollected: isNameCardCollected ?? this.isNameCardCollected,
      responseDeadline: responseDeadline ?? this.responseDeadline,
      invitationId: invitationId ?? this.invitationId,
    );
  }

  // Convenience getters for backward compatibility
  bool get isSystemMessage =>
      messageType == MessageType.system ||
      messageType == MessageType.invitationResponse;

  bool get isInvitation => messageType == MessageType.invitation;

  bool get isInvitationResponse =>
      messageType == MessageType.invitationResponse;

  bool get isConnectionRequest => messageType == MessageType.connectionRequest;

  bool get isConnectionResponse =>
      messageType == MessageType.connectionResponse;

  String? get invitationStatus =>
      isInvitation ? (invitationData?["status"]) : null;

  String? get connectionStatus => isConnectionRequest || isConnectionResponse
      ? (invitationData?["status"])
      : null;

  bool get isPending => invitationStatus == "pending";

  bool get isAccepted => invitationStatus == "accepted";

  bool get isDeclined => invitationStatus == "declined";
}
