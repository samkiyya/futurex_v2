import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futurex_app/utils/url_launcher.dart';
import 'package:futurex_app/widgets/auth_widgets.dart' as auth_widgets;

class AuthService {
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  static Future<bool> isCourseEnrolled(int courseId) async {
    // Changed int to String
    final id = courseId.toString();
    final prefs = await SharedPreferences.getInstance();
    final enrolledCourses = prefs.getStringList('enrolled_courses') ?? [];
    print('Enrolled Courses: ${enrolledCourses}');
    return enrolledCourses.contains(id);
  }

  static Future<void> addDummyEnrollment38(int courseId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> enrolledCourses =
        prefs.getStringList('enrolled_courses') ?? [];
    if (!enrolledCourses.contains('38')) {
      enrolledCourses.add('38');
      await prefs.setStringList('enrolled_courses', enrolledCourses);
      print('Dummy course 38 enrolled!');
    }
  }

  static Future<void> launchTelegram() =>
      UrlLauncher.launchTelegram('futurexhelp');

  static void showLoginPrompt(BuildContext context) =>
      auth_widgets.AuthUtils.showLoginPrompt(context);
}
