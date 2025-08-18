
class Chapter {
  final int id;
  final int unit;
  final int curriculumId;
  final int subjectId;

  Chapter({
    required this.id,
    required this.unit,
    required this.curriculumId,
    required this.subjectId,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      unit: json['unit'],
      curriculumId: json['curriculum_id'],
      subjectId: json['subject_id'],
    );
  }
}