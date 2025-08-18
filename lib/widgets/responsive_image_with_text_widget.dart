import 'package:flutter/material.dart';
import 'package:futurex_app/constants/styles.dart';

class ResponsiveImageTextWidget extends StatelessWidget {
  final String imageUrl;
  final String text;

  ResponsiveImageTextWidget({required this.imageUrl, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageUrl,
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            // You can use other Image properties for customization
          ),
          SizedBox(height: 20),
          Text(text, style: FuturexStyles.error, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ResponsiveImageTextWidget2 extends StatelessWidget {
  final String imageUrl;
  final String text;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const ResponsiveImageTextWidget2({
    Key? key,
    required this.imageUrl,
    required this.text,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageUrl, height: 200, width: 200, fit: BoxFit.contain),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: onButtonPressed,
              child: Text(
                buttonText!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
