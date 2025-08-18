class UserRank {
  final int userId;
  final double maxScore;
  final int subjectId;
  final String subjectName;
  final int rank;

  UserRank({
    required this.userId,
    required this.maxScore,
    required this.subjectId,
    required this.subjectName,
    required this.rank,
  });

  factory UserRank.fromJson(Map<String, dynamic> json) {
    return UserRank(
      userId: json['user_id'] ?? 0,
      maxScore: json['max_score'] ?? 0.0,
      subjectId: json['subject_id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      rank: json['rank'] ?? 0,
    );
  }
}
