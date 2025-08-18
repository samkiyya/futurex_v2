// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/services/auth_servie.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/videoApp/models/section_model.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_lesson_screen.dart';
import 'package:futurex_app/videoApp/services/api_service.dart';
import 'package:futurex_app/widgets/enrollment_dialog.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/commonScreens/chat_bottom_sheet.dart';
import 'package:futurex_app/videoApp/provider/activity_provider.dart';
import 'package:futurex_app/videoApp/models/activity_model.dart';

class OnlineSectionScreen extends StatefulWidget {
  final int courseId;
  final String title;

  const OnlineSectionScreen({
    super.key,
    required this.courseId,
    required this.title,
  });

  @override
  State<OnlineSectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<OnlineSectionScreen> {
  List<Section> sections = [];
  bool isLoading = true;
  bool isLoggedIn = false;
  String userId = '';
  DateTime? sessionStart;
  List<String> selectedSectionTitles = []; // Track selected section titles

  @override
  void initState() {
    super.initState();
    sessionStart = DateTime.now();
    _initialize();
    _fetchSections();
  }

  Future<void> _initialize() async {
    //  await AuthService.addDummyEnrollment38();
    userId = await AuthService.getUserId() ?? '';
    setState(() => isLoggedIn = userId.isNotEmpty);
  }

  Future<void> _fetchSections() async {
    try {
      final data = await ApiService().fetchSections(widget.courseId);
      setState(() {
        sections = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching sections: $e');
    }
  }

  Future<void> _logSessionEnd() async {
    if (!isLoggedIn || sessionStart == null) return;

    // Do NOT send if there are no sections selected
    if (selectedSectionTitles.isEmpty) {
      // Optionally, print or log that nothing will be sent
      print('No sections selected, activity will not be sent to API.');
      return;
    }

    final now = DateTime.now();
    final activityProvider = Provider.of<ActivityProvider>(
      context,
      listen: false,
    );
    final sessionActivity = Activity(
      userId: userId,
      courseId: widget.courseId,
      actions: selectedSectionTitles, // Only send if not empty
      sessionStart: sessionStart!.toIso8601String(),
      sessionEnd: now.toIso8601String(),
      isSynced: false,
    );

    final success = await activityProvider.recordActivity(sessionActivity);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session activity recorded'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logSessionEnd(); // Log session on dispose
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _logSessionEnd(); // Log session on back navigation
    return true;
  }

  void _navigateToLesson(int sectionId, String section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OnlineLesson(sectionId: sectionId, section: section),
      ),
    );
  }

  void _handleSectionTap(int index, int sectionId, String sectionTitle) async {
    if (index != 0 && !isLoggedIn) {
      AuthService.showLoginPrompt(context);
      return;
    }

    bool isEnrolled = await AuthService.isCourseEnrolled(widget.courseId);
    if (!isEnrolled && index != 0) {
      EnrollmentDialog.show(
        context,
        onLaunchTelegram: () => AuthService.launchTelegram(),
      );
    } else {
      // Add the selected section title to the list
      setState(() {
        if (!selectedSectionTitles.contains(sectionTitle)) {
          selectedSectionTitles.add(sectionTitle);
        }
      });
      _navigateToLesson(sectionId, sectionTitle); // Navigate to lesson
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        floatingActionButton: Padding(
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
              height: 28,
              width: 28,
              fit: BoxFit.cover,
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : sections.isNotEmpty
            ? ListView.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return ListTile(
                    leading: const Icon(Icons.book_online, color: Colors.blue),
                    title: Text(section.title),
                    onTap: () =>
                        _handleSectionTap(index, section.id, section.title),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: Colors.blue,
                    ),
                  );
                },
              )
            : const Center(child: Text('No sections found')),
        bottomNavigationBar: BottomNav(
          onTabSelected: (index) async {
            await _logSessionEnd(); // Log session on tab switch
            // Handle tab navigation logic here
          },
          currentSelectedIndex: 1,
        ),
      ),
    );
  }
}
