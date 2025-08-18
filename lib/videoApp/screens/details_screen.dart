// ignore_for_file: library_private_types_in_public_api

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/section_model.dart';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late YoutubePlayerController _youtubeController;
  List<Section> sections = [];
  bool isLoading = false;
  String errorMessage = '';
  bool isFullscreen = false;
  String userId = "";
  String youtubeError = '';
  bool hasValidVideo = false;

  @override
  void initState() {
    super.initState();
    fetchCourseSections();
    initializeYoutubePlayer();
    // getUserId().then((id) => setState(() => userId = id ?? ""));
  }

  void initializeYoutubePlayer() {
    String videoUrl = widget.course.video_url.toString();
    String videoId = '';

    print('Raw video_url: ${widget.course.video_url}');
    print('Converted videoUrl: $videoUrl');

    // Check if it's a URL or just an ID
    if (videoUrl.contains('youtube.com') || videoUrl.contains('youtu.be')) {
      videoId = YoutubePlayer.convertUrlToId(videoUrl) ?? '';
      print('Extracted Video ID from URL: $videoId');
    } else {
      videoId = videoUrl; // Use raw value if not a URL
      print('Using raw value as Video ID: $videoId');
    }

    // Validate videoId (YouTube IDs are typically 11 characters)
    if (videoId.isNotEmpty && videoId.length == 11) {
      hasValidVideo = true;
    } else {
      hasValidVideo = false;
      print('Invalid Video ID: $videoId');
    }

    _youtubeController =
        YoutubePlayerController(
          initialVideoId: hasValidVideo
              ? videoId
              : 'dQw4w9WgXcQ', // Fallback to a known working ID
          flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
        )..addListener(() {
          if (_youtubeController.value.hasError) {
            setState(() {
              youtubeError = _youtubeController.value.errorCode.toString();
            });
            print('YouTube Error Code: $youtubeError');
          }
        });
  }

  Future<void> fetchCourseSections() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10), // 10 seconds timeout
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json', // Explicitly set common headers
            'Content-Type': 'application/json',
          },
          // This might help with SSL issues - use only if needed
          validateStatus: (status) => true, // Accept all status codes to debug
        ),
      );

      // Add this to see the full request details
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
        ),
      );

      final response = await dio.get(
        Networks().sectionAPI + '/sections/course/${widget.course.id}',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          setState(() {
            sections = (data)
                .map((section) => Section.fromJson(section))
                .toList();
            isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format: ${response.data}');
        }
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.statusMessage}\nData: ${response.data}',
        );
      }
    } on DioException catch (e) {
      String detailedError = 'DioException: ';
      if (e.response != null) {
        detailedError +=
            'Status: ${e.response?.statusCode}, Data: ${e.response?.data}';
      } else {
        detailedError += e.message ?? 'Unknown error';
      }
      detailedError += '\nRequest URL: ${e.requestOptions.uri}';

      setState(() {
        isLoading = false;
        errorMessage = 'Error loading sections: $detailedError';
      });
      print('Full error: $detailedError'); // For debugging
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Unexpected error: $e';
      });
      print('Unexpected error: $e');
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _youtubeController.dispose();
    super.dispose();
  }

  void toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
      if (isFullscreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void pauseVideo() => _youtubeController.pause();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isFullscreen
          ? null
          : AppBar(
              title: Text(widget.course.title),
              elevation: 14.0,
              shadowColor: Colors.blueGrey.withOpacity(0.5),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28.0),
                ),
              ),
            ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                hasValidVideo
                    ? YoutubePlayer(
                        controller: _youtubeController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.red,
                        onReady: () {
                          print('Player is ready.');
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            'Invalid or missing video ID',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: toggleFullscreen,
                  ),
                ),
              ],
            ),
          ),
          if (youtubeError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'YouTube Error: $youtubeError',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (!isFullscreen)
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        pauseVideo();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfflineCourseScreen(
                              userId: userId,
                              isOnline: true,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Free Trial",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const TabBar(
                      tabs: [
                        Tab(text: 'Description'),
                        Tab(text: 'Sections'),
                        Tab(text: 'Requirements'),
                      ],
                      indicatorColor: Colors.red,
                      labelColor: Colors.blue,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildDescriptionTab(),
                          _buildSectionsTab(),
                          _buildRequirementsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: HtmlWidget(
        widget.course.description.isNotEmpty
            ? widget.course.description
            : 'No description available',
      ),
    );
  }

  Widget _buildSectionsTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }
    if (sections.isEmpty) {
      return const Center(child: Text('No sections available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(
              section.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: widget.course.requirements.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requirements:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...widget.course.requirements.map(
                  (req) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            req,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Text('No requirements specified'),
    );
  }
}
