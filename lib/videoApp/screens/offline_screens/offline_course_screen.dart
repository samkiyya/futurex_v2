import 'dart:io';

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:futurex_app/videoApp/provider/home_course_provider.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_section_screen.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_course_screen.dart';
import 'package:futurex_app/widgets/appBar.dart';
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
      final isConnected = connectivityResult != ConnectivityResult.none;

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

  Future<String> _getGradeRange() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gradeRange') ?? '9-12';
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

                // Filter courses based on grade range
                final filteredCourses = _filterCoursesByGrade(provider.courses);

                // Organize by category
                final categoryCourses = _organizeCoursesByCategory(
                  filteredCourses,
                );

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Grade 9-12 Sections
                    if (categoryCourses['Grade 9']?.isNotEmpty ?? false)
                      _buildCategorySection(
                        'Grade 9',
                        categoryCourses['Grade 9']!,
                      ),

                    if (categoryCourses['Grade 10']?.isNotEmpty ?? false)
                      _buildCategorySection(
                        'Grade 10',
                        categoryCourses['Grade 10']!,
                      ),

                    if (categoryCourses['Grade 11']?.isNotEmpty ?? false)
                      _buildCategorySection(
                        'Grade 11',
                        categoryCourses['Grade 11']!,
                      ),

                    if (categoryCourses['Grade 12']?.isNotEmpty ?? false)
                      _buildCategorySection(
                        'Grade 12',
                        categoryCourses['Grade 12']!,
                      ),

                    // Other Categories
                    if (categoryCourses['Other']?.isNotEmpty ?? false)
                      _buildCategorySection(
                        'Other Courses',
                        categoryCourses['Other']!,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCourses,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  List<Course> _filterCoursesByGrade(List<Course> courses) {
    if (_gradeRange == '7-8') {
      return courses.where((course) {
        final category = course.category?.catagory ?? '';
        return category.contains('7') || category.contains('8');
      }).toList();
    } else {
      // Default to 9-12
      return courses.where((course) {
        final category = course.category?.catagory ?? '';
        return category.contains('9') ||
            category.contains('10') ||
            category.contains('11') ||
            category.contains('12');
      }).toList();
    }
  }

  Map<String, List<Course>> _organizeCoursesByCategory(List<Course> courses) {
    final Map<String, List<Course>> categoryCourses = {
      'Grade 9': [],
      'Grade 10': [],
      'Grade 11': [],
      'Grade 12': [],
      'Other': [],
    };

    for (final course in courses) {
      final category = course.category?.catagory ?? '';

      if (category.contains('9')) {
        categoryCourses['Grade 9']!.add(course);
      } else if (category.contains('10')) {
        categoryCourses['Grade 10']!.add(course);
      } else if (category.contains('11')) {
        categoryCourses['Grade 11']!.add(course);
      } else if (category.contains('12')) {
        categoryCourses['Grade 12']!.add(course);
      } else {
        categoryCourses['Other']!.add(course);
      }
    }

    return categoryCourses;
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
          height: 200,
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
                                  '${Networks().thumbnailPath}${course.thumbnail}',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPlaceholderImage(),
                                )
                              : _buildPlaceholderImage(),
                        ),
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
