import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'course_card.dart';

class NewCourseList extends StatelessWidget {
  final List<Course> courses;
  const NewCourseList({super.key, required this.courses});

  Future<String> _getGradeRange() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gradeRange') ?? '9-12'; // default to 9-12
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
          return const SizedBox();
        }

        final gradeRange = snapshot.data!;
        final newCourses = _filterNewCoursesByGradeRange(gradeRange);

        if (newCourses.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "New Courses",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 260,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: newCourses.length,
                itemBuilder: (context, index) =>
                    CourseCard(course: newCourses[index]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  List<Course> _filterNewCoursesByGradeRange(String gradeRange) {
    final now = DateTime.now();
    final ninetyDaysAgo = now.subtract(const Duration(days: 150));

    return courses.where((course) {
      final categoryName = course.category?.catagory ?? '';
      final dateAdded = DateTime.tryParse(course.createdAt ?? '');
      if (dateAdded == null || dateAdded.isBefore(ninetyDaysAgo)) {
        return false;
      }

      final is7or8 = categoryName.contains('7') || categoryName.contains('8');

      if (gradeRange == '7-8') {
        return is7or8;
      } else {
        return !is7or8;
      }
    }).toList()..sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt ?? '');
      final dateB = DateTime.tryParse(b.createdAt ?? '');
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });
  }
}
