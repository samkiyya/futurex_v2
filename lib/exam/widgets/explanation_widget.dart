import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:futurex_app/exam/models/question.dart';

class ExplanationWidget extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;

  const ExplanationWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
  });

  Widget _buildImage(String? url, String imageId) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<String?>(
      future: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final securePath = snapshot.data;
        if (securePath != null && File(securePath).existsSync()) {
          return Image.file(
            File(securePath),
            errorBuilder: (context, error, stackTrace) {
              debugPrint("Error loading local image $imageId: $error");
              return Image.network(
                url,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("Error loading network image $imageId: $error");
                  return const Text('Failed to load explanation image');
                },
              );
            },
          );
        }

        return Image.network(
          url,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Error loading network image $imageId: $error");
            return const Text('Failed to load explanation image');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Explanation",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Correct Answer: ${question.answer}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            if (question.explanation != null &&
                question.explanation!.isNotEmpty)
              HtmlWidget(
                question.explanation!,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            const SizedBox(height: 10),
            if (question.explanationImageUrl != null &&
                question.explanationImageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildImage(
                  question.explanationImageUrl,
                  'expimage${question.id}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
