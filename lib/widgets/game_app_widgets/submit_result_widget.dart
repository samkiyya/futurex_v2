import 'package:flutter/material.dart';
import 'package:futurex_app/constants/styles.dart';
import 'package:futurex_app/game/provider/save_userlevel_provider.dart';
import 'package:futurex_app/game/screens/puzzle_screen.dart';
import 'package:futurex_app/widgets/auth_widgets.dart';
import 'package:futurex_app/widgets/custum_modal_widget.dart';
import 'package:provider/provider.dart';

class ActionButtonWidgets {
  static Widget BuildActionButton(
    BuildContext context,
    String userid,
    int level,
    int correct,
    int subjectId,
    String grade,
    String cid,
    bool status,
    String text,
    bool taken,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () async {
        if (userid.isNotEmpty) {
          final userLevelProvider = Provider.of<UserLevelProvider>(
            context,
            listen: false,
          );

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const AlertDialog(content: CircularProgressIndicator()),
          );

          await userLevelProvider.postUserLevel(
            userid,
            level,
            correct,
            subjectId,
            grade,
            cid,
            status,
          );

          Navigator.of(context).pop();

          if (userLevelProvider.error != null) {
            showPersistentDialog(
              context,
              'Submission Error',
              userLevelProvider.error!,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PuzzleScreen(grade: grade, cid: cid, subId: subjectId),
                  ),
                );
              },
              true,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  userLevelProvider.errorMessage.contains('Network error')
                      ? 'Result stored locally and will sync when online.'
                      : 'Result submitted successfully!',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PuzzleScreen(grade: grade, cid: cid, subId: subjectId),
              ),
            );
          }
        } else {
          AuthUtils.showLoginPrompt(context);
        }
      },
      child: Text(text, style: FuturexStyles.normal),
    );
  }
}
