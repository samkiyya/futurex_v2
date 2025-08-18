// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/provider/section_provider.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/section_list.dart';
import 'package:futurex_app/videoApp/services/auth_servie.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/videoApp/provider/activity_provider.dart';
import 'package:futurex_app/videoApp/models/activity_model.dart';

class OfflineSectionScreen extends StatefulWidget {
  final int courseId;
  final String title;

  const OfflineSectionScreen({
    super.key,
    required this.courseId,
    required this.title,
  });

  @override
  _SectionScreenState createState() => _SectionScreenState();
}

class _SectionScreenState extends State<OfflineSectionScreen> {
  bool isLoggedIn = false;
  String userId = '';
  DateTime? sessionStart;
  List<String> selectedSectionTitles = []; // Track selected section titles

  @override
  void initState() {
    super.initState();
    sessionStart = DateTime.now();
    print(
      'OfflineSectionScreen initialized - sessionStart: ${sessionStart?.toIso8601String()}',
    );
    _initializeData();
  }

  void _initializeData() {
    final dataProvider = Provider.of<SectionProvider>(context, listen: false);
    dataProvider
        .fetchData(widget.courseId)
        .then((_) {
          print("After fetchData, sections: ${dataProvider.sections}");
        })
        .catchError((e) {
          print("Error fetching sections: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching sections: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        });
    AuthService.getUserId().then((value) {
      setState(() {
        userId = value ?? '';
        isLoggedIn = userId.isNotEmpty;
      });
    });
  }

  Future<void> _logSessionEnd() async {
    if (isLoggedIn && sessionStart != null) {
      // Do NOT send if there are no sections selected
      if (selectedSectionTitles.isEmpty) {
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
        if (!activityProvider.isOnline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Activity recorded in OFFLINE mode!'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session activity recorded successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  void dispose() {
    _logSessionEnd(); // Log session end when leaving the screen
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _logSessionEnd(); // Log session end on back button
    return true; // Allow navigation
  }

  // Callback to handle section selection
  void _onSectionSelected(String sectionTitle) {
    setState(() {
      if (!selectedSectionTitles.contains(sectionTitle)) {
        selectedSectionTitles.add(sectionTitle);
      }
    });
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
        body: SectionList(
          courseId: widget.courseId,
          userId: userId,
          onSectionSelected: _onSectionSelected, // Pass callback to SectionList
        ),
        bottomNavigationBar: BottomNav(
          onTabSelected: (index) async {
            await _logSessionEnd(); // Log session on tab switch
          },
          currentSelectedIndex: 2,
        ),
      ),
    );
  }
}
