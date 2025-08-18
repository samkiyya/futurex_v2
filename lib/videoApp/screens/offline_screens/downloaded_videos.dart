import 'package:flutter/material.dart';
import 'package:futurex_app/db/video_database.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/video_player_screen.dart';

import 'package:futurex_app/videoApp/services/lesson_service.dart';
import 'package:futurex_app/widgets/bottomNav.dart';

class DownloadedVideosPage extends StatefulWidget {
  const DownloadedVideosPage({Key? key}) : super(key: key);

  @override
  State<DownloadedVideosPage> createState() => _DownloadedVideosPageState();
}

class _DownloadedVideosPageState extends State<DownloadedVideosPage> {
  Future<List<Map<String, dynamic>>>? _videos; // Use Future? for initialization
  List<Map<String, dynamic>> _allVideos = []; // Store all videos
  List<Map<String, dynamic>> _filteredVideos = []; // Store filtered videos
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  // Load videos function
  void _loadVideos() {
    final dbHelper = DatabaseHelper();
    _videos = dbHelper.fetchVideos(); // Directly assign the Future here
  }

  Future<void> _openFile(String videoID, String title) async {
    final filePath = await LessonService.getSecurePath(videoID);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          videoTitle: title,
          videoPath: filePath!,
          lessons: [],
        ),
      ),
    );
  }

  String extractMinutesAndSeconds(String timeString) {
    // Use regular expression to extract minutes and seconds
    RegExp regExp = RegExp(r'(\d{2}):(\d{2})\.\d+');
    Match? match = regExp.firstMatch(timeString);

    if (match != null) {
      String minutes = match.group(1)!; // Extract minutes
      String seconds = match.group(2)!; // Extract seconds
      return '$minutes:$seconds';
    } else {
      return 'Invalid format'; // Handle case if the format doesn't match
    }
  }

  // Filter videos based on the search query
  void _filterVideos() {
    setState(() {
      String query = _searchController.text.trim().toLowerCase();
      _filteredVideos = query.isEmpty
          ? _allVideos
          : _allVideos
                .where((video) => video['title'].toLowerCase().contains(query))
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloaded Videos"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search videos by title...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  _filterVideos(); // Update filtered videos whenever the text changes
                },
              ),
            ),
            SizedBox(height: 16),
            // Video list
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _videos, // Using _videos here directly
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No videos downloaded."));
                  }

                  // Get the videos from snapshot
                  final videos = snapshot.data!;

                  // Update _allVideos and _filteredVideos only once data is fetched
                  if (_allVideos.isEmpty) {
                    _allVideos = videos;
                    _filteredVideos = videos; // Initially show all videos
                  }

                  return ListView.builder(
                    itemCount: _filteredVideos.length,
                    itemBuilder: (context, index) {
                      final video = _filteredVideos[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Title of the video
                            ListTile(
                              title: Text(
                                video['title'],
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                "Duration: ${extractMinutesAndSeconds(video['duration'])}",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // Buttons below each tile
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Play button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue, // Background color
                                    ),
                                    onPressed: () {
                                      _openFile(video['id'], video['title']);
                                    },
                                    child: Text(
                                      "Play",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red, // Background color
                                    ),
                                    onPressed: () async {
                                      await LessonService.deleteFile(
                                        video['id'],
                                        context,
                                      );
                                      final dbHelper = DatabaseHelper();
                                      await dbHelper.deleteVideo(video['id']);
                                      // Update the _videos Future and reload the list
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DownloadedVideosPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 2,
      ),
    );
  }
}
