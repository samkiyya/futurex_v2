import 'dart:convert';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import 'package:futurex_app/videoApp/models/comment_model.dart';
import 'package:futurex_app/videoApp/models/replay_model.dart';

class CommentService {
  static final String _baseUrl = Networks().coursePath;

  Future<List<Comment>> fetchCommentsByNotificationId(
    int notificationId,
  ) async {
    final uri = Uri.parse(
      "$_baseUrl/api/notifications-interactions/comment/notification/$notificationId",
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // try common keys: data, comments
        if (decoded['data'] is List) {
          list = decoded['data'];
        } else if (decoded['comments'] is List) {
          list = decoded['comments'];
        } else if (decoded['replies'] is List) {
          // just in case server returns replies for a comment id endpoint
          list = decoded['replies'];
        } else {
          // fallback: find first list in map
          final firstList = decoded.values.firstWhere(
            (v) => v is List,
            orElse: () => [],
          );
          list = firstList is List ? firstList : [];
        }
      } else {
        list = [];
      }
      return list
          .map((j) => Comment.fromJson(j as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load comments");
    }
  }

  /// Creates a new comment and returns the created Comment object
  Future<Comment> createComment(
    int notificationId,
    int userId,
    String comment,
  ) async {
    final uri = Uri.parse("$_baseUrl/api/notifications-interactions/comment");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "notificationId": notificationId,
        "userType": "student",
        "user_id": userId,
        "comment": comment,
      }),
    );

    print("Create Comment Response: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      // Sometimes API returns { message, comment: {...} }
      final obj = decoded is Map<String, dynamic>
          ? (decoded['comment'] ?? decoded)
          : decoded;
      return Comment.fromJson(obj as Map<String, dynamic>);
    } else {
      throw Exception("Failed to create comment");
    }
  }

  Future<List<Reply>> fetchRepliesByCommentId(int commentId) async {
    final uri = Uri.parse(
      "$_baseUrl/api/notifications-interactions/comment/$commentId",
    );
    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(response.body);
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['replies'] is List) {
          list = decoded['replies'];
        } else if (decoded['data'] is List) {
          list = decoded['data'];
        } else {
          // try to find first list in map
          final firstList = decoded.values.firstWhere(
            (v) => v is List,
            orElse: () => [],
          );
          list = firstList is List ? firstList : [];
        }
      } else {
        list = [];
      }
      return list
          .map((j) => Reply.fromJson(j as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Failed to load replies");
    }
  }

  /// Creates a new reply and returns the created Reply object
  Future<Reply> createReply(int commentId, int adminId, String reply) async {
    final uri = Uri.parse("$_baseUrl/api/notifications-interactions/reply");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "commentId": commentId,
        "adminId": adminId,
        "reply": reply,
        "userType": "student",
      }),
    );

    print("Create Reply Response: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      // API returns { message, reply: {...} }
      final obj = decoded is Map<String, dynamic>
          ? (decoded['reply'] ?? decoded)
          : decoded;
      return Reply.fromJson(obj as Map<String, dynamic>);
    } else {
      throw Exception("Failed to create reply");
    }
  }

  /// Fetch total comment count for a notification
  Future<int> fetchNotificationCommentCount(int notificationId) async {
    final uri = Uri.parse(
      "$_baseUrl/api/notifications-interactions/comment/notification/$notificationId/count",
    );
    final response = await http.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          final count = decoded['count'];
          if (count is int) return count;
          if (count is String) return int.tryParse(count) ?? 0;
        }
      } catch (_) {}
      return 0;
    } else {
      throw Exception(
        "Failed to fetch comment count: ${response.statusCode} ${response.body}",
      );
    }
  }
}
