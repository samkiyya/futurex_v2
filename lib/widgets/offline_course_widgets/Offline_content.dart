import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:futurex_app/videoApp/provider/home_course_provider.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_course_screen.dart';
import 'package:futurex_app/widgets/offline_course_widgets/category_section.dart';
import 'package:provider/provider.dart';

class OfflineContent extends StatefulWidget {
  final Animation<double> fadeAnimation;
  final void Function(int id, String title) onCourseTap;
  final VoidCallback onRefresh;
  final String gradeRange;
  final String userId;

  const OfflineContent({
    super.key,
    required this.fadeAnimation,
    required this.onCourseTap,
    required this.onRefresh,
    required this.gradeRange,
    required this.userId,
  });

  @override
  State<OfflineContent> createState() => _OfflineContentState();
}

class _OfflineContentState extends State<OfflineContent> {
  bool _isOnlineActive = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Consumer<HomeCourseProvider>(
        builder: (context, provider, _) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: provider.isLoading
              ? _buildLoadingState()
              : provider.courses.isEmpty
              ? _buildEmptyState()
              : _buildCourseList(provider.courses),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      key: ValueKey('loading'),
      child: CircularProgressIndicator(
        color: Colors.blueAccent,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      key: const ValueKey('empty'),
      opacity: widget.fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "No courses available for this grade range. Load them online first!",
            style: TextStyle(
              fontSize: 18,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              shadowColor: Colors.blueAccent.withOpacity(0.4),
            ),
            child: const Text(
              'Retry Offline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    final categoryCourses = _categorizeCourses(courses);
    final gradeOrder = [
      'Grade 7',
      'Grade 8',
      'Grade 9',
      'Grade 10',
      'Grade 11',
      'Grade 12',
    ];
    final otherCategories =
        categoryCourses.keys.where((cat) => !gradeOrder.contains(cat)).toList()
          ..shuffle();
    final orderedCategories = [...gradeOrder, ...otherCategories];

    return Column(
      children: [
        // Tab buttons at the top
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Offline Courses Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: _isOnlineActive
                          ? Colors.grey
                          : Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isOnlineActive = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OfflineCourseScreen(
                            userId: widget.userId,
                            isOnline: false,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download_for_offline,
                          color: _isOnlineActive ? Colors.grey : Colors.blue,
                        ),
                        const SizedBox(height: 4),
                        const Text("Offline Courses"),
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: double.infinity,
                          color: _isOnlineActive
                              ? Colors.transparent
                              : Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Online Courses Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: _isOnlineActive
                          ? Colors.blue
                          : Colors.grey,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isOnlineActive = true;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseOnlineScreen(
                            userId: widget.userId,
                            isonline: true,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi,
                          color: _isOnlineActive ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        const Text("Online Courses"),
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: double.infinity,
                          color: _isOnlineActive
                              ? Colors.blue
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Course List
        Expanded(
          child: FadeTransition(
            opacity: widget.fadeAnimation,
            child: ListView.builder(
              itemCount: orderedCategories.length,
              itemBuilder: (context, index) {
                final category = orderedCategories[index];
                final coursesInCategory = categoryCourses[category] ?? [];
                return coursesInCategory.isEmpty
                    ? const SizedBox.shrink()
                    : CategorySection(
                        category: category,
                        courses: coursesInCategory,
                        onCourseTap: widget.onCourseTap,
                      );
              },
            ),
          ),
        ),
      ],
    );
  }

  Map<String, List<Course>> _categorizeCourses(List<Course> courses) {
    debugPrint('Total courses: ${courses.length}');
    for (var course in courses) {
      debugPrint(
        'Course: ${course.title}, Category: ${course.category?.catagory ?? 'None'}',
      );
    }

    bool matchesGradeRange(String category) {
      if (widget.gradeRange == '7-8') {
        return category.contains('7') || category.contains('8');
      } else {
        return !category.contains('7') && !category.contains('8');
      }
    }

    final filteredCourses = courses.where((course) {
      final category = course.category?.catagory ?? '';
      return matchesGradeRange(category);
    }).toList();

    debugPrint(
      'Filtered courses for grade ${widget.gradeRange}: ${filteredCourses.length}',
    );

    return filteredCourses.fold<Map<String, List<Course>>>({}, (map, course) {
      final category = course.category?.catagory ?? 'Uncategorized';
      map.putIfAbsent(category, () => []).add(course);
      return map;
    });
  }
}
