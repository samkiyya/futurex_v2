import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_course_screen.dart';

class CourseTypeSelectionModal extends StatefulWidget {
  const CourseTypeSelectionModal({super.key});

  @override
  State<CourseTypeSelectionModal> createState() =>
      _CourseTypeSelectionModalState();
}

class _CourseTypeSelectionModalState extends State<CourseTypeSelectionModal> {
  String userId = '';

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 12),
            const Text(
              "Choose Course Type",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Select how you want to access your courses.",
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 🚩 Offline comes first
            _CourseTypeButton(
              icon: Icons.download_for_offline,
              label: "Offline Courses",
              gradientColors: [Colors.deepPurple, Colors.deepPurpleAccent],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OfflineCourseScreen(userId: userId, isOnline: false),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _CourseTypeButton(
              icon: Icons.wifi,
              label: "Online Courses",
              gradientColors: [Colors.blueAccent, Colors.lightBlue],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CourseOnlineScreen(userId: userId, isonline: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onPressed;

  const _CourseTypeButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
