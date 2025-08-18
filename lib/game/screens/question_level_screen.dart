import 'dart:async';

import 'package:flutter/material.dart';

import 'package:futurex_app/game/provider/question_by_level_provider.dart';
import 'package:futurex_app/game/screens/level_screen.dart';
import 'package:futurex_app/game/screens/puzzle_screen.dart';
import 'package:futurex_app/game/screens/question_list.dart';
import 'package:futurex_app/widgets/bottomNav.dart';

import 'package:futurex_app/widgets/drawer.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionByLevelScreen extends StatefulWidget {
  final int subjectId;
  final int level;
  final String chapter;
  final int time;
  final int passing;
  final String grade;
  final String cid;
  final String subjectName;
  QuestionByLevelScreen({
    required this.subjectId,
    required this.level,
    required this.chapter,
    required this.time,
    required this.passing,
    required this.grade,
    required this.cid,
    required this.subjectName,
  });

  @override
  State<QuestionByLevelScreen> createState() => _QuestionByLevelScreenState();
}

class _QuestionByLevelScreenState extends State<QuestionByLevelScreen> {
  late Timer _timer;
  late StreamController<int> _streamController;
  int _secondsRemaining = 0;
  bool _isTimerRunning = true;
  String userId = "";
  @override
  void initState() {
    super.initState();
    getUserId();
    _secondsRemaining = widget.time * 60;
    _streamController = StreamController<int>();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isTimerRunning && _secondsRemaining > 0) {
        _secondsRemaining--;
        _streamController.add(_secondsRemaining);
      } else if (_secondsRemaining <= 0) {
        _timer.cancel();
        _streamController.close();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Time is up!'),
            content: Text('Your time has run out.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PuzzleScreen(
                        grade: widget.grade,
                        cid: widget.cid,
                        subId: widget.subjectId,
                      ),
                    ),
                  );
                },
                child: Text('Try Again'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _streamController.close();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      String twoDigitHours = twoDigits(duration.inHours);
      return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionByLevelProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Grade ' + widget.grade + " ",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserLevelScreen(userId: userId),
                ),
              );
            },
            child: Text(
              widget.subjectName,
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // _isTimerRunning = !_isTimerRunning;
              });
            },
            child: Icon(
              _isTimerRunning ? Icons.timer_off_rounded : Icons.timer,
              color: Colors.red,
            ),
          ),
          SizedBox(width: 6),
          Center(
            child: StreamBuilder<int>(
              stream: _streamController.stream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  Duration duration = Duration(seconds: snapshot.data!);
                  return Text(
                    formatDuration(duration),
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  );
                } else {
                  return CircularProgressIndicator(color: Colors.blue);
                }
              },
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Center(
        child: QuestionList(
          time: widget.time,
          level: widget.level,
          subjectId: widget.subjectId,
          chapter: widget.chapter,
          passing: widget.passing,
          grade: widget.grade,
          cid: widget.cid,
          subjectName: widget.subjectName,
        ),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}
//  question body everything is here
