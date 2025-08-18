import 'package:flutter/material.dart';
import 'package:futurex_app/exam/providers/question_provider.dart';
import 'package:futurex_app/exam/providers/result_provider.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/constants/color.dart';
import 'package:futurex_app/exam/models/question.dart';
import 'package:futurex_app/exam/models/exam.dart';
import 'package:futurex_app/exam/widgets/question_card.dart';
import 'package:futurex_app/exam/widgets/result_popup.dart';

class QuestionScreen extends StatefulWidget {
  final Exam exam;
  final subjectId;

  const QuestionScreen({
    super.key,
    required this.exam,
    required this.subjectId,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuestionProvider>(
        context,
        listen: false,
      ).fetchQuestions(widget.exam.id);
    });
  }

  void _submitExam() async {
    final questionProvider = Provider.of<QuestionProvider>(
      context,
      listen: false,
    );
    if (_hasSubmitted || questionProvider.isLoading) return;

    final currentQuestions = questionProvider.questions;
    final selectedAnswers = questionProvider.selectedAnswers;

    int score = 0;
    List<Question> failedQuestions = [];

    for (final question in currentQuestions) {
      final userSelection = selectedAnswers[question.id];
      if (userSelection == null || userSelection != question.answer) {
        if (question.explanation != null && question.explanation!.isNotEmpty) {
          failedQuestions.add(question);
        }
      } else {
        score++;
      }
    }

    final totalQuestions = currentQuestions.length;
    bool passed = false;
    if (totalQuestions > 0) {
      final percentage = (score / totalQuestions) * 100;
      passed = percentage >= widget.exam.passingScore;
    }

    // Submit result to API
    final resultProvider = ResultProvider();
    await resultProvider.submitResult(
      total: score,
      resultStatus: passed ? 'pass' : 'fail',
      examStatus: 'completed',
      examId: widget.exam.id,
      subjectId:
          widget.subjectId ?? 1, // make sure chapterId maps to subject_id
      context: context, // Replace with real user ID (e.g., from auth provider)
    );

    setState(() {
      _hasSubmitted = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ResultPopup(
          passed: passed,
          score: score,
          totalQuestions: totalQuestions,
          failedQuestions: failedQuestions,
          onShowExplanations: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final questionProvider = Provider.of<QuestionProvider>(context);
    final isLoading = questionProvider.isLoading;
    final errorMessage = questionProvider.errorMessage;
    final questions = questionProvider.questions;

    const double bottomButtonHeight = 80.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        backgroundColor: isDarkMode
            ? AppColors.appBarBackgroundDark
            : AppColors.appBarBackgroundLight,
        actions: const [],
      ),
      body: Builder(
        builder: (context) {
          final currentQuestions = questions;
          if (isLoading && currentQuestions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (errorMessage != null && currentQuestions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading questions: $errorMessage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () =>
                                Provider.of<QuestionProvider>(
                                  context,
                                  listen: false,
                                ).fetchQuestions(
                                  widget.exam.id,
                                  forceRefresh: true,
                                ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (currentQuestions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No questions available for ${widget.exam.title}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ),
            );
          } else {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: bottomButtonHeight),
                  child: ListView.builder(
                    itemCount: currentQuestions.length,
                    itemBuilder: (context, index) {
                      final question = currentQuestions[index];
                      return QuestionCard(
                        key: ValueKey(question.id),
                        question: question,
                        questionNumber: index + 1,
                        hasSubmitted: _hasSubmitted,
                        isAnswerBeforeExam: true,
                      );
                    },
                  ),
                ),
                if (!_hasSubmitted && !isLoading && currentQuestions.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: ElevatedButton(
                        onPressed: _submitExam,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          textStyle: const TextStyle(fontSize: 18),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                        child: const Text('Submit Exam'),
                      ),
                    ),
                  ),
                if (isLoading)
                  const Opacity(
                    opacity: 0.6,
                    child: ModalBarrier(
                      dismissible: false,
                      color: Colors.black,
                    ),
                  ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            );
          }
        },
      ),
    );
  }
}
