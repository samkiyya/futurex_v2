import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/chat_bottom_sheet.dart';

class ChatFab extends StatelessWidget {
  const ChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const ChatBottomSheet(),
      ),
      backgroundColor: Colors.blueAccent,
      shape: const CircleBorder(),
      elevation: 8,
      child: Image.asset(
        'assets/images/bot.png',
        fit: BoxFit.cover,
        height: 36,
        width: 36,
      ),
    );
  }
}
