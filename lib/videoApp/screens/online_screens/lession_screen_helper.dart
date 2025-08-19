import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/provider/themProvider.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/online_player.dart';
import 'package:futurex_app/videoApp/screens/online_screens/onlinePdf_reader.dart';
import 'package:futurex_app/videoApp/services/lesson_checker_service.dart';
import 'package:futurex_app/videoApp/services/lesson_service.dart';
import 'package:futurex_app/videoApp/services/lesson_widgets.dart';
import 'package:futurex_app/videoApp/webview/htmlViewer.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/lessons_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/videoApp/provider/offline_lesson_provide.dart';

// Controller to handle business logic for OnlineLesson screen
class OnlineLessonController {
  final Widgets widgets = Widgets(); // Instance of Widgets for utility methods
  final Map<String, Future<bool>> _fileStatuses = {};
  List<Map<String, String>> videos = [];

  // Initialize the controller with sectionId and context
  void initialize(int sectionId, BuildContext context) {
    // Fetch lessons when the screen loads
    Future.microtask(() {
      final lessonProvider = Provider.of<OfflineLessonProvider>(
        context,
        listen: false,
      );
      lessonProvider.fetchLessons(sectionId, "video");
    });
    _initializeFileStatuses();
  }

  // Initialize file statuses for videos
  void _initializeFileStatuses() {
    for (var lesson in videos) {
      final videoUrl = lesson['video_url'];
      if (videoUrl != null && videoUrl.isNotEmpty) {
        _checkFileStatus(videoUrl);
      }
    }
  }

  // Filter lessons by type
  List<dynamic> filterLessonsByType(List lessons, String lessonType) {
    return lessons.where((lesson) {
      final type = getLessonType(
        lesson['lesson_type'],
        lesson['video_url'],
        lesson['link'],
        lesson['attachment_type'],
      );
      return type == lessonType;
    }).toList();
  }

  // Get YouTube video thumbnail
  String getVideoThumbnail(String videoUrl) {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    return videoId != null ? 'https://img.youtube.com/vi/$videoId/0.jpg' : '';
  }

  // Check file download status
  void _checkFileStatus(String url) {
    final fileName = url.split('/').last;
    final videoId = fileName.split('?').last;
    _fileStatuses[videoId] = LessonService.isFileDownloaded(videoId);
  }

  // Navigate to offline lessons screen
  void navigateToOfflineLessons(
    BuildContext context,
    int sectionId,
    String section,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          sectionId: sectionId,
          section: section,
          isOnline: false,
        ),
      ),
    );
  }

  // Get lesson type using LessonCheckerService
  String getLessonType(
    String? lessonType,
    String? videoType,
    String? link,
    String? attachmentType,
  ) {
    return LessonCheckerService.getLessonType(
      lessonType,
      videoType,
      link,
      attachmentType,
    );
  }

  // Build lesson content based on lesson type
  Widget buildLessonContent({
    required List lessons,
    required String lessonTitle,
    required String thumbnail,
    required String lessonType,
    required String videoUrl,
    required String link,
    required String pdfUrl,
    required BuildContext context,
  }) {
    if (lessonType == 'video') {
      return _buildVideoWidget(
        lessons,
        lessonTitle,
        thumbnail,
        videoUrl,
        context,
      );
    } else if (lessonType == 'pdf') {
      return _buildPdfWidget(lessonTitle, pdfUrl, context);
    } else if (lessonType == 'html') {
      return _buildHtmlWidget(lessonTitle, pdfUrl, context);
    } else if (lessonType == '3dmodel') {
      return _buildHtmlWidget(lessonTitle, pdfUrl, context);
    } else {
      return const Center(child: Text('Unknown lesson type'));
    }
  }

  // Build video widget
  Widget _buildVideoWidget(
    List lessons,
    String lessonTitle,
    String thumbnail,
    String videoUrl,
    BuildContext context,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () {
        _playOnlineVideo(lessons, lessonTitle, videoUrl, context);
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            thumbnail.isNotEmpty
                ? Image.network(
                    thumbnail,
                    width: 180,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(
                    width: 100,
                    height: 120,
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lessonTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Play online video
  void _playOnlineVideo(
    List lessons,
    String lessonTitle,
    String videoUrl,
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnlineVideoPlayerScreen(
          videoUrl: videoUrl,
          title: lessonTitle,
          lessons: lessons,
        ),
      ),
    );
  }

  // Build PDF widget
  Widget _buildPdfWidget(
    String lessonTitle,
    String pdfUrl,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OnlinePdfViewer(title: lessonTitle, pdfUrl: pdfUrl),
          ),
        );
      },
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color.fromARGB(255, 245, 250, 255),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.picture_as_pdf,
                color: Color.fromARGB(255, 200, 50, 50),
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lessonTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 34, 34, 34),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OnlinePdfViewer(title: lessonTitle, pdfUrl: pdfUrl),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 6),
                      Text("Read", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHtmlWidget(
    String lessonTitle,
    String pdfUrl,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HtmlViewer(url: pdfUrl, title: lessonTitle),
          ),
        );
      },
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lessonTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 30, 30, 30),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (pdfUrl.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HtmlViewer(url: pdfUrl, title: lessonTitle),
                      ),
                    );
                  }
                },

                label: const Text("Open"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
