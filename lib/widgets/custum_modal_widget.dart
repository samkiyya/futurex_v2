import 'package:flutter/material.dart';
import 'package:futurex_app/constants/styles.dart';

class PersistentDialog extends StatelessWidget {
  final String title;
  final String text;
  final VoidCallback onBackButtonPressed;
  final bool close;

  PersistentDialog({
    required this.title,
    required this.text,
    required this.onBackButtonPressed,
    required this.close,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(title, style: FuturexStyles.head2),
                  SizedBox(height: 10),
                  Text(text, style: FuturexStyles.ftext),
                  SizedBox(height: 20),
                  close
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close'),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                onBackButtonPressed();
                Navigator.pop(context);
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

void showPersistentDialog(
  BuildContext context,
  String title,
  String text,
  VoidCallback onBackButtonPressed,
  bool close,
) {
  showDialog(
    context: context,
    builder: (context) {
      return PersistentDialog(
        title: title,
        text: text,
        onBackButtonPressed: onBackButtonPressed,
        close: close,
      );
    },
  );
}
