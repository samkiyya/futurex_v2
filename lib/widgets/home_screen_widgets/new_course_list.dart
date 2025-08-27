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
    // Approximate five months as 150 days
    final fiveMonthsAgo = now.subtract(const Duration(days: 150));

    List<Course> filtered = courses.where((course) {
      final categoryName = course.category?.catagory ?? '';
      final updated = DateTime.tryParse(course.updatedAt);
      final created = DateTime.tryParse(course.createdAt);
      final dateAdded = updated ?? created;
      if (dateAdded == null || dateAdded.isBefore(fiveMonthsAgo)) {
        return false;
      }

      final is7or8 = categoryName.contains('7') || categoryName.contains('8');
      return gradeRange == '7-8' ? is7or8 : !is7or8;
    }).toList();

    int compareByDateDesc(Course a, Course b) {
      final da =
          DateTime.tryParse(a.updatedAt) ?? DateTime.tryParse(a.createdAt);
      final db =
          DateTime.tryParse(b.updatedAt) ?? DateTime.tryParse(b.createdAt);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    }

    filtered.sort(compareByDateDesc);
    return filtered;
  }
}
