import 'package:flutter/material.dart';
import '../../videoApp/models/course_model.dart';
import 'course_card.dart';

class CategoryCourseList extends StatelessWidget {
  final List<Course> courses;
  const CategoryCourseList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Course>> categoryCourses = _groupByCategory();
    final List<String> categories = categoryCourses.keys.toList();

    // Sort grade categories numerically, others alphabetically
    int categoryPriority(String name) {
      final digits = RegExp(r"\d+").firstMatch(name)?.group(0);
      if (digits != null) {
        return int.tryParse(digits) ?? 9999;
      }
      return 10000; // non-grade categories at the end, preserve alpha order next
    }

    categories.sort((a, b) {
      final pa = categoryPriority(a);
      final pb = categoryPriority(b);
      if (pa != pb) return pa.compareTo(pb);
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    if (categories.isEmpty) {
      return const SizedBox();
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
  }

  Map<String, List<Course>> _groupByCategory() {
    final Map<String, List<Course>> categoryCourses = {};
    for (final course in courses) {
      final name = (course.category?.catagory ?? '').trim();
      if (name.isEmpty) continue;
      categoryCourses.putIfAbsent(name, () => []).add(course);
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
            itemBuilder: (context, index) => CourseCard(
              course: categoryCourses[index],
              respectGradeRange: false, // show all courses in category
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
