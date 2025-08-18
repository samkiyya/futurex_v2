import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  Future<String> fetchVideoUrl(String action) async {
    final apiUrl ='https://111.21.27.29.futurex.et/video_changer.php?action=$action';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'];
      } else {
        throw Exception('Failed to load video URL');
      }
    } catch (error) {
      throw Exception('Error: please try gain');
    }
  }

  void showVideoPlayerModal(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height *
                0.8, // 80% of screen height
            child: Column(
              children: [
                Expanded(
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId:
                          YoutubePlayer.convertUrlToId(videoUrl) ?? '',
                      flags: const YoutubePlayerFlags(
                        autoPlay: true,
                        mute: false,
                      ),
                    ),
                    showVideoProgressIndicator: true,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigateToVideoPlayer(BuildContext context, String action) async {
    try {
      final videoUrl = action == "game"
          ? "https://www.youtube.com/shorts/6TkXO5vpCCA"
          : await fetchVideoUrl(action);
      showVideoPlayerModal(context, videoUrl);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch video: $error'),
        ),
      );
    }
  }

  void contactViaTelegram() async {
    const telegramUrl = 'https://t.me/futurexhelp';
    if (await canLaunch(telegramUrl)) {
      await launch(telegramUrl);
    } else {
      throw 'Could not launch $telegramUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to use FutureX?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => navigateToVideoPlayer(context, 'howtostart'),
              child: const Text(
                'How to Start ?',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => navigateToVideoPlayer(context, 'howto'),
              child: const Text(
                'How to Use App?',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => navigateToVideoPlayer(context, 'game'),
              child: const Text(
                'How to play question games?',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => navigateToVideoPlayer(context, 'howtopay'),
              child: const Text(
                'How to pay and send receipt ?',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => navigateToVideoPlayer(context, 'howtodownload'),
              child: const Text(
                'How to  download video, notes and questions ?',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => navigateToVideoPlayer(context, 'features'),
              child: const Text(
                'What are FutureX features ?',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => navigateToVideoPlayer(context, 'qanda'),
              child: const Text(
                'Frequently Asked Question and Answers ?',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: contactViaTelegram,
              child: const Text(
                'Contact Us via Telegram',
                style: TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 215, 217, 219), // Blue background color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Call Us +251 91 107 0663',
                style: TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 113, 106, 106)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
