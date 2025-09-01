import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/chat_bottom_sheet.dart';
import 'package:futurex_app/videoApp/provider/themProvider.dart';
import 'package:futurex_app/videoApp/services/lesson_checker_service.dart';
import 'package:futurex_app/videoApp/services/lesson_widgets.dart';
import 'package:provider/provider.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';

class OnlineVideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final List<dynamic> lessons;

  const OnlineVideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.lessons,
  });

  @override
  State<OnlineVideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<OnlineVideoPlayerScreen> {
  final Widgets widgets = Widgets();
  late YoutubePlayerController _controller;
  bool _isFullscreen = false;
  bool _isOverlayVisible = false;
  String _overlayText = "";
  Timer? _longPressTimer;
  double _currentVolume = 0.5; // Default volume level (50%)
  final int _currentlyPlayingIndex =
      -1; // Track the index of the currently playing video
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl == null || widget.videoUrl.trim().isEmpty) {
      debugPrint(
        '[OnlinePlayer] widget.videoUrl is null or empty! Value: ${widget.videoUrl}',
      );
    }
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId == null || videoId.isEmpty) {
      debugPrint(
        '[OnlinePlayer] Could not extract videoId from videoUrl: ${widget.videoUrl}',
      );
    }
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        hideControls: false,
        hideThumbnail: true,
        enableCaption: true,
      ),
    );

    _controller.addListener(() {
      if (_controller.value.isFullScreen != _isFullscreen) {
        setState(() {
          _isFullscreen = _controller.value.isFullScreen;
        });
      }
      _onPlayerStateChange();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  String? _getVideoThumbnail(String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    return videoId != null ? 'https://img.youtube.com/vi/$videoId/0.jpg' : null;
  }

  void _jumpSeconds(int seconds) {
    final currentPosition = _controller.value.position.inSeconds;
    final duration = _controller.value.metaData.duration.inSeconds;
    final newPosition = (currentPosition + seconds).clamp(0, duration);
    _controller.seekTo(Duration(seconds: newPosition));
    _showOverlay(seconds > 0 ? "Fast Forward" : "Rewind");
  }

  void _showOverlay(String text) {
    setState(() {
      _overlayText = text;
      _isOverlayVisible = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isOverlayVisible = false;
      });
    });
  }

  void _startContinuousJump(int seconds) {
    _longPressTimer?.cancel();
    _longPressTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _jumpSeconds(seconds);
    });
  }

  void _stopContinuousJump() {
    _longPressTimer?.cancel();
  }

  void _adjustVolume(double delta) {
    setState(() {
      _currentVolume = (_currentVolume + delta).clamp(0.0, 1.0);
    });
    _controller.setVolume((_currentVolume * 100).toInt());
    _showOverlay("Volume: ${(_currentVolume * 100).toInt()}%");
  }

  void _onPlayerStateChange() {
    if (_controller.value.playerState == PlayerState.paused) {
      // Ensure we only handle pause actions when needed
      if (!_isPaused) {
        _isPaused = true;
        final currentPosition = _controller.value.position;
        debugPrint('Paused at: $currentPosition');
        _controller.seekTo(currentPosition); // Ensure video stays at the frame
        _controller.pause();
      }
    } else if (_controller.value.playerState == PlayerState.playing) {
      _isPaused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (widget.videoUrl == null ||
        widget.videoUrl.trim().isEmpty ||
        videoId == null ||
        videoId.isEmpty) {
      return Scaffold(
        appBar: _isFullscreen
            ? null
            : AppBar(
                title: Text(
                  widget.title,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Invalid or missing video URL',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text('videoUrl: \'${widget.videoUrl}\''),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: Text(widget.title, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => const ChatBottomSheet(),
            );
          },
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
          child: Image.asset(
            'assets/images/bot.png',
            fit: BoxFit.cover,
            height: 28,
            width: 28,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: isLandscape
                ? (screenSize.width / screenSize.height)
                : (16 / 9),
            child: GestureDetector(
              onDoubleTapDown: (details) {
                final tapX = details.localPosition.dx;
                final screenWidth = screenSize.width;
                if (tapX < screenWidth / 2) {
                  _jumpSeconds(-15);
                } else {
                  _jumpSeconds(15);
                }
              },
              onLongPressStart: (details) {
                final tapX = details.localPosition.dx;
                final screenWidth = screenSize.width;
                if (tapX < screenWidth / 2) {
                  _startContinuousJump(-5);
                } else {
                  _startContinuousJump(5);
                }
              },
              onLongPressEnd: (_) => _stopContinuousJump(),
              onVerticalDragUpdate: (details) {
                if (details.delta.dy != 0) {
                  _adjustVolume(-details.delta.dy / screenSize.height);
                }
              },
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                aspectRatio: isLandscape
                    ? (screenSize.width / screenSize.height)
                    : (16 / 9),
              ),
            ),
          ),
          if (_isOverlayVisible)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _overlayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _currentlyPlayingIndex != -1
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          " ${widget.lessons[_currentlyPlayingIndex]['lesson'] ?? 'No Lesson'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 98,
                            fontWeight: FontWeight.w100,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.lessons.length,
                    itemBuilder: (context, index) {
                      final video = widget.lessons[index];
                      final videoUrl = video["video_url"];
                      final title =
                          (video['lesson'] ?? video['title'] ?? widget.title)
                              ?.toString() ??
                          'Untitled Lesson';
                      if (videoUrl == null) {
                        debugPrint(
                          '[OnlinePlayer] Lesson at index $index missing video_url. Lesson: $video',
                        );
                        return const ListTile(
                          leading: Icon(Icons.error, color: Colors.red),
                          title: Text('Video unavailable'),
                          subtitle: Text('Missing video URL'),
                        );
                      }
                      if (title == 'Untitled Lesson') {
                        debugPrint(
                          '[OnlinePlayer] Lesson at index $index missing title. Lesson: $video',
                        );
                      }
                      final thumbnailUrl = _getVideoThumbnail(videoUrl);
                      LessonCheckerService.getLessonType(
                        video['lesson_type'] as String?,
                        video['video_type'] as String?,
                        video['link'] as String?,
                        video['attachment_type'] as String?,
                      );
                      return GestureDetector(
                        onTap: () {
                          _controller.pause();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnlineVideoPlayerScreen(
                                videoUrl: videoUrl ?? '',
                                title: title,
                                lessons: widget.lessons,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              if (thumbnailUrl != null)
                                Image.network(
                                  thumbnailUrl,
                                  width: 140,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 140,
                                        height: 110,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                              else
                                const SizedBox(
                                  width: 100,
                                  height: 190,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video["title"] ?? 'Untitled Lesson',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: _currentlyPlayingIndex == index
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
