import 'package:flutter/material.dart';

class CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CommentInput({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Write a comment...",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: onSubmit,
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
