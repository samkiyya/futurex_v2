import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/save_userlevel_provider.dart';
import 'package:futurex_app/game/screens/puzzle_screen.dart';
import 'package:futurex_app/widgets/auth_widgets.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/game_app_widgets/submit_result_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class CongratulationScreen extends StatefulWidget {
  const CongratulationScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.passing,
    required this.grade,
    required this.level,
    required this.subjectId,
    required this.cid,
    required this.subjectName,
  });

  final int correct;
  final int total;
  final int passing;
  final String grade;
  final int subjectId;
  final int level;
  final String cid;
  final String subjectName;

  @override
  _CongratulationScreenState createState() => _CongratulationScreenState();
}

class _CongratulationScreenState extends State<CongratulationScreen> {
  late VideoPlayerController _videoPlayerController;
  String userId = "";
  bool _hasExamined = false; // To track if the data has been examined
  bool isLoggedIn = false; // Track if user is logged in

  @override
  void initState() {
    super.initState();
    getUserId();
    _initialize();

    _checkIfExamined();
    String videoAssetPath = determineVideo(widget.correct);
    _videoPlayerController = VideoPlayerController.asset(videoAssetPath)
      ..initialize()
          .then((_) {
            setState(() {});
            _videoPlayerController.play();
          })
          .catchError((error) {
            // Handle video initialization error
            //print('Error initializing video: $error');
          });
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId =
          prefs.getString('userId') ?? ''; // Get user ID from SharedPreferences
      isLoggedIn = userId
          .isNotEmpty; // If userId is not empty, consider user as logged in
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  String determineVideo(int score) {
    switch (score) {
      case 0:
        return 'assets/videos/0.mp4';
      case 1:
        return 'assets/videos/1.mp4';
      case 2:
        return 'assets/videos/2.mp4';
      case 3:
        return 'assets/videos/3.mp4';
      case 4:
        return 'assets/videos/4.mp4';
      case 5:
        return 'assets/videos/5.mp4';
      case 6:
        return 'assets/videos/6.mp4';
      case 7:
        return 'assets/videos/7.mp4';
      case 8:
        return 'assets/videos/8.mp4';
      case 9:
        return 'assets/videos/9.mp4';
      case 10:
        return 'assets/videos/10.mp4';
      default:
        return 'assets/videos/0R.mp4';
    }
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
  }

  Future<void> _checkIfExamined() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGrade = prefs.getString('grade');
    final savedSubjectId = prefs.getInt('subjectId');
    final savedLevel = prefs.getInt('level');
    final savedCid = prefs.getString('cid');

    if (savedGrade == widget.grade &&
        savedSubjectId == widget.subjectId &&
        savedLevel == widget.level &&
        savedCid == widget.cid) {
      setState(() {
        _hasExamined = true;
      });
    }
  }

  void _shareScore() {
    String message =
        "🔥🔥🔥 አሸነፍኩኝ 💪\n\n"
        "በ FutureX ትምህርታዊ Game ተጫወትኩኝና ምርጥ ውጤት አመጣው!\n\n"
        "❇️ ውጤቴ ይኸውና\n\n"
        "Subject:${widget.subjectName}\n"
        "Grade ፡ ${widget.grade}\n"
        "Level ፡ ${widget.level}\n"
        "ውጤት ፡ ${widget.correct}/${widget.total}\n\n"
        "FutureX ላይ Game ተጫውተህ በትምህርት ከኔ ጋር መወዳደር ከፈለክ ከታች ያለውን ሊንክ ነክተህ ስልክህ ላይ አፕሊኬሽኑን ጫነውና ጀምር👇\n"
        "https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2";
    Share.share(message, subject: 'ደስ ብሎኛል!');
  }

  @override
  Widget build(BuildContext context) {
    bool showExplanationButton = widget.correct >= widget.passing;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Loading your Result, please wait...'),
                    ],
                  ),
            const SizedBox(height: 20),
            // Text(
            //   isPassed
            //       ? 'Congratulations! You passed!'
            //       : 'Try Again! Better Luck Next Time!',
            //   style: TextStyle(
            //     fontSize: 24,
            //     color: isPassed ? Colors.green : Colors.red,
            //   ),
            // ),
            const SizedBox(height: 20),
            if (widget.correct < widget.passing)
              ActionButtonWidgets.BuildActionButton(
                context,
                userId,
                widget.level,
                widget.correct,
                widget.subjectId,
                widget.grade,
                widget.cid,
                false,
                "Try Again",
                false,
              ),

            if (widget.correct >= widget.passing)
              !_hasExamined
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            isLoggedIn
                                ? ActionButtonWidgets.BuildActionButton(
                                    context,
                                    userId,
                                    widget.level,
                                    widget.correct,
                                    widget.subjectId,
                                    widget.grade,
                                    widget.cid,
                                    true,
                                    "Submit & Go to Next Level",
                                    _hasExamined,
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue, // Background color
                                    ),
                                    onPressed: () =>
                                        AuthUtils.showLoginPrompt(context),
                                    child: Text("Goto Next Level"),
                                  ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (showExplanationButton)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Background color
                            ),
                            onPressed: () async {
                              final userLevelProvider = UserLevelProvider();
                              await userLevelProvider.postUserLevel(
                                userId,
                                widget.level,
                                widget.correct,
                                widget.subjectId,
                                widget.grade,
                                widget.cid,
                                true,
                              );
                              Navigator.pop(context, true);
                            },
                            child: const Text(
                              'Show Explanations',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Background color
                          ),
                          onPressed: () async {
                            final userLevelProvider = UserLevelProvider();
                            await userLevelProvider.postUserLevel(
                              userId,
                              widget.level,
                              widget.correct,
                              widget.subjectId,
                              widget.grade,
                              widget.cid,
                              true,
                            );
                            _shareScore();
                          },
                          child: const Text(
                            'Share this Score to Friends',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text("You have taken this level before"),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Background color
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PuzzleScreen(
                                  grade: widget.grade,
                                  cid: widget.cid,
                                  subId: widget.subjectId,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Next Level',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Background color
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text(
                            'Show Explanations',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}
