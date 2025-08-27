import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/chat_bottom_sheet.dart';
import 'package:futurex_app/videoApp/provider/offline_lesson_provide.dart';
import 'package:futurex_app/videoApp/screens/google_form.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/lesson_screen_helper.dart';
import 'package:futurex_app/videoApp/screens/online_screens/onlinePdf_reader.dart';
import 'package:futurex_app/videoApp/services/donwload_service.dart';
import 'package:futurex_app/videoApp/services/lesson_checker_service.dart';
import 'package:futurex_app/videoApp/services/lesson_service.dart';
import 'package:futurex_app/videoApp/services/lesson_widgets.dart';
import 'package:futurex_app/videoApp/webview/localHtml.dart';
import 'package:futurex_app/videoApp/webview/webview.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

class LessonScreen extends StatefulWidget {
  final int sectionId;
  final String section;
  final bool isOnline;

  const LessonScreen({
    super.key,
    required this.sectionId,
    required this.section,
    required this.isOnline,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Widgets widgets = Widgets();
  final LessonServiceHelper _lessonService = LessonServiceHelper();
  List lessons = [];
  Map<String, List<yt.StreamInfo>> _videoStreams = {};
  Map<String, yt.StreamInfo?> _selectedStreams = {};
  Map<String, String> _selectedFormats = {};
  Map<String, bool> _isFetchingStreams = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    final lessonProvider = Provider.of<OfflineLessonProvider>(
      context,
      listen: false,
    );
    await lessonProvider.fetchLessons(widget.sectionId, "video");
    setState(() {
      lessons = lessonProvider.lessons;
      _lessonService.initializeFileStatuses(lessons);
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
        final defaultStream =
            streams.last; // Lowest quality for faster download
        _selectedStreams[videoId] = defaultStream;
        _selectedFormats[videoId] = defaultStream is yt.MuxedStreamInfo
            ? defaultStream.container.name
            : 'mp4';
      } else {
        _selectedStreams[videoId] = null;
        _selectedFormats[videoId] = 'mp4';
      }
      _isFetchingStreams[videoId] = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = Provider.of<OfflineLessonProvider>(context);
    if (lessonProvider.isLoading) {
      return _buildLoadingScreen();
    }

    if (lessons.isEmpty) {
      return _buildEmptyScreen();
    }

    final videoLessons = lessons
        .where(
          (lesson) =>
              LessonCheckerService.getLessonType(
                lesson['lesson_type'] as String?,
                lesson['video_type'] as String?,
                lesson['link'] as String?,
                lesson['attachment_type'] as String?,
              ) ==
              'video',
        )
        .toList();
    final pdfLessons = lessons
        .where(
          (lesson) =>
              LessonCheckerService.getLessonType(
                lesson['lesson_type'] as String?,
                lesson['video_type'] as String?,
                lesson['link'] as String?,
                lesson['attachment_type'] as String?,
              ) ==
              'pdf',
        )
        .toList();
    final htmlLessons = lessons
        .where(
          (lesson) =>
              LessonCheckerService.getLessonType(
                lesson['lesson_type'] as String?,
                lesson['video_type'] as String?,
                lesson['link'] as String?,
                lesson['attachment_type'] as String?,
              ) ==
              'html',
        )
        .toList();
    final examLessons = lessons
        .where(
          (lesson) =>
              LessonCheckerService.getLessonType(
                lesson['lesson_type'] as String?,
                lesson['video_type'] as String?,
                lesson['link'] as String?,
                lesson['attachment_type'] as String?,
              ) ==
              'exam',
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchLessons),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Videos'),
            Tab(text: 'Notes'),
            Tab(text: 'Questions'),
            // Tab(text: 'Exams'),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLessonList(videoLessons, 'video'),
          _buildLessonList(pdfLessons, 'pdf'),
          _buildLessonList(htmlLessons, 'html'),
          // _buildLessonList(examLessons, 'exam'),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.not_interested, size: 50, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              "No lessons available for offline. Please load once from online.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonScreen(
                      sectionId: widget.sectionId,
                      section: widget.section,
                      isOnline: true,
                    ),
                  ),
                );
              },
              child: const Text(
                'Load Online',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
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
    );
  }

  Widget _buildLessonList(List lessons, String lessonType) {
    if (lessons.isEmpty) {
      return const Center(
        child: Text('No lessons available for this category'),
      );
    }

    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final lessonTitle = lesson['title']?.toString() ?? 'Untitled';
        final videoUrl = lesson['video_url']?.toString() ?? '';
        final link = lesson['link']?.toString() ?? '';
        final pdfUrl = lesson['attachment']?.toString() ?? '';
        final thumbnailUrl = widget.isOnline
            ? _lessonService.getVideoThumbnail(videoUrl) ?? ''
            : '';

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (lessonType == 'video') {
                      if (await _lessonService.isVideoDownloaded(videoUrl)) {
                        if (videoUrl.isNotEmpty) {
                          _lessonService.openVideoFile(
                            context,
                            lessons,
                            lessonTitle,
                            videoUrl,
                            "media_kit",
                            widget.section,
                          );
                        }
                      } else if (widget.isOnline) {
                        if (videoUrl.isNotEmpty) {
                          _lessonService.playOnlineVideo(
                            context,
                            lessons,
                            lessonTitle,
                            videoUrl,
                            widget.section,
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Video not downloaded, please download first",
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    lessonTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildLessonContent(
                  thumbnailUrl,
                  lessons,
                  lessonTitle,
                  lessonType,
                  videoUrl,
                  link,
                  pdfUrl,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonContent(
    String thumbnailUrl,
    List lessons,
    String lessonTitle,
    String lessonType,
    String videoUrl,
    String link,
    String pdfUrl,
  ) {
    switch (lessonType) {
      case 'video':
        return _buildVideoWidget(thumbnailUrl, lessons, lessonTitle, videoUrl);
      case 'pdf':
        return _buildPdfWidget(lessonTitle, pdfUrl);
      case 'html':
        return _buildHtmlWidget(lessonTitle, pdfUrl);
      case 'exam':
        return _buildGoogleLinkWidget(lessonTitle, link);
      default:
        return const Center(child: Text('Unknown lesson type'));
    }
  }

  Widget _buildVideoWidget(
    String thumbnail,
    List lessons,
    String lessonTitle,
    String videoUrl,
  ) {
    final videoId = yt.VideoId(videoUrl).value;
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (thumbnail.isNotEmpty)
            Image.network(
              thumbnail,
              width: 180,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (videoUrl.isNotEmpty) {
                          _lessonService.playOnlineVideo(
                            context,
                            lessons,
                            lessonTitle,
                            videoUrl,
                            widget.section,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Play Online",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _fetchStreams(videoUrl, videoId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Select Quality",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (_isFetchingStreams[videoId] == true)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (_videoStreams[videoId]?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<yt.StreamInfo>(
                    value: _selectedStreams[videoId],
                    decoration: const InputDecoration(
                      labelText: 'Video Quality',
                      border: OutlineInputBorder(),
                    ),
                    items: _videoStreams[videoId]!.map((stream) {
                      final format = stream.container.name.toUpperCase();
                      final quality = stream.qualityLabel;
                      final sizeMB = (stream.size.totalBytes / (1024 * 1024))
                          .toStringAsFixed(1);
                      final label = '$quality ($format, $sizeMB MB)';
                      return DropdownMenuItem<yt.StreamInfo>(
                        value: stream,
                        child: Row(
                          children: [
                            const Icon(Icons.video_settings, size: 20),
                            const SizedBox(width: 8),
                            Text(label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStreams[videoId] = value;
                        _selectedFormats[videoId] = value?.container.name ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                _lessonService.buildVideoFileButton(
                  context,
                  lessons,
                  lessonTitle,
                  videoUrl,
                  widget.sectionId.toString(),
                  widget.section,
                  onStateUpdate: () => setState(() {}),
                  selectedStream: _selectedStreams[videoId],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfWidget(String lessonTitle, String pdfUrl) {
    final fileName = pdfUrl.split('/').last;
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
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
                  child: const Text("Read"),
                ),
                Row(
                  children: [
                    FutureBuilder<bool>(
                      future: FileManager.fileExists(fileName),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final path =
                                      '${await FileManager.getLocalPath()}/$fileName';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LocalHtmlViewer(
                                        localHtmlPath: path,
                                        title: lessonTitle,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('View'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final path =
                                      '${await FileManager.getLocalPath()}/$fileName';
                                  final file = File(path);
                                  if (await file.exists()) {
                                    await file.delete();
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'File deleted successfully',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        } else if (_lessonService.downloadingFiles.contains(
                          fileName,
                        )) {
                          return SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value:
                                      _lessonService.downloadProgress[fileName],
                                  strokeWidth: 6,
                                ),
                                Text(
                                  '${(_lessonService.downloadProgress[fileName]! * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return ElevatedButton(
                            onPressed: () => _lessonService.downloadPDFFile(
                              pdfUrl,
                              fileName,
                              context,
                              onStateUpdate: () => setState(() {}),
                            ),
                            child: const Text('Download'),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlWidget(String lessonTitle, String pdfUrl) {
    final fileName = pdfUrl.split('/').last;
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Home(url: pdfUrl, title: lessonTitle),
                      ),
                    );
                  },
                  child: const Text("Read"),
                ),
                Row(
                  children: [
                    FutureBuilder<bool>(
                      future: FileManager.fileExists(fileName),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final path =
                                      '${await FileManager.getLocalPath()}/$fileName';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LocalHtmlViewer(
                                        localHtmlPath: path,
                                        title: lessonTitle,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('View'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final path =
                                      '${await FileManager.getLocalPath()}/$fileName';
                                  final file = File(path);
                                  if (await file.exists()) {
                                    await file.delete();
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'File deleted successfully',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        } else if (_lessonService.downloadingFiles.contains(
                          fileName,
                        )) {
                          return SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value:
                                      _lessonService.downloadProgress[fileName],
                                  strokeWidth: 6,
                                ),
                                Text(
                                  '${(_lessonService.downloadProgress[fileName]! * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return ElevatedButton(
                            onPressed: () => _lessonService.downloadPDFFile(
                              pdfUrl,
                              fileName,
                              context,
                              onStateUpdate: () => setState(() {}),
                            ),
                            child: const Text('Download'),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleLinkWidget(String lessonTitle, String link) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoogleFormWebView(url: link),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    "Open Exam",
                    style: TextStyle(color: Colors.white),
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
