import 'user_profile.dart';

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
  });

  /// Calculate match score based on common interests/background
  static double calculateMatchScore(UserProfile user, Peer peer) {
    double score = 0.0;

    // School match
    if (user.school?.toLowerCase() == peer.school.toLowerCase()) {
      score += 0.3;
    }

    // Major match
    if (user.major?.toLowerCase() == peer.major.toLowerCase()) {
      score += 0.3;
    }

    // Interest overlap (simple word matching)
    if (user.interests != null && peer.interests.isNotEmpty) {
      final userInterests =
          user.interests!.toLowerCase().split(RegExp(r'[,\s]+'));
      final peerInterests = peer.interests.toLowerCase().split(RegExp(r'[,\s]+'));
      final commonInterests =
          userInterests.where((i) => peerInterests.contains(i)).length;
      if (commonInterests > 0) {
        score += 0.4 * (commonInterests / userInterests.length).clamp(0, 1);
      }
    }

    return score;
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
    );
  }
}
