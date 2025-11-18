import 'profile.dart';

/// Model class representing a potential peer/match
class Peer {
  final String id;
  final String name;
  final String school;
  final String major;
  final String interests;
  final String background;
  final double matchScore; // 0.0 to 1.0
  final double distance; // distance in km
  final bool wantsToEat; // true if they want to eat, false otherwise
  final String? profileImageUrl; // URL for profile image

  Peer({
    required this.id,
    required this.name,
    required this.school,
    required this.major,
    required this.interests,
    required this.background,
    this.matchScore = 0.0,
    this.distance = 0.0,
    this.wantsToEat = true,
    this.profileImageUrl,
  });

  /// Calculate match score based on common interests/background
  static double calculateMatchScore(Profile user, Peer peer) {
    if (user.major == null && user.interests == null) {
      return 0.0;
    }

    // Split majors and interests into individual tags
    final userMajors = user.major?.split(',').map((e) => e.trim().toLowerCase()).toSet() ?? {};
    final userInterests = user.interests?.split(',').map((e) => e.trim().toLowerCase()).toSet() ?? {};
    final peerMajors = peer.major.split(',').map((e) => e.trim().toLowerCase()).toSet();
    final peerInterests = peer.interests.split(',').map((e) => e.trim().toLowerCase()).toSet();

    // Count matching tags
    final matchingMajors = userMajors.intersection(peerMajors).length;
    final matchingInterests = userInterests.intersection(peerInterests).length;
    final totalMatches = matchingMajors + matchingInterests;

    // Count total unique tags from both users
    final totalUserTags = userMajors.length + userInterests.length;
    final totalPeerTags = peerMajors.length + peerInterests.length;
    final totalTags = (totalUserTags + totalPeerTags) / 2; // Average

    if (totalTags == 0) return 0.0;

    // Calculate percentage: matching tags / average total tags
    return (totalMatches / totalTags).clamp(0.0, 1.0);
  }

  Peer copyWith({
    String? id,
    String? name,
    String? school,
    String? major,
    String? interests,
    String? background,
    double? matchScore,
    double? distance,
    bool? wantsToEat,
    String? profileImageUrl,
  }) {
    return Peer(
      id: id ?? this.id,
      name: name ?? this.name,
      school: school ?? this.school,
      major: major ?? this.major,
      interests: interests ?? this.interests,
      background: background ?? this.background,
      matchScore: matchScore ?? this.matchScore,
      distance: distance ?? this.distance,
      wantsToEat: wantsToEat ?? this.wantsToEat,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
