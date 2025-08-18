// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:futurex_app/auth/login_screen.dart';
import 'package:futurex_app/commonScreens/chat_bottom_sheet.dart';
import 'package:futurex_app/constants/styles.dart';
import 'package:futurex_app/commonScreens/developer.dart';
import 'package:futurex_app/forum/screens/testimonials_screen.dart';
import 'package:futurex_app/functions/share_media_functions.dart';
import 'package:futurex_app/game/provider/current_level_provider.dart';
import 'package:futurex_app/game/screens/result_screen.dart';
import 'package:futurex_app/game/screens/top_scorer_screen.dart';
import 'package:futurex_app/game/screens/top_scrorer_subject.dart';
import 'package:futurex_app/game/screens/users_score_by_subject_screen.dart';
import 'package:futurex_app/game/screens/home.dart';
import 'package:futurex_app/commonScreens/help.dart';
import 'package:futurex_app/commonScreens/setting_screen.dart';
import 'package:futurex_app/videoApp/provider/themProvider.dart';
import 'package:futurex_app/videoApp/screens/device_change_request_screen.dart';
import 'package:futurex_app/videoApp/screens/home_screen/home_screen.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_course_screen.dart';
import 'package:futurex_app/order_screens/course_selections_screen.dart';
import 'package:futurex_app/order_screens/enrollment_type_screen.dart';
import 'package:futurex_app/widgets/auth_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String? _selectedGradeRange;
  final List<String> _gradeRanges = ['9-12', '7-8'];
  String userId = "";
  ShareMedia shareMedia = ShareMedia();

  @override
  void initState() {
    super.initState();
    _loadGradeRange();
    _loadUserId();
  }

  Future<void> _loadGradeRange() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGradeRange = prefs.getString('gradeRange') ?? '7-8';
    });
  }

  Future<void> _saveGradeRange(String gradeRange) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gradeRange', gradeRange);
    setState(() {
      _selectedGradeRange = gradeRange;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(userId: userId, isOnline: true),
      ),
    );
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  Future<bool> checkLogin() async {
    return userId.isNotEmpty;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    Widget _drawerItem({
      required IconData icon,
      required String label,
      Color? color,
      required VoidCallback onTap,
    }) {
      return ListTile(
        leading: Icon(
          icon,
          color:
              color ?? (themeProvider.isDarkMode ? Colors.white : Colors.blue),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        onTap: onTap,
      );
    }

    return Drawer(
      width: 280,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: CircleAvatar(
                radius: 26,
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.blue.shade700
                    : Colors.blue.shade100,
                child: Text(
                  "FX",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 2, color: Colors.blue.shade900),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'FutureX',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Select Grade Level',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _gradeRanges.map((range) {
                  bool isSelected = _selectedGradeRange == range;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _saveGradeRange(range),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Grade $range',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode
                          ? Icons.nightlight_round
                          : Icons.wb_sunny,
                    ),
                    title: Text(
                      themeProvider.isDarkMode
                          ? 'Dark Mode ON'
                          : 'Dark Mode OFF',
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                    onTap: () {
                      themeProvider.toggleTheme();
                      Navigator.pop(context);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.videogame_asset,
                    label: 'Game',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GameAppScreen()),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.videogame_asset,
                    label: 'testimony',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TestimonialsScreen()),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.smart_toy,
                    label: 'AI Support',
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => const ChatBottomSheet(),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.shopping_bag,
                    label: 'Buy Course',
                    onTap: () => _requireLoginThenNavigate(
                      context,
                      EnrollmentPlansScreen(),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.emoji_events_outlined,
                    label: 'Top Scorer',
                    onTap: () =>
                        _requireLoginThenNavigate(context, TopScorer()),
                  ),
                  _drawerItem(
                    icon: Icons.view_list_outlined,
                    label: 'Top Scorer by Subject',
                    onTap: () => _requireLoginThenNavigate(
                      context,
                      TopScorerBySubject(),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.bar_chart,
                    label: 'My Game Score',
                    onTap: () => _requireLoginThenNavigate(
                      context,
                      UserRankScoreBySubjectScreen(),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.school,
                    label: 'My Exam Result',
                    onTap: () =>
                        _requireLoginThenNavigate(context, ResultScreen()),
                  ),
                  const Divider(height: 30, thickness: 1),
                  _drawerItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserProfilePage()),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.devices_other,
                    label: 'Change Device',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeviceChangeRequestScreen(),
                      ),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.info_outline_rounded,
                    label: 'Quick Tour',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Help()),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.code,
                    label: 'Developed by',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DeveloperInfoScreen()),
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.telegram,
                    label: 'Share via Telegram',
                    onTap: () {
                      shareMedia.shareAppTelegram(
                        'https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2',
                      );
                    },
                  ),
                  const Divider(height: 30, thickness: 1),
                  FutureBuilder<bool>(
                    future: checkLogin(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final isLoggedIn = snapshot.data!;
                      return _drawerItem(
                        icon: isLoggedIn ? Icons.logout : Icons.login,
                        label: isLoggedIn ? 'Logout' : 'Login',
                        color: Colors.red,
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.clear();
                          if (isLoggedIn) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'You logged out successfully.',
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requireLoginThenNavigate(
    BuildContext context,
    Widget screen,
  ) async {
    if (await checkLogin()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } else {
      AuthUtils.showLoginPrompt(context);
    }
  }
}
