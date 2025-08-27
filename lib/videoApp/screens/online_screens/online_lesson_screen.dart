// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/chat_bottom_sheet.dart';
import 'package:futurex_app/videoApp/provider/offline_lesson_provide.dart';
import 'package:futurex_app/videoApp/screens/online_screens/lession_screen_helper.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';

// UI for displaying the online lesson screen with tab-based navigation
class OnlineLesson extends StatefulWidget {
  final int sectionId;
  final String section;

  OnlineLesson({super.key, required this.sectionId, required this.section});

  @override
  _OnlineLessonState createState() => _OnlineLessonState();
}

class _OnlineLessonState extends State<OnlineLesson>
    with SingleTickerProviderStateMixin {
  // Instantiate the controller to handle business logic
  final _controller = OnlineLessonController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with sectionId and context
    _controller.initialize(widget.sectionId, context);
    // Initialize TabController with 4 tabs (Video, PDF, HTML, Exam)
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<OfflineLessonProvider>(context);
    final lessons = lessonProvider.lessons;

    // Handle loading state
    if (lessonProvider.isLoading) {
      return _buildLoadingScaffold();
    }

    // Handle empty lessons state
    if (lessons.isEmpty) {
      return _buildEmptyScaffold();
    }

    // Build scaffold with tab-based lessons
    return _buildLessonsScaffold(lessons);
  }

  // Build scaffold for loading state
  Scaffold _buildLoadingScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  // Build scaffold for empty lessons state
  Scaffold _buildEmptyScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.not_interested, size: 50, color: Colors.redAccent),
            SizedBox(height: 20),
            Text(
              "No lessons available for this chapter",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 2,
      ),
    );
  }

  // Build scaffold with tab-based lessons
  Scaffold _buildLessonsScaffold(List lessons) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
      body: Column(
        children: [
          // TabBar for lesson types
          TabBar(
            controller: _tabController,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: const [
              Tab(text: 'Videos'),
              Tab(text: 'Notes'),
              Tab(text: 'Questions'),
            ],
          ),
          // TabBarView for displaying lessons by type
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLessonsTab(lessons, 'video'),
                _buildLessonsTab(lessons, 'pdf'),
                _buildLessonsTab(lessons, 'html'),
                // _buildLessonsTab(lessons, '3dmodel'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 2,
      ),
    );
  }

  // Build lessons tab for a specific lesson type
  Widget _buildLessonsTab(List lessons, String lessonType) {
    final filteredLessons = _controller.filterLessonsByType(
      lessons,
      lessonType,
    );

    if (filteredLessons.isEmpty) {
      return Center(
        child: Text(
          'No $lessonType lessons available',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredLessons.length,
      itemBuilder: (context, index) {
        final lesson = filteredLessons[index];
        final lessonTitle = lesson['title'] ?? 'Untitled';
        final videoUrl = lesson['video_url'] ?? '';
        final link = lesson['link'] ?? '';
        final thumbnailUrl = _controller.getVideoThumbnail(videoUrl);
        final pdfUrl = lesson['attachment'] ?? '';

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display lesson content based on type
                _controller.buildLessonContent(
                  lessons: lessons,
                  lessonTitle: lessonTitle,
                  thumbnail: thumbnailUrl,
                  lessonType: lessonType,
                  videoUrl: videoUrl,
                  link: link,
                  pdfUrl: pdfUrl,
                  context: context,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build AppBar with refresh and offline button
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.section, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _controller.navigateToOfflineLessons(
              context,
              widget.sectionId,
              widget.section,
            );
          },
        ),
      ],
    );
  }

  // Build floating action button for chat
  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const ChatBottomSheet(),
          );
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: Image.asset(
          'assets/images/bot.png',
          fit: BoxFit.cover,
          height: 28,
          width: 28,
        ),
      ),
    );
  }
}
