/// Model class representing an invitation to eat
class Invitation {
  final String id;
  final String peerId;
  final String peerName;
  final String restaurant;
  final DateTime createdAt;
  final InvitationStatus status;
  final bool sentByMe; // true if user sent, false if received
  final List<IceBreaker> iceBreakers; // Ice-breaking questions
  final bool nameCardCollected; // Whether name card was collected

  Invitation({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.restaurant,
    required this.createdAt,
    this.status = InvitationStatus.pending,
    required this.sentByMe,
    List<IceBreaker>? iceBreakers,
    this.nameCardCollected = false,
  }) : iceBreakers = iceBreakers ?? [];

  Invitation copyWith({
    String? id,
    String? peerId,
    String? peerName,
    String? restaurant,
    DateTime? createdAt,
    InvitationStatus? status,
    bool? sentByMe,
    List<IceBreaker>? iceBreakers,
    bool? nameCardCollected,
  }) {
    return Invitation(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      restaurant: restaurant ?? this.restaurant,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      sentByMe: sentByMe ?? this.sentByMe,
      iceBreakers: iceBreakers ?? this.iceBreakers,
      nameCardCollected: nameCardCollected ?? this.nameCardCollected,
    );
  }

  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isPending => status == InvitationStatus.pending;
}

/// Ice-breaking question for conversation starters
class IceBreaker {
  final String question;
  final String answer;

  IceBreaker({
    required this.question,
    required this.answer,
  });
}

enum InvitationStatus {
  pending,
  accepted,
  declined,
}

/// Model class representing a chat room for accepted meetups
class ChatRoom {
  final String id;
  final String peerId;
  final String peerName;
  final String restaurant;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.restaurant,
    List<ChatMessage>? messages,
    required this.createdAt,
  }) : messages = messages ?? [];

  ChatRoom copyWith({
    String? id,
    String? peerId,
    String? peerName,
    String? restaurant,
    List<ChatMessage>? messages,
    DateTime? createdAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      restaurant: restaurant ?? this.restaurant,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model for chat messages
class ChatMessage {
  final String id;
  final String text;
  final bool isMine;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.timestamp,
  });
}
