import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:futurex_app/game/model/question_by_level_model.dart';

import 'option.dart';

class QuestionItem extends StatefulWidget {
  final QuestionByLevel question;
  final bool showAnswer;
  final int index;
  final String? selectedOption;
  final Function(int, String) onOptionSelected;

  const QuestionItem({
    super.key,
    required this.question,
    required this.showAnswer,
    required this.index,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  _QuestionItemState createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedOption;
  }

  @override
  void didUpdateWidget(covariant QuestionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedOption != widget.selectedOption) {
      _selectedOption = widget.selectedOption;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.index}.",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            widget.question.passage.isNotEmpty
                ? HtmlWidget(widget.question.passage)
                : const SizedBox.shrink(),
            widget.question.image.isNotEmpty
                ? Row(
                    children: [
                      Expanded(
                        child: NetworkImageWidget(
                          originalPath: widget.question.image,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            HtmlWidget(widget.question.question),
            const SizedBox(height: 5),
            for (var option in ['A', 'B', 'C', 'D'])
              OptionButton(
                option: option,
                question: widget.question,
                selectedOption: _selectedOption,
                onSelect: (selected) {
                  setState(() {
                    _selectedOption = selected;
                    widget.onOptionSelected(widget.question.id, selected);
                  });
                },
                showAnswer: widget.showAnswer,
              ),
            const SizedBox(height: 15),
            if (widget.showAnswer)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explanation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  HtmlWidget(widget.question.explanation),
                  widget.question.expimage.isNotEmpty
                      ? NetworkImageWidget(
                          originalPath: widget.question.expimage,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class NetworkImageWidget extends StatelessWidget {
  final String originalPath;

  NetworkImageWidget({required this.originalPath});

  String formatImageUrl(String path) {
    // Find the index of "assets/"
    int assetsIndex = path.indexOf("assets/");

    // If "assets/" is found, remove everything before it
    if (assetsIndex != -1) {
      path = path.substring(assetsIndex);
    }

    // Prepend the base URL
    return "https://gamedashboard.futurexapp.net/$path";
  }

  @override
  Widget build(BuildContext context) {
    // Format the image URL
    String imageUrl = formatImageUrl(originalPath);

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return Center(child: Text('Failed to load image'));
          },
    );
  }
}
