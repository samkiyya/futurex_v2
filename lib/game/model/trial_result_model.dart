class TrialResult {
  final int id;
  final int userId;
  final int level;
    final int userlevel;
  final double? score;
  final String grade;
  final int subjectId;
  final String subjectName;

  TrialResult({
    required this.id,
    required this.userId,
    required this.level,
     required this.userlevel,
    this.score,
    required this.grade,
    required this.subjectId,
    required this.subjectName,
  });

  factory TrialResult.fromJson(Map<String, dynamic> json) {
    return TrialResult(
      id: int.parse(json['id']),
      userId: int.parse(json['user_id']),
      level: int.parse(json['level']),
      userlevel: int.parse(json['userlevel']),
      score: json['score'] != null ? double.tryParse(json['score']) : null,
      grade: json['grade'],
      subjectId: int.parse(json['subject_id']),
      subjectName: json['subject_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'level': level,
      'score': score?.toString(),
      'grade': grade,
      'subject_id': subjectId,
      'subject_name': subjectName,
    };
  }
}
