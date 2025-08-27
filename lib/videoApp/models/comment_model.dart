import 'user.dart';

class Comment {
  final int id;
  final int notificationId;
  final String userType;
  final int userId;
  final String comment;
  final String createdAt;
  final String updatedAt;
  final User? user;

  Comment({
    required this.id,
    required this.notificationId,
    required this.userType,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String parseString(dynamic v, {String fallback = ''}) {
      if (v == null) return fallback;
      return v.toString();
    }

    // Ensure createdAt/updatedAt are valid strings to avoid DateTime.parse null errors
    final created = parseString(
      json['createdAt'],
      fallback: DateTime.now().toIso8601String(),
    );
    final updated = parseString(
      json['updatedAt'],
      fallback: DateTime.now().toIso8601String(),
    );

    return Comment(
      id: parseInt(json['id']),
      notificationId: parseInt(json['notificationId']),
      userType: parseString(json['userType']),
      userId: parseInt(json['user_id']),
      comment: parseString(json['comment']),
      createdAt: created,
      updatedAt: updated,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
