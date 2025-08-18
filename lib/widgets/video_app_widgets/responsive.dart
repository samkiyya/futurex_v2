
import 'package:flutter/material.dart';

class ResponsiveTextWidget extends StatelessWidget {
  final String title;
  final String text;

  const ResponsiveTextWidget({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: RichText(
                text: TextSpan(
                  text: text,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}