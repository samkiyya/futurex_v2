import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../videoApp/models/course_model.dart';
import 'course_card.dart';

class CategoryCourseList extends StatelessWidget {
  final List<Course> courses;
  const CategoryCourseList({super.key, required this.courses});

  Future<String> _getGradeRange() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gradeRange') ?? '9-12';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getGradeRange(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No grade range set"));
        }

        final gradeRange = snapshot.data!;
        Map<String, List<Course>> categoryCourses = _categorizeByCustomLogic(
          gradeRange,
        );
        List<String> categories = categoryCourses.keys.toList();

        // Sort categories so grade-related ones show in order
        const gradeOrder = {'7': 1, '8': 2, '9': 3, '10': 4, '11': 5, '12': 6};
        categories.sort((a, b) {
          int getPriority(String name) {
            for (var grade in gradeOrder.keys) {
              if (name.contains(grade)) return gradeOrder[grade]!;
            }
            return 1000 + name.toLowerCase().codeUnitAt(0);
          }

          return getPriority(a).compareTo(getPriority(b));
        });

        if (categories.isEmpty) {
          return const Center(child: Text("No matching courses found."));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categories
              .map(
                (category) =>
                    _buildCategoryCard(category, categoryCourses[category]!),
              )
              .toList(),
        );
      },
    );
  }

  // ✅ Custom filtering logic based on gradeRange
  Map<String, List<Course>> _categorizeByCustomLogic(String gradeRange) {
    Map<String, List<Course>> categoryCourses = {};

    for (var course in courses) {
      final categoryName = course.category?.catagory ?? '';
      if (categoryName.isEmpty) continue;

      final normalized = categoryName.toLowerCase().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final isGrade7 = normalized == '7';
      final isGrade8 = normalized == '8';
      final isGrade7Or8 = isGrade7 || isGrade8;

      if (gradeRange == '7-8') {
        if (!isGrade7Or8) continue;
      } else {
        if (isGrade7Or8) continue;
      }

      categoryCourses.putIfAbsent(categoryName, () => []).add(course);
    }

    return categoryCourses;
  }

  Widget _buildCategoryCard(String category, List<Course> categoryCourses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            category,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 260,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoryCourses.length,
            itemBuilder: (context, index) =>
                CourseCard(course: categoryCourses[index]),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
