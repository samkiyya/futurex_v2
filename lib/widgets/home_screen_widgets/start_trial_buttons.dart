import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/howtoStart.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';

class StartTrialButtons extends StatelessWidget {
  final String userId;
  const StartTrialButtons({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoWithRegistrationScreen()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          child: const Text(
            "አሁን እንዴት ልጀምር?",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OfflineCourseScreen(userId: userId, isOnline: false),
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            "Free Trial",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
