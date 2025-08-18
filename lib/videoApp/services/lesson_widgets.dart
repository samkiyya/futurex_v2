import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/webview/webview.dart';

import 'package:url_launcher/url_launcher.dart';

class Widgets {
  // PDF Widget
  Widget buildPDFWidget(
    String lessonTitle,
    String pdfUrl,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to a new screen with PDF viewing functionality or open in a browser
        _openPDF(pdfUrl);
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text(
            lessonTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            "PDF Document",
            style: TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
        ),
      ),
    );
  }

  // HTML Widget
  Widget buildHTMLWidget(
    String lessonTitle,
    String htmlUrl,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        // Open Google link in a browser
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(url: htmlUrl, title: lessonTitle),
          ),
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text(
            lessonTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            "HTML Content",
            style: TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.web, color: Colors.blue),
        ),
      ),
    );
  }

  // Google Link Widget
  Widget buildGoogleLinkWidget(
    String lessonTitle,
    String googleLink,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        // Open Google link in a browser
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(url: googleLink, title: lessonTitle),
          ),
        );
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text(
            lessonTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            "Online Exam",
            style: TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.open_in_browser, color: Colors.green),
        ),
      ),
    );
  }

  // Video Widget
  Widget buildVideoWidget(
    String lessonTitle,
    String thumbnail,
    String videoUrl,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to a video player screen or open video in browser
        _playOnlineVideo(lessonTitle, videoUrl, context);
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (videoUrl.isNotEmpty) {
                            _playOnlineVideo(lessonTitle, videoUrl, context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            73,
                            170,
                            25,
                          ),
                          minimumSize: const Size(40, 40),
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.play_arrow),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to open a PDF link
  void _openPDF(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open PDF: $url';
    }
  }

  // Helper function to open an HTML link in a browser

  // Helper function to open any URL (Google link, etc.)

  // Function to play video
  void _playOnlineVideo(String title, String url, BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => OnlineVideoPlayerScreen(
    //       videoUrl: videoUrl,
    //       title: title,
    //     ),
    //   ),
    // );
  }
}

// Example Video Screen for video playback
class VideoScreen extends StatelessWidget {
  final String videoUrl;

  const VideoScreen({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can use a video player widget here or just display the URL
            Text('Playing video from: $videoUrl'),
          ],
        ),
      ),
    );
  }
}
