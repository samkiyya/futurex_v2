class UserLevel {
  final int id;
  final int userId;
  final int level;
  final double score;
  final String name;
  final String grade;
  final Subject subject; // Change the type to Subject

  UserLevel({
    required this.id,
    required this.userId,
    required this.level,
    required this.score,
     required this.name,
    required this.grade,
    required this.subject,
  });

  factory UserLevel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('json must not be null');
    }

    return UserLevel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      level: json['level'] ?? 0,
      score: json['score'] is String ? double.parse(json['score']) : (json['score'] ?? 0.0),
      name: json['name'] ?? "",
      grade: json['grade'] ?? '',
      subject: Subject.fromJson(json['subject'] ?? {}), // Use Subject.fromJson and handle null with {}
    );
  }
}


class Subject {
  final int id;
  final String name;
  final String grade;
  final String category;
  final String image;

  Subject({
    required this.id,
    required this.name,
    required this.grade,
    required this.category,
    required this.image,
  });

  factory Subject.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('json must not be null');
    }

    return Subject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
