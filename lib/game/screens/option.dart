import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:futurex_app/game/model/question_by_level_model.dart';

class OptionButton extends StatelessWidget {
  final String option;
  final QuestionByLevel question;
  final String? selectedOption;
  final Function(String) onSelect;
  final bool showAnswer;

  const OptionButton({
    super.key,
    required this.option,
    required this.question,
    required this.selectedOption,
    required this.onSelect,
    required this.showAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = (option == selectedOption);
    final isCorrectAnswer = (option == question.answer);

    Color getBackgroundColor() {
      if (showAnswer) {
        return isCorrectAnswer
            ? Colors.green.withOpacity(0.3)
            : isSelected
            ? Colors.red.withOpacity(0.3)
            : Colors.white;
      } else {
        return Colors.white;
      }
    }

    Color getTextColor() {
      return isSelected ? Colors.black : Colors.black;
    }

    return GestureDetector(
      onTap: () {
        onSelect(option);
      },
      child: Container(
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                if (value != null && value) {
                  onSelect(option);
                }
              },
            ),
            Text(
              '$option.',
              style: TextStyle(
                color: getTextColor(),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: HtmlWidget(getOptionText(option))),
          ],
        ),
      ),
    );
  }

  String getOptionText(String option) {
    switch (option) {
      case 'A':
        return question.optionA;
      case 'B':
        return question.optionB;
      case 'C':
        return question.optionC;
      case 'D':
        return question.optionD;
      default:
        return '';
    }
  }
}
