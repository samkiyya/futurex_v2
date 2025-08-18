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
    return Comment(
      id: json['id'],
      notificationId: json['notificationId'],
      userType: json['userType'],
      userId: json['user_id'],
      comment: json['comment'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}