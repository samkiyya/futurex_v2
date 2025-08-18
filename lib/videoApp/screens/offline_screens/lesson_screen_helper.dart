import 'package:flutter/material.dart';
import 'package:futurex_app/db/video_database.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/online_player.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/video_player_screen.dart';
import 'package:futurex_app/videoApp/services/donwload_service.dart';
import 'package:futurex_app/videoApp/services/lesson_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class LessonServiceHelper {
  final Map<String, double> _downloadProgress = {};
  final Set<String> _downloadingFiles = {};
  final Map<String, Future<bool>> _fileStatuses = {};

  void checkFileStatus(String url) {
    if (url.isEmpty) return;
    final videoId = yt.VideoId(url).value;
    _fileStatuses[videoId] = LessonService.isFileDownloaded(videoId);
  }

  void initializeFileStatuses(List lessons) {
    _fileStatuses.clear();
    for (var lesson in lessons) {
      final videoUrl = lesson['video_url'];
      if (videoUrl != null && videoUrl.isNotEmpty) {
        checkFileStatus(videoUrl);
      }
    }
  }

  Future<void> downloadPDFFile(
    String pdfUrl,
    String fileName,
    BuildContext context, {
    required VoidCallback onStateUpdate,
  }) async {
    final fileId = fileName.trim();
    if (_downloadingFiles.contains(fileId)) return;
    _downloadingFiles.add(fileId);
    _downloadProgress[fileId] = 0.0;
    onStateUpdate();
    try {
      final path = await FileManager().downloadPDFFile(
        url: pdfUrl,
        fileName: fileName,
        onProgress: (progress) {
          _downloadProgress[fileId] = progress;
          onStateUpdate();
        },
      );
      if (path != null) {
        _downloadingFiles.remove(fileId);
        onStateUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File downloaded successfully')),
        );
      }
    } catch (e) {
      _downloadingFiles.remove(fileId);
      onStateUpdate();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download file: $e')));
    }
  }

  String? getVideoThumbnail(String videoUrl) {
    if (videoUrl.isEmpty) return null;
    try {
      final videoId = yt.VideoId(videoUrl).value;
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    } catch (e) {
      return null;
    }
  }

  void playOnlineVideo(
    BuildContext context,
    List lessons,
    String title,
    String url,
    String section,
  ) {
    if (url.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnlineVideoPlayerScreen(
          videoUrl: url,
          title: section,
          lessons: lessons,
        ),
      ),
    );
  }

  Future<void> downloadYoutubeVideo(
    BuildContext context,
    String url,
    String title, {
    required VoidCallback onStateUpdate,
    required yt.StreamInfo? selectedStream,
  }) async {
    if (url.isEmpty || selectedStream == null) return;
    final videoId = yt.VideoId(url).value;
    if (_downloadingFiles.contains(videoId)) return;
    _downloadingFiles.add(videoId);
    _downloadProgress[videoId] = 0.0;
    onStateUpdate();
    try {
      final success = await LessonService.downloadVideoFile(
        videoId: videoId,
        url: url,
        onProgress: (progress) {
          _downloadProgress[videoId] = progress;
          onStateUpdate();
        },
        videoTitle: title,
        selectedStream: selectedStream,
      );
      if (success) {
        _fileStatuses[videoId] = Future.value(true);
        onStateUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download video'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _downloadingFiles.remove(videoId);
      _downloadProgress.remove(videoId);
      onStateUpdate();
    }
  }

  Future<void> openVideoFile(
    BuildContext context,
    List lessons,
    String title,
    String url,
    String player,
    String section,
  ) async {
    final videoId = yt.VideoId(url).value;
    final filePath = await LessonService.getSecurePath(videoId);
    if (filePath != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: filePath,
            videoTitle: title,
            lessons: lessons,
            isOnline: false,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load offline video'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> isVideoDownloaded(String url) async {
    if (url.isEmpty) return false;
    final videoId = yt.VideoId(url).value;
    final futureStatus =
        _fileStatuses[videoId] ?? LessonService.isFileDownloaded(videoId);
    return await futureStatus;
  }

  Widget buildVideoFileButton(
    BuildContext context,
    List lessons,
    String title,
    String url,
    String sectionId,
    String section, {
    required VoidCallback onStateUpdate,
    yt.StreamInfo? selectedStream,
  }) {
    if (url.isEmpty) return const SizedBox.shrink();
    final videoId = yt.VideoId(url).value;

    return FutureBuilder<bool>(
      key: ValueKey(videoId),
      future: _fileStatuses[videoId] ?? LessonService.isFileDownloaded(videoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(),
          );
        }
        final isDownloaded = snapshot.data ?? false;
        final isDownloading = _downloadingFiles.contains(videoId);

        return isDownloading
            ? SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _downloadProgress[videoId] ?? 0.0,
                    ),
                    Text(
                      "${((_downloadProgress[videoId] ?? 0.0) * 100).toInt()}%",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDownloaded
                          ? Colors.green
                          : Colors.blue,
                    ),
                    onPressed: isDownloaded
                        ? () => openVideoFile(
                            context,
                            lessons,
                            title,
                            url,
                            "media_kit",
                            section,
                          )
                        : selectedStream != null
                        ? () => downloadYoutubeVideo(
                            context,
                            url,
                            title,
                            onStateUpdate: onStateUpdate,
                            selectedStream: selectedStream,
                          )
                        : null,
                    child: Text(
                      isDownloaded ? "Play offline" : "Download",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (isDownloaded)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        await LessonService.deleteFile(videoId, context);
                        final dbHelper = DatabaseHelper();
                        await dbHelper.deleteVideo(videoId);
                        _fileStatuses[videoId] = Future.value(false);
                        onStateUpdate();
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              );
      },
    );
  }

  Map<String, double> get downloadProgress => _downloadProgress;
  Set<String> get downloadingFiles => _downloadingFiles;
}
