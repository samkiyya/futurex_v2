class Subject {
  final int id;
  final String name;
  final String grade;
  final String category;
  final String image;

  Subject({
    required this.id,
    required this.name,
    required this.grade,
    required this.category,
    required this.image,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      grade: json['grade'],
      category: json['category'],
      image: json['image'],
    );
  }
}
