// lib/models/author.dart

class Author {
  final int id;
  final String name;

  Author({required this.id, required this.name});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
    );
  }
}


class Post {
  final int id;
  final String title;
  final String description;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Author author;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      author: Author.fromJson(json['author'] ?? {}),
    );
  }
}
