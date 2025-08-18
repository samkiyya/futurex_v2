import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:futurex_app/widgets/offline_course_widgets/offline_course_card.dart';

class CategorySection extends StatelessWidget {
  final String category;
  final List<Course> courses;
  final void Function(int id, String title) onCourseTap;

  const CategorySection({
    super.key,
    required this.category,
    required this.courses,
    required this.onCourseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blueAccent, Colors.blue.shade900],
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                      shadows: [
                        Shadow(
                          color: Colors.blueAccent.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              itemBuilder: (context, idx) => Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 4.0),
                child: OfflineCourseCard(
                  course: courses[idx],
                  onTap: () => onCourseTap(courses[idx].id, courses[idx].title),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
