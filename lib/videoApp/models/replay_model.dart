class Reply {
  final int id;
  final int commentId;
  final int? adminId;
  final String reply;
  final String? userType;
  final String createdAt;
  final String updatedAt;

  Reply({
    required this.id,
    required this.commentId,
    this.adminId,
    required this.reply,
    this.userType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
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

    return Reply(
      id: parseInt(json['id']),
      commentId: parseInt(json['commentId']),
      adminId: json['adminId'] is int
          ? json['adminId'] as int
          : (json['adminId'] is String ? int.tryParse(json['adminId']) : null),
      reply: parseString(json['reply']),
      userType: json['userType']?.toString(),
      createdAt: parseString(
        json['updatedAt'] == null && json['createdAt'] == null
            ? DateTime.now().toIso8601String()
            : json['createdAt'],
      ),
      updatedAt: parseString(
        json['updatedAt'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }
}
