import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:futurex_app/videoApp/models/comment_model.dart';
import 'package:futurex_app/videoApp/models/replay_model.dart';

class CommentService {
  static const String _baseUrl = "https://usersservice.futurexapp.net";

  Future<List<Comment>> fetchCommentsByNotificationId(
    int notificationId,
  ) async {
    final uri = Uri.parse(
      "$_baseUrl/api/notification-replay/comment/$notificationId",
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
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
    final uri = Uri.parse("$_baseUrl/api/notification-replay/comment");
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
      final data = json.decode(response.body);
      return Comment.fromJson(
        data,
      ); // Assuming the server returns the created comment as JSON
    } else {
      throw Exception("Failed to create comment");
    }
  }

  Future<List<Reply>> fetchRepliesByCommentId(int commentId) async {
    final uri = Uri.parse(
      "$_baseUrl/api/notification-replay/replies/$commentId",
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['replies'] as List<dynamic>;
      return data.map((json) => Reply.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load replies");
    }
  }

  /// Creates a new reply and returns the created Reply object
  Future<Reply> createReply(int commentId, int adminId, String reply) async {
    final uri = Uri.parse("$_baseUrl/api/notification-replay/reply");
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
      final data = json.decode(response.body);
      return Reply.fromJson(
        data,
      ); // Assuming the server returns the created reply as JSON
    } else {
      throw Exception("Failed to create reply");
    }
  }
}
