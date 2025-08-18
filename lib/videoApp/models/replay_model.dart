class Reply {
  final int id;
  final int commentId;
  final int adminId;
  final String reply;
  final String userType;
  final String createdAt;
  final String updatedAt;

  Reply({
    required this.id,
    required this.commentId,
    required this.adminId,
    required this.reply,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'],
      commentId: json['commentId'],
      adminId: json['adminId'],
      reply: json['reply'],
      userType: json['userType'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}