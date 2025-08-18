import 'package:flutter/material.dart';
import 'package:futurex_app/constants/base_urls.dart';
import 'package:futurex_app/exam/providers/subject_provider.dart';
import 'package:futurex_app/exam/screens/exam_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/constants/color.dart';
import 'package:futurex_app/exam/widgets/subject_card.dart';

class Subject extends StatefulWidget {
  const Subject({super.key});

  @override
  State<Subject> createState() => _SubjectState();
}

class _SubjectState extends State<Subject> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubjectProvider>(context, listen: false).fetchSubjects();
    });
  }

  Future<void> _refreshSubjects(BuildContext context) async {
    await Provider.of<SubjectProvider>(
      context,
      listen: false,
    ).fetchSubjects(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final isLoading = subjectProvider.isLoading;
    final errorMessage = subjectProvider.errorMessage;
    final subjects = subjectProvider.subjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Exams'),
        backgroundColor: isDarkMode
            ? AppColors.appBarBackgroundDark
            : Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : () => _refreshSubjects(context),
          ),
        ],
      ),
      body: Builder(
        builder: (BuildContext ctx) {
          if (isLoading && subjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (errorMessage != null && subjects.isEmpty) {
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
                      'Error: $errorMessage',
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
                          : () => _refreshSubjects(context),
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
          } else if (subjects.isEmpty) {
            return Center(
              child: Text(
                'No subjects available.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          } else {
            return Stack(
              children: [
                ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return SubjectCard(
                      id: subject.id,
                      name: subject.name,
                      category: subject.category,
                      year: subject.year,
                      image:
                          BaseUrls.sectionService +
                          "/" +
                          subject.displayImagePath.toString(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamScreen(subjectId: subject.id),
                          ),
                        );
                      },
                    );
                  },
                ),
                if (isLoading && subjects.isNotEmpty)
                  const Opacity(
                    opacity: 0.6,
                    child: ModalBarrier(
                      dismissible: false,
                      color: Colors.black,
                    ),
                  ),
                if (isLoading && subjects.isNotEmpty)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          }
        },
      ),
    );
  }
}
