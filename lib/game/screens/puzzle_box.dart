import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/question_by_level_provider.dart';
import 'package:futurex_app/widgets/auth_widgets.dart';
import 'package:provider/provider.dart';

class PuzzleBox extends StatefulWidget {
  final int level;
  final int userLevel;
  final String chapter;
  final int subjectId;
  final String cid;
  final String grade;
  final String subjectName;
  final int time;
  final int passing;
  final VoidCallback onTap;
  final bool isLoggedIn;
  final VoidCallback onDownloadSuccess;
  final void Function(int level) showDialogCallback;

  const PuzzleBox({
    super.key,
    required this.level,
    required this.userLevel,
    required this.chapter,
    required this.subjectId,
    required this.cid,
    required this.grade,
    required this.subjectName,
    required this.time,
    required this.passing,
    required this.onTap,
    required this.isLoggedIn,
    required this.onDownloadSuccess,
    required this.showDialogCallback,
  });

  @override
  State<PuzzleBox> createState() => _PuzzleBoxState();
}

class _PuzzleBoxState extends State<PuzzleBox> {
  final ValueNotifier<bool> _isDownloading = ValueNotifier(false);

  Future<bool> _hasLocalQuestions(BuildContext context) async {
    final questionProvider = Provider.of<QuestionByLevelProvider>(
      context,
      listen: false,
    );
    final questions = await questionProvider.getLocalQuestions(
      widget.subjectId,
      widget.level,
      widget.chapter,
    );
    return questions.isNotEmpty;
  }

  void _downloadQuestions(BuildContext context) async {
    final questionProvider = Provider.of<QuestionByLevelProvider>(
      context,
      listen: false,
    );
    bool hasLocalQuestions = await _hasLocalQuestions(context);

    if (hasLocalQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questions already downloaded for this level.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _isDownloading.value = true;

    try {
      await questionProvider.fetchQuestions(
        widget.subjectId,
        widget.level,
        widget.chapter,
      );
      if (context.mounted) {
        if (questionProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Please Connect to the internet to donwload questions.",
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Questions downloaded successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          widget.onDownloadSuccess(); // Notify PuzzleScreen
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading questions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (context.mounted) {
        _isDownloading.value = false;
      }
    }
  }

  @override
  void dispose() {
    _isDownloading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUnlocked = widget.level == 1 || widget.level <= widget.userLevel;
    return FutureBuilder<bool>(
      future: _hasLocalQuestions(context),
      builder: (context, snapshot) {
        bool isDownloaded = snapshot.hasData && snapshot.data == true;
        return GestureDetector(
          onTap: isUnlocked
              ? widget.onTap
              : () {
                  if (!widget.isLoggedIn) {
                    AuthUtils.showLoginPrompt(context);
                  } else {
                    widget.showDialogCallback(
                      widget.level - 1,
                    ); // Show AlertDialog
                  }
                },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue, // Uniform color
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isUnlocked)
                          const Icon(Icons.lock, color: Colors.white, size: 16),
                        Text(
                          'Level ${widget.level}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _downloadQuestions(context),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isDownloading,
                      builder: (context, isDownloading, _) {
                        return Tooltip(
                          message: isDownloading
                              ? 'Downloading...'
                              : isDownloaded
                              ? 'Questions downloaded'
                              : 'Download questions',
                          child: isDownloading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isDownloaded
                                      ? Icons.download_done
                                      : Icons.download,
                                  color: isDownloaded
                                      ? Colors.white
                                      : Colors.white,
                                  size: 24,
                                  semanticLabel: isDownloading
                                      ? 'Downloading'
                                      : isDownloaded
                                      ? 'Questions downloaded'
                                      : 'Download questions',
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
