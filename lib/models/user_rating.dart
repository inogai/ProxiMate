/// Model for user ratings after interactions
class UserRating {
  final String id;
  final String ratedUserId; // The user being rated
  final String ratedByUserId; // The user giving the rating
  final int rating; // 1-5 stars
  final String? reason; // Required for 1-2 star ratings
  final DateTime createdAt;

  UserRating({
    required this.id,
    required this.ratedUserId,
    required this.ratedByUserId,
    required this.rating,
    this.reason,
    required this.createdAt,
  });

  UserRating copyWith({
    String? id,
    String? ratedUserId,
    String? ratedByUserId,
    int? rating,
    String? reason,
    DateTime? createdAt,
  }) {
    return UserRating(
      id: id ?? this.id,
      ratedUserId: ratedUserId ?? this.ratedUserId,
      ratedByUserId: ratedByUserId ?? this.ratedByUserId,
      rating: rating ?? this.rating,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ratedUserId': ratedUserId,
      'ratedByUserId': ratedByUserId,
      'rating': rating,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserRating.fromJson(Map<String, dynamic> json) {
    return UserRating(
      id: json['id'] as String,
      ratedUserId: json['ratedUserId'] as String,
      ratedByUserId: json['ratedByUserId'] as String,
      rating: json['rating'] as int,
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
