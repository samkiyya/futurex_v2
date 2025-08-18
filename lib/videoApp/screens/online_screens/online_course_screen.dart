// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/constants.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:futurex_app/videoApp/provider/home_course_provider.dart';
import 'package:futurex_app/videoApp/provider/online_course_provide.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_section_screen.dart';
import 'package:futurex_app/widgets/appBar.dart';
import 'package:futurex_app/widgets/drawer.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseOnlineScreen extends StatefulWidget {
  final String userId;

  const CourseOnlineScreen({
    super.key,
    required this.userId,
    required bool isonline,
  });

  @override
  State<CourseOnlineScreen> createState() => _CourseOnlineScreenState();
}

class _CourseOnlineScreenState extends State<CourseOnlineScreen> {
  bool _isOnlineActive = true; // Track which tab is active
  @override
  void initState() {
    super.initState();
    Provider.of<HomeCourseProvider>(context, listen: false).fetchCourses();
  }

  // Read grade range from shared_preferences
  Future<String> _getGradeRange() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gradeRange') ?? '9-12'; // Default to '9-12'
  }

  void _navigateToSection(int courseId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OnlineSectionScreen(courseId: courseId, title: title),
      ),
    );
  }

  @override
  // Add this to your state class
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnlineCourseProvider()..fetchData(),
      child: Scaffold(
        appBar: GradientAppBar(title: "Online courses"),
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
                              color: _isOnlineActive
                                  ? Colors.grey
                                  : Colors.blue,
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
                              color: _isOnlineActive
                                  ? Colors.blue
                                  : Colors.grey,
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
              child: FutureBuilder<String>(
                future: _getGradeRange(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final gradeRange = snapshot.data!;
                  return _buildBody(gradeRange);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _buildRefreshButton(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Consumer<OnlineCourseProvider>(
      builder: (context, provider, child) => FloatingActionButton(
        onPressed: provider.fetchData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNav(onTabSelected: (index) {}, currentSelectedIndex: 1);
  }

  Widget _buildBody(String gradeRange) {
    return Consumer<OnlineCourseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error.isNotEmpty) {
          return _buildErrorState(provider.error);
        }
        if (provider.courses.isEmpty) {
          return _buildEmptyState();
        }
        return _buildCourseContent(provider, gradeRange);
      },
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: ResponsiveImageTextWidget(
        imageUrl: 'assets/images/nointernet.gif',
        text: errorMessage,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ResponsiveImageTextWidget(
        imageUrl: 'assets/images/nodata.gif',
        text: 'No data available. Please retry again!',
      ),
    );
  }

  Widget _buildCourseContent(OnlineCourseProvider provider, String gradeRange) {
    final widgets = <Widget>[];

    // Filter courses based on grade range
    bool matchesGradeRange(String category) {
      if (gradeRange == '7-8') {
        return category.contains('7') || category.contains('8');
      } else {
        // Return true only if it does NOT contain 7 or 8 and contains 9-12
        return !category.contains('7') && !category.contains('8');
      }
    }

    // New Courses Section
    final filteredNewCourses = provider.newCourses.where((course) {
      final category = course.category?.catagory ?? '';
      return matchesGradeRange(category);
    }).toList();

    if (filteredNewCourses.isNotEmpty) {
      widgets.add(_buildSection('New Courses', filteredNewCourses));
    }

    // Categorized Courses (Grades first, then others)
    final filteredCategorizedCourses = <String, List<Course>>{};
    provider.categorizedCourses.forEach((category, courses) {
      final filteredCourses = courses.where((course) {
        final courseCategory = course.category?.catagory ?? '';
        return matchesGradeRange(courseCategory);
      }).toList();
      if (filteredCourses.isNotEmpty) {
        filteredCategorizedCourses[category] = filteredCourses;
      }
    });

    filteredCategorizedCourses.forEach((category, courses) {
      widgets.add(_buildSection(category, courses));
    });

    if (widgets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(children: widgets);
  }

  Widget _buildSection(String title, List<Course> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) =>
                _buildCourseCard(courses[index], isHorizontal: true),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCourseCard(Course course, {required bool isHorizontal}) {
    return GestureDetector(
      onTap: () => _navigateToSection(course.id, course.title),
      child: Container(
        width: MediaQuery.of(context).size.width, // Full screen width
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ), // Padding on left and right
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: isHorizontal
              ? _buildHorizontalCourseCard(course)
              : _buildVerticalCourseCard(course),
        ),
      ),
    );
  }

  Widget _buildHorizontalCourseCard(Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: Image.network(
            '${course.thumbnail}',
            width: double.infinity,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                size: 60,
                color: Colors.grey,
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            child: Center(
              child: Text(
                course.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16), // Slightly smaller font
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalCourseCard(Course course) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
            child: Image.network(
              Networks().thumbnailPath + '/${course.thumbnail}',
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              course.title,
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
