import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:futurex_app/game/provider/upload_provider.dart';
import 'package:futurex_app/game/screens/selectGradeScreen.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/drawer.dart';

import 'package:futurex_app/game/screens/html_viewer_screen.dart';

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
      body: ChangeNotifierProvider(
        create: (_) => UploadProvider()..load(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // existing game types
              ...List.generate(_games.length, (index) {
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
              }),

              // HTML Games header
              const SizedBox(height: 8),
              const Text(
                'HTML Games',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // uploads list from provider
              Consumer<UploadProvider>(
                builder: (context, prov, _) {
                  if (prov.loading)
                    return const Center(child: CircularProgressIndicator());
                  if (prov.error != null) return Text('Error: ${prov.error}');
                  if (prov.uploads.isEmpty)
                    return const Text('No HTML games available');

                  return Column(
                    children: prov.uploads.map((u) {
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.html,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                            title: Text(u.title),
                            subtitle: Text(u.htmlFilePath.split('/').last),
                            trailing: prov.downloading[u.id] == true
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (u.localPath != null)
                                        IconButton(
                                          icon: const Icon(Icons.open_in_new),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    HtmlViewerScreen(
                                                      path: u.localPath!,
                                                      title: u.title,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () async {
                                          print(
                                            '[UI] download button pressed for id=${u.id}',
                                          );
                                          await prov.downloadOne(u);
                                          // after download open automatically
                                          if (u.localPath != null && mounted) {
                                            print(
                                              '[UI] opening downloaded file ${u.localPath}',
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    HtmlViewerScreen(
                                                      path: u.localPath!,
                                                      title: u.title,
                                                    ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
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
