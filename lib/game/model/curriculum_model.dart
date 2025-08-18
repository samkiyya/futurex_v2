class Curriculum {
  final int id;
  final String name;
  final String description;
  final String curriculum_grade;

  Curriculum({
    required this.id,
    required this.name,
    required this.description,
    required this.curriculum_grade,
  });

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      curriculum_grade:json['curriculum_grade']
    );
  }
}