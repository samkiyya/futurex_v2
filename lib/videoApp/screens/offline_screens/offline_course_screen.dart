import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:futurex_app/videoApp/provider/home_course_provider.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_section_screen.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_course_screen.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineCourseScreen extends StatefulWidget {
  final String userId;
  final bool isOnline;

  const OfflineCourseScreen({
    super.key,
    required this.userId,
    required this.isOnline,
  });

  @override
  State<OfflineCourseScreen> createState() => _OfflineCourseScreenState();
}

class _OfflineCourseScreenState extends State<OfflineCourseScreen> {
  bool _isOnlineActive = false;
  String? _gradeRange;

  @override
  void initState() {
    super.initState();
    _loadGradeRange();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final provider = Provider.of<HomeCourseProvider>(context, listen: false);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      // In this project setup, checkConnectivity returns List<ConnectivityResult>
      final bool isConnected = connectivityResult.any(
        (r) => r != ConnectivityResult.none,
      );

      if (isConnected) {
        await provider.fetchCourses();
      } else {
        await provider.getCoursesFromStorage();
      }
    } catch (e) {
      debugPrint('Error loading courses: $e');
    }
  }

  Future<void> _loadGradeRange() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gradeRange = prefs.getString('gradeRange') ?? '9-12';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: "Offline courses"),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          // Tab buttons at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Online Courses Button (moved to the left)
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

                // Offline Courses Button (moved to the right)
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
                        _loadCourses();
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
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Consumer<HomeCourseProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.courses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No courses available'),
                        ElevatedButton(
                          onPressed: _loadCourses,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return _buildCourseContent(provider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCourses,
        child: const Icon(Icons.refresh),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNav(onTabSelected: (index) {}, currentSelectedIndex: 1);
  }

  // Match grade range logic with online screen
  bool _matchesGradeRange(String category) {
    final range = _gradeRange ?? '9-12';
    if (range == '7-8') {
      return category.contains('7') || category.contains('8');
    }
    // For 9-12, include anything that is not 7 or 8 (covers other topics too)
    return !category.contains('7') && !category.contains('8');
  }

  // Build content similar to online _buildCourseContent
  Widget _buildCourseContent(HomeCourseProvider provider) {
    final List<Widget> sections = [];

    // Guard
    final all = provider.courses;
    if (all.isEmpty) {
      return Center(child: Text('No data available. Please retry again!'));
    }

    // New Courses (latest 10)
    final List<Course> sorted = List<Course>.from(all)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final newCourses = sorted
        .where((c) => _matchesGradeRange(c.category?.catagory ?? ''))
        .take(10)
        .toList();
    if (newCourses.isNotEmpty) {
      sections.add(_buildCategorySection('New Courses', newCourses));
    }

    // Categorized Courses (Grades first, then others)
    const gradeOrder = ['Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
    final Map<String, List<Course>> gradeBuckets = {};
    final Map<String, List<Course>> otherBuckets = {};

    for (final course in all) {
      final name = course.category?.catagory ?? '';
      if (!_matchesGradeRange(name)) continue;

      if (gradeOrder.contains(name)) {
        gradeBuckets.putIfAbsent(name, () => []).add(course);
      } else if (name.isNotEmpty) {
        otherBuckets.putIfAbsent(name, () => []).add(course);
      }
    }

    for (final grade in gradeOrder) {
      final items = gradeBuckets[grade];
      if (items != null && items.isNotEmpty) {
        sections.add(_buildCategorySection(grade, items));
      }
    }

    // Append other categories in alphabetical order for stability
    final otherKeys = otherBuckets.keys.toList()..sort();
    for (final key in otherKeys) {
      final items = otherBuckets[key]!;
      if (items.isNotEmpty) {
        sections.add(_buildCategorySection(key, items));
      }
    }

    if (sections.isEmpty) {
      return Center(child: Text('No data available for selected grade range'));
    }

    return ListView(padding: const EdgeInsets.all(16), children: sections);
  }

  Widget _buildCategorySection(String title, List<Course> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _navigateToSection(course),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Use local thumbnail if available
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: course.localThumbnailPath != null
                              ? Image.file(
                                  File(course.localThumbnailPath!),
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholderImage(),
                                )
                              : course.thumbnail.isNotEmpty
                              ? Image.network(
                                  // Ensure single slash between base and path
                                  course.thumbnail.startsWith('https://')
                                      ? course.thumbnail
                                      : '${Networks().thumbnailPath}${course.thumbnail.startsWith('/') ? '' : '/'}${course.thumbnail}',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholderImage(),
                                )
                              : _buildPlaceholderImage(),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }

  void _navigateToSection(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OfflineSectionScreen(courseId: course.id, title: course.title),
      ),
    );
  }
}
