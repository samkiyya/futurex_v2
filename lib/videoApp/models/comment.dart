class Comment {
  final String userName;
  final String comment;
  final String reply;
  final String createdAt;

  Comment({
    required this.userName,
    required this.comment,
    required this.reply,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userName: json['user_name'] ?? '',
      comment: json['comment'] ?? '',
      reply: json['reply'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
