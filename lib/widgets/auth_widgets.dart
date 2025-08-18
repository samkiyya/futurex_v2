import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/howtoStart.dart';
import 'package:futurex_app/auth/signUp.dart';
import 'package:futurex_app/auth/login_screen.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static String userId = "";
  // Check if the user is logged in
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    return userId.isNotEmpty; // If userId is not empty, user is logged in
  }

  static void showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Rounded corners
          ),
          titlePadding: EdgeInsets.all(16.0), // Adjust padding for title
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.redAccent, size: 28.0), // Icon
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  "Login Required",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "To access the following FutureX apps  please register, enroll, and login:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.0),
                Divider(color: Colors.grey[300]),
                // List of apps with icons
                Column(
                  children: [
                    _buildAppItem(Icons.games, "Game Question App"),
                    _buildAppItem(
                      Icons.offline_pin_outlined,
                      "Offline Tutorials App",
                    ),
                    _buildAppItem(Icons.wifi, "Online Tutorials App"),
                    _buildAppItem(Icons.book_online_rounded, "አጤሬራ App"),
                    _buildAppItem(Icons.quiz, "Entrance Exam  Question App"),
                  ],
                ),
                Divider(color: Colors.grey[300]),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          actions: <Widget>[
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 13.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: Icon(Icons.login, color: Colors.white),
                  label: Text("Login", style: TextStyle(fontSize: 13)),
                ),
                SizedBox(width: 7),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: Icon(Icons.app_registration, color: Colors.white),
                  label: Text("Register", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Align buttons horizontally
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoWithRegistrationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 13.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: Icon(
                    Icons.free_breakfast_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    "How to Start Now",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OfflineCourseScreen(userId: userId, isOnline: true),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  icon: Icon(
                    Icons.free_breakfast_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Try It with Free",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildAppItem(IconData icon, String appName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 28.0),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              appName,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
