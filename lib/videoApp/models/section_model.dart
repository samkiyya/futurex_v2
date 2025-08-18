class Section {
  final int id;
  final String title;
  final int courseId; // Add courseId field

  Section({
    required this.id,
    required this.title,
    required this.courseId,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as int,
      title: json['title'] as String,
      courseId: json['course_id'], // Include courseId in the model
    );
  }

 

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_id': courseId, // Include courseId when converting to JSON
    };
  }
}
