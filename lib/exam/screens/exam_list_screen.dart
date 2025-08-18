import 'package:flutter/material.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/exam/providers/exam_provider.dart';
import 'package:futurex_app/exam/screens/question_screen.dart';

class ExamScreen extends StatefulWidget {
  final int? subjectId;

  const ExamScreen({Key? key, this.subjectId}) : super(key: key);

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Fetch exams when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExamProvider>(
        context,
        listen: false,
      ).fetchExams(subjectId: widget.subjectId);
    });

    // Initialize animation controller for card hover effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exams',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<ExamProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            if (provider.exams.isEmpty) {
              return const Center(
                child: Text(
                  'No exams available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: provider.exams.length,
                itemBuilder: (context, index) {
                  final exam = provider.exams[index];
                  return GestureDetector(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionScreen(
                            exam: exam,
                            subjectId: widget.subjectId,
                          ),
                        ),
                      );
                    },
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: exam.examType == 'final'
                                  ? [Colors.blue[50]!, Colors.blue[100]!]
                                  : [Colors.green[50]!, Colors.green[100]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Exam Title
                                Text(
                                  exam.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                // Passing Score
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.score,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Passing Score: ${exam.passingScore}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Exam Type Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: exam.examType == 'final'
                                        ? Colors.blueAccent
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    exam.examType.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}
