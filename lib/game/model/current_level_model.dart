// model.dart
class CurrentUserLevel {
  final int userId;
  final int level;
  final int score;
  final String subject;
  final String grade;

  CurrentUserLevel({
    required this.userId,
    required this.level,
    required this.score,
    required this.subject,
    required this.grade,
  });

  factory CurrentUserLevel.fromJson(Map<String, dynamic> json) {
    return CurrentUserLevel(
      userId: json['user_id'],
      level: json['level'],
      score: json['score'],
      subject: json['subject'],
      grade: json['grade'],
    );
  }
}
