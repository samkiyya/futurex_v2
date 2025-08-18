import 'package:flutter/material.dart';
import 'package:futurex_app/forum/screens/discussion_group_screen.dart';
import 'package:futurex_app/forum/screens/testimonials_screen.dart';
import 'package:futurex_app/videoApp/provider/themProvider.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:futurex_app/game/provider/trial_result_provider.dart';

import 'package:futurex_app/widgets/drawer.dart';

import 'package:futurex_app/order_screens/enrollment_type_screen.dart';
import 'package:futurex_app/exam/screens/my_result_screen.dart';
import 'package:futurex_app/videoApp/screens/online_screens/online_course_screen.dart';
import 'package:futurex_app/game/model/trial_result_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Placeholder widgets (replace with actual implementations)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TrialResultProvider trialResultProvider = TrialResultProvider();
  String userId = "";
  String firstName = "Alex";
  String lastName = "";
  String grade = "";
  String phone = "No Phone Number";
  List<TrialResult> selectedResults = [];

  @override
  void initState() {
    super.initState();
    getUserId();
    getUserDetails();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await trialResultProvider.fetchResultData(userId);
    setState(() {});
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  Future<void> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? 'Alex';
      lastName = prefs.getString('last_name') ?? '';
      grade = prefs.getString('grade') ?? '';
      phone = prefs.getString('phone') ?? 'Not logged in';
    });
  }

  void _shareResults() {
    if (selectedResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one result to share."),
        ),
      );
      return;
    }

    double totalScore = 0.0;
    String tableContent = '';

    for (var trialResult in selectedResults) {
      double score = trialResult.score ?? 0.0;
      totalScore += score;
      tableContent +=
          '${trialResult.subjectName.padRight(11)} | Grade ${trialResult.grade.toString().padRight(5)} | Level ${trialResult.level.toString().padRight(3)} | ${score.toString()}/out of 10\n';
    }

    String message =
        "🔥🔥🔥 አሸነፍኩኝ 💪\n\n"
        "በ FutureX ትምህርታዊ Game ተጫወትኩኝና ምርጥ ውጤት አመጣው!\n\n"
        "❇️ ውጤቴ ይኸውና\n\n"
        "Subject         | Grade    | Level     | Score\n"
        "---------------------------------------------\n"
        "$tableContent\n"
        "✅ Total Score = ${totalScore.toStringAsFixed(2)}/10\n\n"
        "https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2";

    Share.share(message, subject: 'ደስ ብሎኛል!');
  }

  void _shareAllResults() {
    double totalScore = 0.0;
    String tableContent = '';

    for (var trialResult in trialResultProvider.trialData) {
      double score = trialResult.score ?? 0.0;
      totalScore += score;
      tableContent +=
          '${trialResult.subjectName.padRight(11)} | Grade ${trialResult.grade.toString().padRight(5)} | Level ${trialResult.level.toString().padRight(3)} | ${score.toString()}/10 \n';
    }

    String message =
        "🔥🔥🔥 አሸነፍኩኝ 💪\n\n"
        "በ FutureX ትምህርታዊ Game ተጫወትኩኝና ምርጥ ውጤት አመጣው!\n\n"
        "❇️ ውጤቴ ይኸውና\n\n"
        "Subject         | Grade    | Level     | Score\n"
        "---------------------------------------------\n"
        "$tableContent\n"
        "✅ Total Score = ${totalScore.toStringAsFixed(2)}/10\n\n"
        "https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2";

    Share.share(message, subject: 'ደስ ብሎኛል!');
  }

  void _navigateToPurchaseCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EnrollmentPlansScreen()),
    );
  }

  void _navigateToMyResults() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResultScreen()),
    );
  }

  void _navigateTo(String route) {
    switch (route) {
      case "forum":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostsScreen()),
        );
        break;
      case "testimony":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TestimonialsScreen()),
        );
        break;
      case "courses":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CourseOnlineScreen(userId: userId, isonline: true),
          ),
        );
        break;
    }
  }

  Widget buildProfileButton({
    required String label,
    required String subLabel,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subLabel, style: TextStyle(color: Colors.blue[600])),
        onTap: onTap,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blueAccent,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.blue[900] : Colors.blue[900],
        foregroundColor: isDarkMode ? Colors.white : null,
        actions: const [Icon(Icons.notifications)],
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.blue[850] : Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black12
                          : Colors.blue.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.15,
                      backgroundImage: const AssetImage(
                        "assets/images/logo1.jpg",
                      ),
                      backgroundColor: isDarkMode
                          ? Colors.blue[700]
                          : Colors.blue[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$firstName $lastName",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "Grade: $grade",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Vertical Buttons
              buildProfileButton(
                label: "Buy New Course",
                subLabel: "Browse our catalog of premium courses",
                onTap: _navigateToPurchaseCourse,
                icon: Icons.shopping_cart,
              ),

              buildProfileButton(
                label: "Student Testimony",
                subLabel: "View Futurex student what they said",
                onTap: () => _navigateTo("testimony"),
                icon: Icons.record_voice_over,
              ),
              buildProfileButton(
                label: "Discussion",
                subLabel: "Discuss with others",
                onTap: () => _navigateTo("forum"),
                icon: Icons.forum,
              ),
              buildProfileButton(
                label: "My Courses",
                subLabel: "Access your enrolled courses",
                onTap: () => _navigateTo("courses"),

                icon: Icons.book,
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _shareAllResults,
                    icon: const Icon(Icons.share),
                    label: const Text(
                      "Share All",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.blue[700]
                          : Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.01,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _shareResults,
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      "Share Selected",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.green[700]
                          : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.01,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Result Table
              Text(
                "My Question Game Results",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.4,
                child: trialResultProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : trialResultProvider.error.isNotEmpty
                    ? Center(
                        child: Text(
                          "Failed to load data.",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                    : _buildResultTable(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentSelectedIndex: 3,
        onTabSelected: (index) {},
      ),
    );
  }

  Widget _buildResultTable() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          themeProvider.isDarkMode ? Colors.blue[800] : Colors.blue[100],
        ),
        dataRowColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? (themeProvider.isDarkMode ? Colors.blue[700] : Colors.blue[50])
              : null;
        }),
        columnSpacing: 20.0,
        columns: [
          DataColumn(
            label: Text(
              "Subject",
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Grade",
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Level",
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              "Score",
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
        rows: trialResultProvider.trialData.map((result) {
          final isSelected = selectedResults.contains(result);
          return DataRow(
            selected: isSelected,
            onSelectChanged: (selected) {
              setState(() {
                if (selected == true) {
                  selectedResults.add(result);
                } else {
                  selectedResults.remove(result);
                }
              });
            },
            cells: [
              DataCell(
                Text(
                  result.subjectName,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ),
              DataCell(
                Text(
                  "Grade ${result.grade}",
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ),
              DataCell(
                Text(
                  "Level ${result.level}",
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ),
              DataCell(
                Text(
                  result.score?.toString() ?? "0",
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
