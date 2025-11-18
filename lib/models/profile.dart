import 'package:flutter/foundation.dart';

/// Unified profile model representing any user (current user or connections)
@immutable
class Profile {
  final String id;
  final String userName;
  final String? school;
  final String? major;
  final String? interests;
  final String? background;
  final String? profileImagePath;

  const Profile({
    required this.id,
    required this.userName,
    this.school,
    this.major,
    this.interests,
    this.background,
    this.profileImagePath,
  });

  Profile copyWith({
    String? id,
    String? userName,
    String? school,
    String? major,
    String? interests,
    String? background,
    String? profileImagePath,
  }) {
    return Profile(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      school: school ?? this.school,
      major: major ?? this.major,
      interests: interests ?? this.interests,
      background: background ?? this.background,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      if (school != null) 'school': school,
      if (major != null) 'major': major,
      if (interests != null) 'interests': interests,
      if (background != null) 'background': background,
      if (profileImagePath != null) 'profileImagePath': profileImagePath,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      userName: json['userName'] as String,
      school: json['school'] as String?,
      major: json['major'] as String?,
      interests: json['interests'] as String?,
      background: json['background'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Profile{id: $id, userName: $userName}';
  }
}
