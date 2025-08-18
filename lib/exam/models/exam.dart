// Exam Model
class Exam {
  final int id;
  final String title;
  final int passingScore;
  final String examType;

  Exam({
    required this.id,
    required this.title,
    required this.passingScore,
    required this.examType,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'],
      passingScore: json['passing_score'],
      examType: json['exam_type'],
    );
  }
}
