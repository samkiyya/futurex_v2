// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class VideoWithRegistrationScreen extends StatefulWidget {
  const VideoWithRegistrationScreen({super.key});

  @override
  _VideoWithRegistrationScreenState createState() =>
      _VideoWithRegistrationScreenState();
}

class _VideoWithRegistrationScreenState
    extends State<VideoWithRegistrationScreen> {
  YoutubePlayerController? _controller; //
  final String telegramUsername = 'futurexhelp';
  int _selectedIndex = 0;

  // Tab content for each tab
  final List<Widget> _tabContents = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'እንዴት ልጀምር?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text('Step 1. መመዝገብ - Register የሚለውን ምልክት በመንካት ፎርሙን ሞልቶ መመዝገብ'),
        SizedBox(height: 10),
        Text(
          'Step 2. መክፈል - አሁኑኑ ለመጀመር በመረጡት የክፍያ አማራጭ ገንዘቡን በኢትዮጵያ ንግድ ባንክ የባንክ ቁጥር 1000530747445 ገቢ ማድረግ። በቀላሉ ማለትም በሞባይል *889# ወይም በ CBE አፕሊኬሽን ወይም በ Tele-Birr ወዲያው መክፈል ይችላሉ።',
        ),
        SizedBox(height: 10),
        Text(
          'Step 3. የከፈሉብትን አሳይተው መጀመር - 0911 07 06 63 በሚለው ስልክ ቁጥር በቴሌግራም የከፈሉበትን Screenshot ፎቶ ወይም የደረሰኝ ፎቶ መላክ። በተጨማሪም የእርሶን ስምና ስልክ ቁጥር መላክ አይርሱ።',
        ),
        SizedBox(height: 10),
        Text(
          'ልክ ይሄን ሲያደርጉ ወዲያው አባል እንደሆኑ እና ኮርሶቹን መጀመር እንደሚችሉ ወዲያው ቴሌግራም ላይ መልዕክት ይደርሶታል። Login ብለው ገብተው የፈለጉትን ኮርስ እየከፈቱ ማጥናት ይችላሉ ማለት ነው። ለማንኛውም ጥያቄና ማብራሪያ በ 0911 07 06 63 ይደውሉ።',
        ),
      ],
    ),
    Column(
      children: [
        Text("የክፍያ አማራጮች በሚገባቸው ሰነዶች ላይ ማብራሪያ ያግኛሉ።"),
        SizedBox(height: 10),
        Text(
          "1. አንድ ኮርስ መርጦ መግዛት",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text("• 499 ብር ከፍለው የመረጡትን 1 ኮርስ ያገኛሉ"),
        Text("• ያንን ኮርስ ብቻ Download ማድረግና ያለ ኢንተርኔት ማጥናት ይችላሉ"),
        Text("• ሌላ ኮርስ ማግኘት ሲፈልጉ ተጨማሪ 499 ይከፍላሉ"),
        SizedBox(height: 10),
        Text(
          "2. በክፍል ደረጃችን ያሉ ኮርሶችን ማግኘት",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "• በመረጡት የክፍል ደረጃ ያሉ ትምህርቶችን ያገኛሉ (9ኛ ክፍል ከሆኑ የ 9ኛ ክፍል ት/ቶችን ያገኛሉ፤ 10ኛ ከሆኑ የ10ኛ ክፍል ት/ቶችን ያገኛሉ...ወዘተ)",
        ),
        Text("• በክፍል ደረጃዎ ያሉ ት/ቶች ላይ የወጡ Shortnotes (አጤሬራ) ያገኛሉ"),
        Text("• ኮርሶቹን Download ማድረግና ያለ ኢንተርኔት ማጥናት ይችላሉ"),
        Text("• የሌላ ክፍል ደረጃ ኮርስ ሲፈልጉ ተጨማሪ ይከፍላሉ"),
        Text("• ዋጋ: 1999 ብር"),
        SizedBox(height: 10),
        Text("3. ሁሉንም ኮርስ ማግኘት", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text("• 2999 ብር ከፍለው ሁሉንም ኮርስ ያገኛሉ"),
        Text(
          "• ሁሉንም ኮርስ ማለትም ከ [totalRows] በላይ ኮርሶች ያገኛሉ (አሁን ያሉትንም ወደፊት የሚለቀቁትንም ጨምሮ)",
        ),
        Text("• የሁሉንም ትምህርቶች Shortnote (አጤሬራ) ያገኛሉ"),
        Text("• ሁሉንም ኮርስ Download ማድረግና ያለ ኢንተርኔት ማጥናት ይችላሉ"),
        Text("• ከዚህ በኋላ ደግመው አይከፍሉም"),
        Text("• ዋጋ: 2999 ብር"),
        SizedBox(height: 10),
        Text(
          "ማስታወሻ፡ በየጊዜው የዋጋ ጭማሪ ስለሚደረግ ቶሎ ከፍለው ይጀምሩ።",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'የተማሪዎች ተደጋጋሚ ጥያቄ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          '1.የምታስጠኑን በየትኛው ካሪኩለም ነው?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'መልስ: በሁለቱም። ከ 9-12 ያሉት ሁሉም ኮርሶች በአዲሱ ካሪኩለም መሰረት አሉ። ለ 12 ኛ ክፍል ማትሪክ ተፈታኞች ደግሞ የ 9 እና የ 10 ክፍል ትምህርቶችን በድሮ ካሪኩለም ሁሉንም በቅርቡ ሰርተን እንጨርሳለን።',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        Text(
          '2. ክፍያውን ሌላ ሰው ቢከፍልልኝስ?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'መልስ: ይቻላል፤ ቤተሰብ፣ ዘመድ ወይ ማንኛውም ሰው ሊከፍልልህ ይችላል ዋናው የከፈልክበትን ማሳየትህ ነው',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        Text(
          '3. ለሁሉም ኮርስ ከከፈልኩኝ በኋላ አዲስ ኮርስ ሲለቀቅ ክፈል እባላለው?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'መልስ: 2999ብር ከፍሎ አባል የሆነ ሰው ድጋሚ ምንም ገንዘብ አይከፍልም፤ አሁን ያሉትንም ወደፊት የሚለቀቁትንም ኮርሶች በሙሉ ያገኛል።',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        Text(
          '4. አፕሊኬሽኑን ስጠቀም ቢያስቸግረኝ ምን ላርግ?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'መልስ: 0911 07 06 63 ላይ መደወል ወይም በቴሌግራም @futurexhelp ላይ ያጋጠመህን በመናገር ወዲያው ችግሩ ይፈታል።',
          style: TextStyle(fontSize: 16),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadVideoUrl();
  }

  // Method to load the video URL asynchronously
  Future<void> _loadVideoUrl() async {
    final response = await http.get(
      Uri.parse(
        'https://111.21.27.29.futurex.et/video_changer.php?action=howtostart',
      ),
    );

    if (response.statusCode == 200) {
      // Parse the response body and extract the URL
      final data = json.decode(response.body);
      final String youtubeVideoUrl = data['url'];

      // Extract the YouTube video ID from the URL
      final String youtubeVideoId = YoutubePlayer.convertUrlToId(
        youtubeVideoUrl,
      )!;

      // Create the YouTube Player Controller with the fetched video ID
      _controller = YoutubePlayerController(
        initialVideoId: youtubeVideoId,
        flags: YoutubePlayerFlags(autoPlay: true, mute: false),
      );

      // Trigger the rebuild to update the UI with the new video
      setState(() {});
    } else {
      // Handle the error case if the API request fails
      return;
    }
  }

  // Function to open Telegram directly to a user message
  Future<void> _launchTelegram() async {
    final String telegramAppUrl = 'tg://resolve?domain=$telegramUsername';
    final String telegramWebUrl = 'https://t.me/$telegramUsername';

    if (await canLaunch(telegramAppUrl)) {
      await launch(telegramAppUrl);
    } else if (await canLaunch(telegramWebUrl)) {
      await launch(telegramWebUrl);
    } else {
      throw 'Could not launch Telegram.';
    }
  }

  @override
  @override
  void dispose() {
    _controller?.dispose(); // Dispose only if the controller is initialized
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "How to Start",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // YouTube Player
          _controller == null
              ? Center(child: CircularProgressIndicator())
              : YoutubePlayer(
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                ),
          const SizedBox(height: 10),
          // Tabs for different contents
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _onTabSelected(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex == 0
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: const Text(
                  'እንዴት ልጀምር?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => _onTabSelected(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex == 1
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: const Text(
                  'የክፍያ አማራጮች',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () => _onTabSelected(2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedIndex == 2
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: const Text('FAQ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Content of the selected tab
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(child: _tabContents[_selectedIndex]),
            ),
          ),
          // Telegram link to open Telegram
          ElevatedButton(
            onPressed: _launchTelegram,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(8.0),
              backgroundColor: Colors.blue, // Text color
            ),
            child: const Text(
              'የከፈሉበትን ደረሰኝ ይሄንን ተጭነው ይላኩ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
