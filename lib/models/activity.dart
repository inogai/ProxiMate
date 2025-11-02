/// Model class representing a user activity
class Activity {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  Activity copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
