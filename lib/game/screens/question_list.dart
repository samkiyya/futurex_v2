import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/question_by_level_provider.dart';
import 'package:futurex_app/game/screens/puzzle_screen.dart';
import 'package:futurex_app/game/screens/question_item.dart';
import 'package:futurex_app/widgets/game_app_widgets/result_submit_screen.dart';
import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:provider/provider.dart';

class QuestionList extends StatefulWidget {
  const QuestionList({
    Key? key,
    required this.time,
    required this.level,
    required this.subjectId,
    required this.chapter,
    required this.passing,
    required this.grade,
    required this.cid,
    required this.subjectName,
  }) : super(key: key);

  final int time;
  final int level;
  final int subjectId;
  final String chapter;
  final int passing;
  final String grade;
  final String cid;
  final String subjectName;

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  bool showAnswer = false;
  bool explanationButtonClicked = false;
  final Map<int, String> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchQuestions();
    });
  }

  Future<void> _fetchQuestions() async {
    final quizProvider = Provider.of<QuestionByLevelProvider>(
      context,
      listen: false,
    );
    await quizProvider.fetchQuestions(
      widget.subjectId,
      widget.level,
      widget.chapter,
    );
  }

  void onOptionSelected(int questionId, String selectedOption) {
    setState(() {
      _selectedOptions[questionId] = selectedOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuestionByLevelProvider>(context);
    return Scaffold(
      body: quizProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizProvider.questions.isEmpty && quizProvider.error != null
          ? ResponsiveImageTextWidget2(
              imageUrl: 'assets/images/nointernet.gif',
              text: quizProvider.error!,
              buttonText: 'Retry',
              onButtonPressed: _fetchQuestions,
            )
          : quizProvider.questions.isEmpty
          ? ResponsiveImageTextWidget2(
              imageUrl: 'assets/images/nodata.gif',
              text:
                  "No questions available. Please check your internet connection or try again later.",
              buttonText: 'Retry',
              onButtonPressed: _fetchQuestions,
            )
          : Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {},
                      child: Text(
                        'Grade ${widget.grade} Unit-${widget.chapter}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {},
                      child: Text(
                        'Level ${widget.level}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {},
                      child: Text(
                        determineType(widget.level),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: quizProvider.questions.length,
                    itemBuilder: (ctx, index) {
                      final question = quizProvider.questions[index];
                      return QuestionItem(
                        question: question,
                        showAnswer: showAnswer,
                        index: index + 1,
                        selectedOption: _selectedOptions[question.id],
                        onOptionSelected: onOptionSelected,
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: Container()),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        print('Submit button pressed');

                        if (explanationButtonClicked) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PuzzleScreen(
                                grade: widget.grade,
                                cid: widget.cid,
                                subId: widget.subjectId,
                              ),
                            ),
                          );
                        } else {
                          quizProvider.resetScore();
                          print('Checking answers...');

                          for (var question in quizProvider.questions) {
                            final selectedOption =
                                _selectedOptions[question.id];
                            if (selectedOption != null) {
                              print(
                                'Checking answer for question ID: ${question.id}',
                              );
                              try {
                                final isCorrect = await quizProvider
                                    .checkAnswer(question, selectedOption);
                                if (isCorrect) {
                                  quizProvider.incrementScore();
                                }
                              } catch (e) {
                                print('Error checking answer: $e');
                              }
                            }
                          }

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CongratulationScreen(
                                correct: quizProvider.score,
                                total: quizProvider.questions.length,
                                passing: widget.passing,
                                grade: widget.grade,
                                cid: widget.cid,
                                level: widget.level,
                                subjectId: widget.subjectId,
                                subjectName: widget.subjectName,
                              ),
                            ),
                          );

                          if (result == true) {
                            setState(() {
                              showAnswer = true;
                              explanationButtonClicked = true;
                            });
                          }
                        }
                      },
                      child: Text(
                        explanationButtonClicked ? 'Finish' : 'Submit result',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  String determineType(int level) {
    int cyclePosition = (level - 1) % 3;
    if (cyclePosition == 0) {
      return "Beginner";
    } else if (cyclePosition == 1) {
      return "Intermediate";
    } else {
      return "Master";
    }
  }
}
