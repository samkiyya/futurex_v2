// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/constants.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:futurex_app/videoApp/provider/home_course_provider.dart';
import 'package:futurex_app/videoApp/screens/slider.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/drawer.dart';
import 'package:futurex_app/widgets/home_screen_widgets/banner_widget.dart';
import 'package:futurex_app/widgets/home_screen_widgets/grade_course_list.dart';
import 'package:futurex_app/widgets/home_screen_widgets/new_course_list.dart';
import 'package:futurex_app/widgets/home_screen_widgets/start_trial_buttons.dart';
import 'package:futurex_app/widgets/home_screen_widgets/searchCourseWidget.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final bool isOnline;

  const HomeScreen({super.key, required this.userId, required this.isOnline});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userId;
  final TextEditingController _searchController = TextEditingController();
  List<Course> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    userId = widget.userId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeData();
      await _getEnrollments();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? dontShowAgain = prefs.getBool('dontShow3');

      if (dontShowAgain == null || !dontShowAgain) {
        _showVideoModal(context);
      }
    });
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<HomeCourseProvider>(context, listen: false);
    if (widget.isOnline) {
      await provider.fetchCourses();
    } else {
      await provider.getCoursesFromStorage();
    }
    setState(() {
      _filteredCourses = provider.courses;
    });
  }

  void _filterCourses(String query) {
    final provider = Provider.of<HomeCourseProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() => _filteredCourses = provider.courses);
    } else {
      setState(() {
        _filteredCourses = provider.courses
            .where(
              (course) =>
                  course.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  void _dontShowAgain() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dontShow3', true);
  }

  void _showVideoModal(BuildContext context) {
    final String youtubeVideoId = YoutubePlayer.convertUrlToId(
      'https://www.youtube.com/shorts/L6GQAa_NAU4',
    )!;

    YoutubePlayerController _youtubeController = YoutubePlayerController(
      initialVideoId: youtubeVideoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: SizedBox(
              height: 400,
              child: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blue,
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                ),
                onPressed: () {
                  _dontShowAgain();
                  _youtubeController.pause();
                  Navigator.pop(context);
                },
                child: const Text("Never Show Me Again"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                ),
                onPressed: () {
                  _youtubeController.pause();
                  Navigator.pop(context);
                },
                child: const Text("Close And Start"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getEnrollments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString("userId");
    if (storedUserId == null) return;

    try {
      Dio dio = Dio();
      Response response = await dio.get(
        "${Networks().userAPI}/users/enrolled-courses/$storedUserId",
      );
      print("Response from enrollments: ${response.data}");

      if (response.statusCode == 200) {
        var data = response.data;
        if (data["success"] == true) {
          List<dynamic> enrolledCourses = data["enrolled_course_ids"] ?? [];
          await prefs.setStringList(
            "enrolled_courses",
            enrolledCourses.map((e) => e.toString()).toList(),
          );
        }
      }
    } catch (e) {
      print("Error fetching enrollments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GradientAppBar(title: "Home"),
        drawer: const MyDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<HomeCourseProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (provider.courses.isEmpty &&
                  provider.errorMessage.isNotEmpty) {
                return _buildErrorView(context, provider.errorMessage);
              } else if (provider.courses.isEmpty) {
                return const Center(child: Text("No courses available."));
              }

              return ListView(
                children: [
                  const BannerWidget(),
                  StartTrialButtons(userId: userId),
                  SlidingText(
                    text: "${provider.courses.length} በላይ ኮርሶች በ 2999 ብር ብቻ",
                  ),

                  // Search box
                  SearchBarWidget(
                    controller: _searchController,
                    onChanged: _filterCourses,
                  ),

                  NewCourseList(courses: _filteredCourses),
                  CategoryCourseList(courses: _filteredCourses),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNav(
          onTabSelected: (index) {},
          currentSelectedIndex: 0,
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage.isNotEmpty
                ? "please try gain failed to connect to internet"
                : "Failed to load courses. Please try again.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final provider = Provider.of<HomeCourseProvider>(
                context,
                listen: false,
              );
              await provider.fetchCourses();
              setState(() {
                _filteredCourses = provider.courses;
              });
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
