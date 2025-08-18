class ExamResult {
  final int id;
  final int total;
  final String resultStatus;
  final String examStatus;
  final int examId;
  final int subjectId;
  final int userId;
  final String examTitle;
  final String subjectName;
  final String subjectYear;

  ExamResult({
    required this.id,
    required this.total,
    required this.resultStatus,
    required this.examStatus,
    required this.examId,
    required this.subjectId,
    required this.userId,
    required this.examTitle,
    required this.subjectName,
    required this.subjectYear,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: int.tryParse(json['id'].toString()) ?? 0,
      total: int.tryParse(json['total'].toString()) ?? 0,
      resultStatus: json['result_status'] ?? "",
      examStatus: json['exam_status'] ?? "",
      examId: int.tryParse(json['exam_id'].toString()) ?? 0,
      subjectId: int.tryParse(json['subject_id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      examTitle: json['exam']['title'] ?? "",
      subjectName: json['subject']['name'] ?? "",
      subjectYear: json['subject']['year'] ?? "",
    );
  }
}
