import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:futurex_app/exam/screens/exam_subject_screen.dart';
import 'package:futurex_app/forum/screens/discussion_group_screen.dart';
import 'package:futurex_app/game/screens/game_type_modal.dart';
import 'package:futurex_app/auth/profile_screen.dart';
import 'package:futurex_app/order_screens/category_selection_screen.dart';
import 'package:futurex_app/videoApp/screens/home_screen/home_screen.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';
import 'package:futurex_app/videoApp/screens/onlineOfflineSelection.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_course_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Assuming this is your login screen

class BottomNav extends StatefulWidget {
  final Function(int) onTabSelected;
  final int currentSelectedIndex;

  const BottomNav({
    super.key,
    required this.onTabSelected,
    required this.currentSelectedIndex,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  bool isLoggedIn = false; // Track if user is logged in
  String userId = "";
  @override
  void initState() {
    super.initState();
    _initialize();
    getUserId().then((userId) {
      userId = userId;
    });
  }

  Future<void> _initialize() async {
    await _checkLoginStatus();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? "";
    return prefs.getString('userId') ?? "";
  }

  // Check if the user is logged in
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId =
          prefs.getString('userId') ?? ''; // Get user ID from SharedPreferences
      isLoggedIn = userId
          .isNotEmpty; // If userId is not empty, consider user as logged in
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentSelectedIndex,
      onTap: (index) {
        widget.onTabSelected(index); // Update the state
        _navigateToScreen(context, index); // Handle navigation
      },
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.blue,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed, // Ensures fixed spacing
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.house),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          label: "Course",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.games_outlined),
          label: "Game",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.book),
        //   label: "Notes",
        // ),
      ],
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    Widget? targetPage; // Make nullable

    switch (index) {
      case 0:
        targetPage = HomeScreen(userId: userId, isOnline: true);
        break;
      case 1:
        targetPage = CourseOnlineScreen(userId: userId, isonline: true);

        break;
      case 2:
        _showGradeSelectionModal(context);
        return; // Don't navigate, just show modal

      case 3:
        targetPage = ProfileScreen();
        break;
      default:
        return; // No navigation for undefined indices
    }

    if (targetPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage!),
      );
    }
  }

  void _showGradeSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GameTypeSelectionScreen();
      },
    );
  }

  void _showCourseSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CourseTypeSelectionModal();
      },
    );
  }
}
