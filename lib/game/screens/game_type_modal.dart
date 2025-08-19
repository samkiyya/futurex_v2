import 'package:flutter/material.dart';
import 'package:futurex_app/game/screens/selectGradeScreen.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class GameTypeSelectionScreen extends StatefulWidget {
  const GameTypeSelectionScreen({super.key});

  @override
  State<GameTypeSelectionScreen> createState() =>
      _GameTypeSelectionScreenState();
}

class _GameTypeSelectionScreenState extends State<GameTypeSelectionScreen> {
  // Define game types and their corresponding video URLs
  static const List<Map<String, dynamic>> _games = [
    {
      'label': 'Question Game',
      'videoUrl': 'https://www.youtube.com/shorts/6TkXO5vpCCA',
      'prefKey': 'dontShowGame1',
      'description': 'Test your knowledge with fun quizzes.',
      'icon': Icons.help_outline,
    },
    {
      'label': 'Vocabulary Game',
      'videoUrl':
          'https://www.youtube.com/watch?v=placeholder2', // Replace with actual URL
      'prefKey': 'dontShowGame2',
      'description': 'Learn and play with 10+ new words daily.',
      'icon': Icons.book,
    },
    {
      'label': 'Maths Fun Game',
      'videoUrl':
          'https://www.youtube.com/watch?v=placeholder3', // Replace with actual URL
      'prefKey': 'dontShowGame3',
      'description': 'Challenge your brain with quick math.',
      'icon': Icons.calculate,
    },
  ];

  Future<void> _checkFirstRun(int gameIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? dontShowAgain = prefs.getBool(_games[gameIndex]['prefKey']);

    if (dontShowAgain == null || !dontShowAgain) {
      _showVideoModal(gameIndex);
    } else {
      _navigateToGame(gameIndex);
    }
  }

  void _showVideoModal(int gameIndex) {
    // Extract video ID from URL
    final String? youtubeVideoId = YoutubePlayer.convertUrlToId(
      _games[gameIndex]['videoUrl'],
    );

    if (youtubeVideoId == null) {
      _showErrorDialog('Invalid video URL for ${_games[gameIndex]['label']}');
      return;
    }

    YoutubePlayerController _youtubeController = YoutubePlayerController(
      initialVideoId: youtubeVideoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Disable back button
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
                onPressed: () async {
                  await _dontShowAgain(gameIndex);
                  _youtubeController.pause();
                  Navigator.pop(context);
                  _navigateToGame(gameIndex);
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
                  _navigateToGame(gameIndex);
                },
                child: const Text("Close And Start"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _dontShowAgain(int gameIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_games[gameIndex]['prefKey'], true);
  }

  void _navigateToGame(int gameIndex) {
    if (gameIndex == 0) {
      // Navigate to GradeSelectionModal for Question Game
      showDialog(
        context: context,
        builder: (context) => const GradeSelectionModal(),
      );
    } else {
      // Show "Coming Soon" for Game 2 and Game 3
      _showComingSoon(_games[gameIndex]['label']);
    }
  }

  void _showComingSoon(String gameLabel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Coming Soon"),
        content: Text("$gameLabel is coming soon!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: "Games"),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _games.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _GameTypeCard(
                  label: _games[index]['label'],
                  description: _games[index]['description'],
                  icon: _games[index]['icon'],
                  onPressed: () => _checkFirstRun(index),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentSelectedIndex: 2,
        onTabSelected: (index) {},
      ),
    );
  }
}

class _GameTypeCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  const _GameTypeCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.lightBlue[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
