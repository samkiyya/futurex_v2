import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/models/section_model.dart';

class CourseDetail {
  final int id;
  final String title;
  final String video_url;
  final String description;

  final List<Section> sections;

  CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.video_url,
    required this.sections,
  });
  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final course = json['course'];
    debugPrint('Raw course data: $course');
    final sectionsJson = course['sections'] as List<dynamic>? ?? [];
    final sections = sectionsJson.map((s) => Section.fromJson(s)).toList();
    // Debugging
    debugPrint('Raw course data: $course');
    debugPrint('Raw course data: $sections');
    return CourseDetail(
      id: int.tryParse(course['id'].toString()) ?? 0, // ✅ Fix for type safety
      title: course['title'] ?? '',
      video_url: course['video'] ?? '',
      description: course['description'] ?? '',
      sections: sections,
    );
  }
}
