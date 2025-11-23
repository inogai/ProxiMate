import 'package:flutter/foundation.dart';

/// Connection status enum
enum ConnectionStatus { pending, accepted, declined }

/// Represents a connection between two profiles
@immutable
class Connection {
  final String id;
  final String fromProfileId;
  final String toProfileId;
  final String restaurant;
  final DateTime collectedAt;
  final ConnectionStatus status;
  final String? notes;

  const Connection({
    required this.id,
    required this.fromProfileId,
    required this.toProfileId,
    required this.restaurant,
    required this.collectedAt,
    this.status = ConnectionStatus.pending,
    this.notes,
  });

  Connection copyWith({
    String? id,
    String? fromProfileId,
    String? toProfileId,
    String? restaurant,
    DateTime? collectedAt,
    ConnectionStatus? status,
    String? notes,
  }) {
    return Connection(
      id: id ?? this.id,
      fromProfileId: fromProfileId ?? this.fromProfileId,
      toProfileId: toProfileId ?? this.toProfileId,
      restaurant: restaurant ?? this.restaurant,
      collectedAt: collectedAt ?? this.collectedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromProfileId': fromProfileId,
      'toProfileId': toProfileId,
      'restaurant': restaurant,
      'collectedAt': collectedAt.toIso8601String(),
      'status': status.name,
      if (notes != null) 'notes': notes,
    };
  }

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String,
      fromProfileId: json['fromProfileId'] as String,
      toProfileId: json['toProfileId'] as String,
      restaurant: json['restaurant'] as String,
      collectedAt: DateTime.parse(json['collectedAt'] as String),
      status: ConnectionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConnectionStatus.pending,
      ),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Connection && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Connection{id: $id, from: $fromProfileId, to: $toProfileId, status: $status}';
  }
}
