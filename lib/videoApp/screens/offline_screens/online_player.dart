import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futurex_app/commonScreens/chat_bottom_sheet.dart';
import 'package:futurex_app/videoApp/provider/themProvider.dart';
import 'package:futurex_app/videoApp/services/lesson_checker_service.dart';
import 'package:futurex_app/videoApp/services/lesson_service.dart';
import 'package:futurex_app/videoApp/services/lesson_widgets.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart'
    as media_kit; // Alias for media_kit_video
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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
  late Player _player;
  late media_kit.VideoController _controller; // Use alias for VideoController
  bool _isFullscreen = false;
  bool _isOverlayVisible = false;
  String _overlayText = "";
  Timer? _longPressTimer;
  double _currentVolume = 0.5; // Default volume level (50%)
  final int _currentlyPlayingIndex =
      -1; // Track the index of currently playing video
  bool _isPaused = false;
  List<StreamInfo> _availableStreams = []; // Available video quality streams
  StreamInfo? _selectedStream; // Currently selected stream
  bool _isLoadingQualities = false;
  bool _isQualitySheetOpen = false;
  static final Map<String, List<StreamInfo>> _streamCache =
      {}; // Local cache for streams

  @override
  void initState() {
    super.initState();
    // Initialize media_kit player
    _player = Player();
    _controller = media_kit.VideoController(_player);

    // Fetch video qualities and load the initial stream
    _fetchVideoQualities();

    // Listen to player state changes
    _player.stream.playing.listen((isPlaying) {
      setState(() {
        _isPaused = !isPlaying;
      });
      _onPlayerStateChange();
    });
  }

  // Fetch available video qualities with caching
  void _fetchVideoQualities() async {
    setState(() {
      _isLoadingQualities = true;
    });
    try {
      final videoId = _extractVideoId(widget.videoUrl);
      if (videoId == null) {
        setState(() {
          _isLoadingQualities = false;
        });
        _showOverlay("Invalid video URL");
        return;
      }
      // Check local cache first
      if (_streamCache.containsKey(videoId)) {
        setState(() {
          _availableStreams = _streamCache[videoId]!;
          _selectedStream = _availableStreams.isNotEmpty
              ? _availableStreams.firstWhere(
                  (stream) => stream is MuxedStreamInfo,
                  orElse: () => _availableStreams.first,
                )
              : null;
          _isLoadingQualities = false;
        });
        if (_selectedStream != null) {
          _loadStream(_selectedStream!);
        }
        return;
      }
      // Fetch streams if not cached
      final streams = await LessonService.fetchVideoStreams(widget.videoUrl);
      setState(() {
        _availableStreams = streams;
        _selectedStream = streams.isNotEmpty
            ? streams.firstWhere(
                (stream) => stream is MuxedStreamInfo,
                orElse: () => streams.first,
              )
            : null;
        _isLoadingQualities = false;
      });
      // Cache the streams locally
      _streamCache[videoId] = streams;
      if (_selectedStream != null) {
        _loadStream(_selectedStream!);
      }
    } catch (e) {
      setState(() {
        _isLoadingQualities = false;
      });
      _showOverlay("Failed to load quality options");
    }
  }

  // Extract video ID from URL
  String? _extractVideoId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
      return uri.queryParameters['v'] ?? uri.pathSegments.last;
    }
    return null;
  }

  // Load a specific stream into the player
  void _loadStream(StreamInfo stream) async {
    final streamUrl = stream.url.toString();
    await _player.open(Media(streamUrl));
    await _player.setVolume(_currentVolume * 100);
  }

  // Change video quality
  void _changeQuality(StreamInfo stream) async {
    final currentPosition = _player.state.position;
    setState(() {
      _selectedStream = stream;
      _isOverlayVisible = true;
      _overlayText = "Quality: ${stream.qualityLabel}";
      _isQualitySheetOpen = false;
    });

    _loadStream(stream);
    await _player.seek(currentPosition);
    await _player.setVolume(_currentVolume * 100);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isOverlayVisible = false;
      });
    });
  }

  // Toggle fullscreen mode
  void _toggleFullscreen() async {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _longPressTimer?.cancel();
    // Restore system UI and orientation when disposing
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  String? _getVideoThumbnail(String videoUrl) {
    final videoId = _extractVideoId(videoUrl);
    return videoId != null ? 'https://img.youtube.com/vi/$videoId/0.jpg' : null;
  }

  void _jumpSeconds(int seconds) async {
    final currentPosition = _player.state.position.inSeconds;
    final duration = _player.state.duration.inSeconds;
    final newPosition = (currentPosition + seconds).clamp(0, duration);
    await _player.seek(Duration(seconds: newPosition));
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

  void _adjustVolume(double delta) async {
    setState(() {
      _currentVolume = (_currentVolume + delta).clamp(0.0, 1.0);
    });
    await _player.setVolume(_currentVolume * 100);
    _showOverlay("Volume: ${(_currentVolume * 100).toInt()}%");
  }

  void _onPlayerStateChange() {
    if (!_player.state.playing && !_isPaused) {
      _isPaused = true;
      final currentPosition = _player.state.position;
      debugPrint('Paused at: $currentPosition');
      _player.seek(currentPosition);
      _player.pause();
    } else if (_player.state.playing) {
      _isPaused = false;
    }
  }

  void _showQualitySelector() {
    setState(() {
      _isQualitySheetOpen = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.7,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900.withOpacity(0.9), Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Text(
                "Select Video Quality",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoadingQualities
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _availableStreams.isEmpty
                    ? const Center(
                        child: Text(
                          "No quality options available",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: _availableStreams.length,
                        itemBuilder: (context, index) {
                          final stream = _availableStreams[index];
                          final isSelected = stream == _selectedStream;
                          return GestureDetector(
                            onTap: () {
                              _changeQuality(stream);
                              Navigator.pop(context);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.videocam,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      stream.qualityLabel,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isQualitySheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: Text(
                widget.title,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Quality Settings',
                  onPressed: _isLoadingQualities || _isQualitySheetOpen
                      ? null
                      : _showQualitySelector,
                ),
                IconButton(
                  icon: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                  tooltip: 'Toggle Fullscreen',
                  onPressed: _toggleFullscreen,
                ),
              ],
            ),
      floatingActionButton: _isFullscreen
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
              child: media_kit.Video(
                controller: _controller,
                controls: media_kit.AdaptiveVideoControls,
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
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (!_isFullscreen)
            Expanded(
              child: Column(
                children: [
                  _currentlyPlayingIndex != -1
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            " ${widget.lessons[_currentlyPlayingIndex]['lesson'] ?? 'No Lesson'}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.blue,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 18,
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
                        if (videoUrl == null) return const Text("");
                        final thumbnailUrl = _getVideoThumbnail(videoUrl);
                        LessonCheckerService.getLessonType(
                          video['lesson_type'] ?? '',
                          video['video_type'] ?? '',
                          video['link'] ?? '',
                          video['attachment_type'],
                        );
                        return GestureDetector(
                          onTap: () {
                            _player.pause();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnlineVideoPlayerScreen(
                                  videoUrl: videoUrl,
                                  title: video['lesson'],
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
                                  )
                                else
                                  const SizedBox(
                                    width: 100,
                                    height: 110,
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video["title"] ?? 'Untitled Lesson',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: _currentlyPlayingIndex == index
                                              ? Colors.red
                                              : themeProvider.isDarkMode
                                              ? Colors.white
                                              : Colors.blue,
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
