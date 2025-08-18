import 'package:futurex_app/forum/models/post.dart';

class Reply {
  final int id;
  final String content;
  final int userId;
  final DateTime createdAt;
  final Author author;

  Reply({
    required this.id,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.author,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'],
      content: json['content'] ?? '',
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      author: Author.fromJson(json['author'] ?? {}),
    );
  }
}

class Comment {
  final int id;
  final String content;
  final int userId;
  final int postId;
  final DateTime createdAt;
  final List<Reply> replies;
  final Author author;
  final Post post;

  Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.replies,
    required this.author,
    required this.post,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'] ?? '',
      userId: json['userId'],
      postId: json['postId'],
      createdAt: DateTime.parse(json['createdAt']),
      replies: (json['replies'] as List<dynamic>)
          .map((r) => Reply.fromJson(r))
          .toList(),
      author: Author.fromJson(json['author'] ?? {}),
      post: Post(
        id: json['post']['id'],
        title: json['post']['title'],
        description: '',
        userId: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        author: Author(id: 0, name: ''),
      ),
    );
  }
}
