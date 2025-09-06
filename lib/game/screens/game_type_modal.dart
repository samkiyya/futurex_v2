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
      'videoUrl': 'https://www.youtube.com/watch?v=placeholder2',
      'prefKey': 'dontShowGame2',
      'description': 'Learn and play with 10+ new words daily.',
      'icon': Icons.book,
    },
    {
      'label': 'Maths Fun Game',
      'videoUrl': 'https://www.youtube.com/watch?v=placeholder3',
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
      showDialog(
        context: context,
        builder: (context) => const GradeSelectionModal(),
      );
    } else {
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
              // Existing game types
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

              // Uploads list from provider
              Consumer<UploadProvider>(
                builder: (context, prov, _) {
                  if (prov.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (prov.uploads.isEmpty) {
                    if (prov.error != null) {
                      return Text('Error: ${prov.error}');
                    }
                    return const Text('No HTML games available');
                  }
                  return Column(
                    children: prov.uploads.map((u) {
                      final isDownloading = prov.downloading[u.id] == true;
                      final progress = (prov.progress[u.id] ?? 0.0) / 100.0;
                      return Column(
                        children: [
                          _GameTypeCard(
                            label: u.title,
                            description: 'Interactive ${u.title} Exam',
                            icon: Icons.html,
                            onPressed: () async {
                              if (u.onlineUrl != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HtmlViewerScreen(
                                      path: u.onlineUrl!,
                                      title: u.title,
                                      isOnline: true,
                                    ),
                                  ),
                                );
                              } else if (u.localPath != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HtmlViewerScreen(
                                      path: u.localPath!,
                                      title: u.title,
                                      isOnline: false,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'File not available online or offline',
                                    ),
                                  ),
                                );
                              }
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDownloading) ...[
                                  _SmallProgressCircle(progress: progress),
                                ] else if (u.localPath != null) ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HtmlViewerScreen(
                                            path: u.localPath!,
                                            title: u.title,
                                            isOnline: false,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await prov.deleteLocal(u);
                                    },
                                  ),
                                ] else if (u.fileExists == true) ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.download,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      await prov.downloadOne(u);
                                      if (u.localPath != null && mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => HtmlViewerScreen(
                                              path: u.localPath!,
                                              title: u.title,
                                              isOnline: false,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
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
  final Widget? trailing;

  const _GameTypeCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.onPressed,
    this.trailing,
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
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _SmallProgressCircle extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  const _SmallProgressCircle({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).toStringAsFixed(0);
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 4,
            valueColor: const AlwaysStoppedAnimation(Colors.blue),
          ),
          Text(
            pct,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
