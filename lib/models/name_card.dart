/// Model class representing a collected name card
class NameCard {
  final String id;
  final String peerId;
  final String name;
  final String school;
  final String major;
  final String interests;
  final String background;
  final String restaurant; // Where they met
  final DateTime collectedAt;

  NameCard({
    required this.id,
    required this.peerId,
    required this.name,
    required this.school,
    required this.major,
    required this.interests,
    required this.background,
    required this.restaurant,
    required this.collectedAt,
  });
}
