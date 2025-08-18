import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/models/comment.dart';
import 'package:get_time_ago/get_time_ago.dart';

class CommentList extends StatelessWidget {
  final List<Comment> comments;

  const CommentList({super.key, required this.comments});

  String _formatTimestamp(String timestamp) {
    try {
      if (timestamp.isEmpty || timestamp == "0000-00-00 00:00:00") {
        return "1 year ago";
      }
      final dateTime = DateTime.parse(timestamp);
      return GetTimeAgo.parse(dateTime);
    } catch (_) {
      return "1 year ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(
        child: Text('No comments available. Be the first to comment!'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        if (comment.comment.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(comment.comment, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(comment.createdAt),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 192, 190, 190),
                  ),
                ),
                if (comment.reply.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Replied by FutureX:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              comment.reply,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
