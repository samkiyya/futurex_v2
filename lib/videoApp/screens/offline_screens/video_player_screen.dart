import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/chat_bottom_sheet.dart';
import 'package:futurex_app/videoApp/provider/themProvider.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/lesson_screen_helper.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:futurex_app/videoApp/services/lesson_service.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class VideoPlayerScreen extends StatefulWidget {
  final String videoTitle;
  final String videoPath;
  final List<dynamic> lessons;
  final bool isOnline;

  const VideoPlayerScreen({
    super.key,
    required this.videoTitle,
    required this.videoPath,
    required this.lessons,
    this.isOnline = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);
  final LessonServiceHelper _lessonService = LessonServiceHelper();
  final Map<String, List<yt.StreamInfo>> _videoStreams = {};
  final Map<String, bool> _isFetchingStreams = {};
  final Map<String, yt.StreamInfo?> _selectedStreams = {};
  final Map<String, String> _selectedFormats = {};
  int _currentlyPlayingIndex = -1;
  bool isLoading = true;
  bool videoError = false;
  String errorMessage = '';
  String selectedSpeed = '1.0';

  @override
  void initState() {
    super.initState();
    initializeVideo();
    _lessonService.initializeFileStatuses(widget.lessons);
    if (widget.isOnline && widget.videoPath.isNotEmpty) {
      final videoId = yt.VideoId(widget.videoPath).value;
      _fetchStreams(widget.videoPath, videoId);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> initializeVideo() async {
    String fileUri = widget.isOnline
        ? widget.videoPath
        : File(widget.videoPath).uri.toString();
    try {
      await player.open(Media(fileUri));
      await player.play();
      setState(() {
        isLoading = false;
        if (widget.isOnline && widget.videoPath.isNotEmpty) {
          _currentlyPlayingIndex = widget.lessons.indexWhere(
            (lesson) =>
                lesson['video_url'] != null &&
                (lesson['video_url'] as String).isNotEmpty &&
                yt.VideoId(lesson['video_url']).value ==
                    yt.VideoId(widget.videoPath).value,
          );
        } else {
          _currentlyPlayingIndex = -1;
        }
      });
    } catch (e) {
      setState(() {
        videoError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
      _showSnackbar("Error playing video: $errorMessage");
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      selectedSpeed = '$speed';
      player.setRate(speed);
    });
  }

  Future<void> _playVideo(String title, String url, int index) async {
    if (url.isEmpty) return;
    final isDownloaded = await _lessonService.isVideoDownloaded(url);

    setState(() {
      player.stop();
      isLoading = true;
    });

    if (widget.isOnline && !isDownloaded) {
      _lessonService.playOnlineVideo(
        context,
        widget.lessons,
        title,
        url,
        widget.videoTitle,
      );
    } else if (isDownloaded) {
      await _lessonService.openVideoFile(
        context,
        widget.lessons,
        title,
        url,
        'media_kit',
        widget.videoTitle,
      );
    } else {
      _showSnackbar("Video not downloaded, please download first");
    }
    setState(() {
      _currentlyPlayingIndex = index;
    });
  }

  Future<void> _fetchStreams(String videoUrl, String videoId) async {
    if (_isFetchingStreams[videoId] == true) return;
    setState(() {
      _isFetchingStreams[videoId] = true;
    });
    final streams = await LessonService.fetchVideoStreams(videoUrl);
    setState(() {
      _videoStreams[videoId] = streams;
      if (streams.isNotEmpty) {
        _selectedStreams[videoId] = streams.last; // Default to lowest quality
        _selectedFormats[videoId] = streams.last is yt.MuxedStreamInfo
            ? streams.last.container.name
            : 'mp4';
      } else {
        _selectedStreams[videoId] = null;
        _selectedFormats[videoId] = 'mp4';
      }
      _isFetchingStreams[videoId] = false;
    });
  }

  Widget _buildSpeedDropdown() {
    final theme = Provider.of<ThemeProvider>(context);
    return DropdownButton<String>(
      value: selectedSpeed,
      onChanged: (newValue) {
        if (newValue != null) {
          _changePlaybackSpeed(double.parse(newValue));
        }
      },
      items: ['0.5', '1.0', '1.25', '1.5', '2.0']
          .map(
            (v) => DropdownMenuItem(
              value: v,
              child: Text(
                'Speed: $v',
                style: TextStyle(
                  color: theme.isDarkMode ? Colors.white : Colors.blue,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildQualityDropdown() {
    final url = widget.videoPath;
    if (!widget.isOnline) return const SizedBox.shrink();
    final videoId = yt.VideoId(url).value;
    if (_isFetchingStreams[videoId] == true) {
      return const Center(child: CircularProgressIndicator());
    }
    final streams = _videoStreams[videoId] ?? [];
    final selected = _selectedStreams[videoId];
    if (streams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Quality:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<yt.StreamInfo>(
          value: selected,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
          ),
          onChanged: (stream) async {
            if (stream == null) return;
            setState(() {
              _selectedStreams[videoId] = stream;
            });
          },
          items: streams.map((s) {
            final format = s.container.name.toUpperCase();
            final label =
                '${s.qualityLabel} ($format, ${(s.size.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB)';
            return DropdownMenuItem(
              value: s,
              child: Text(label, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileButton(List lessons, String title, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    final videoId = yt.VideoId(url).value;
    final isLoading = _isFetchingStreams[videoId] == true;
    final streams = _videoStreams[videoId] ?? [];
    final hasStreams = streams.isNotEmpty;
    final selectedStream = _selectedStreams[videoId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => _fetchStreams(url, videoId),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            "Select Quality",
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (!isLoading && hasStreams)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 250),
              child: DropdownButtonFormField<yt.StreamInfo>(
                isExpanded: true,
                value: selectedStream,
                decoration: InputDecoration(
                  labelText: 'Download Quality',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: streams.map((stream) {
                  final fmt = stream.container.name.toUpperCase();
                  final lbl =
                      '${stream.qualityLabel} ($fmt, ${(stream.size.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB)';
                  return DropdownMenuItem(
                    value: stream,
                    child: Text(lbl, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (stream) {
                  if (stream == null) return;
                  setState(() {
                    _selectedStreams[videoId] = stream;
                    _selectedFormats[videoId] = stream.container.name;
                  });
                },
              ),
            ),
          ),
        _lessonService.buildVideoFileButton(
          context,
          lessons,
          title,
          url,
          lessons.isNotEmpty ? lessons[0]['section_id'].toString() : '0',
          widget.videoTitle,
          onStateUpdate: () => setState(() {}),
          selectedStream: selectedStream,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        await player.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.videoTitle, style: const TextStyle(fontSize: 20)),
          backgroundColor: Colors.blueAccent,
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16, right: 16),
          child: FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const ChatBottomSheet(),
            ),
            backgroundColor: Colors.blue,
            shape: const CircleBorder(),
            child: Image.asset('assets/images/bot.png', height: 28, width: 28),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: videoError
                    ? Center(child: Text('Error: $errorMessage'))
                    : isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Video(
                              controller: controller,
                              controls: AdaptiveVideoControls,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSpeedDropdown(),
                                _buildQualityDropdown(),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_currentlyPlayingIndex != -1)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  "Currently Playing: ${widget.lessons[_currentlyPlayingIndex]['title'] ?? 'No Lesson'}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.isDarkMode ? Colors.white : Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = widget.lessons[index];
                  final videoUrl = lesson['video_url'] as String?;
                  if (videoUrl == null || videoUrl.isEmpty) {
                    return const SizedBox();
                  }
                  return GestureDetector(
                    onTap: () => _playVideo(lesson['title'], videoUrl, index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson['title'] ?? 'Untitled Lesson',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _currentlyPlayingIndex == index
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildFileButton(
                                widget.lessons,
                                lesson['title'],
                                videoUrl,
                              ),
                            ],
                          ),
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
    );
  }
}
