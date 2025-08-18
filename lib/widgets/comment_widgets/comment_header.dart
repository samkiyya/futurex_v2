import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';

class CommentHeader extends StatelessWidget {
  final String thumbnail;
  final int likesCount;
  final int commentsCount;
  final VoidCallback onLikePressed;

  const CommentHeader({
    super.key,
    required this.thumbnail,
    required this.likesCount,
    required this.commentsCount,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          Networks().thumbnailPath + '/$thumbnail',
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up, size: 56, color: Colors.blue),
                onPressed: onLikePressed,
              ),
              const SizedBox(width: 4),
              Text(
                '$likesCount Likes',
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.comment, size: 24, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                '$commentsCount Comments',
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
