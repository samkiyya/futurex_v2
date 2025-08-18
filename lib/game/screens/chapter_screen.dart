import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/chapter_provider.dart';

import 'package:futurex_app/widgets/bottomNav.dart';

import 'package:futurex_app/widgets/drawer.dart';
import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:provider/provider.dart';

class ChapterScreen extends StatefulWidget {
  final int subjectId;
  final int level;
  final String subject;
  final int time;
  final int passing;
  final String grade;
  final String cid;

  ChapterScreen({
    required this.subjectId,
    required this.level,
    required this.subject,
    required this.time,
    required this.passing,
    required this.grade,
    required this.cid,
  });

  @override
  _ChapterScreenState createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late ChapterProvider chapterProvider;

  @override
  void initState() {
    super.initState();
    chapterProvider = Provider.of<ChapterProvider>(context, listen: false);
    chapterProvider.fetchChapters(widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chapters -${widget.subject}')),
      drawer: MyDrawer(),
      body: Consumer<ChapterProvider>(
        builder: (context, chapterProvider, _) {
          if (chapterProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (chapterProvider.error != null) {
            return ResponsiveImageTextWidget(
              imageUrl: 'assets/images/nointernet.gif',
              text:
                  'failed to connect to the server please check your connection',
            );
          } else if (chapterProvider.chapters.isEmpty) {
            return ResponsiveImageTextWidget(
              imageUrl: 'assets/images/nodata.gif',
              text: 'No chapters available for this Subject .',
            );
          } else {
            return ListView.builder(
              itemCount: chapterProvider.chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapterProvider.chapters[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Card(
                    elevation: 5,
                    color: Colors.blue,
                    child: ListTile(
                      title: Text(
                        "Unit - " + chapter.unit.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        //Handle onTap, e.g., navigate to detailed question screen
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => QuestionByLevelScreen(
                        //         subjectId: widget.subjectId,
                        //         level: widget.level,
                        //         chapter: chapter.unit.toString(),
                        //         time: widget.time,
                        //         passing: widget.passing,
                        //         grade: widget.grade,
                        //         cid:widget.cid
                        //         subjectName: widget.subjectName,
                        //         ),
                        //   ),
                        // );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}
