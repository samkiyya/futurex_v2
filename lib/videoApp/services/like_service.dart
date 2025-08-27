import 'dart:convert';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futurex_app/videoApp/models/like_model.dart';

class LikeService {
  static final String _baseUrl = Networks().coursePath;

  // Fetch all likes for the current user
  Future<Map<int, bool>> fetchLikesForUser() async {
    final uri = Uri.parse("$_baseUrl/api/notifications-interactions/like");
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('userId');
    final userId = userIdStr == null ? null : int.tryParse(userIdStr);

    if (userId == null) {
      throw Exception("User ID not found. Please log in again.");
    }

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch likes");
    }

    final data = json.decode(response.body) as List<dynamic>;
    final Map<int, bool> likes = {};

    for (var item in data) {
      if (item['user_id'] == userId) {
        likes[item['notificationId']] = true;
      }
    }

    return likes;
  }

  Future<void> likeNotification(int notificationId) async {
    final uri = Uri.parse("$_baseUrl/api/notifications-interactions/like");
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('userId');
    final userId = userIdStr == null ? null : int.tryParse(userIdStr);
    print("The Liked User ID is: $userId");

    if (userId == null) {
      throw Exception("User ID not found. Please log in again.");
    }

    final like = Like(
      notificationId: notificationId,
      userType: "parent",
      userId: userId,
    );

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode(like.toJson()),
    );

    if (response.statusCode == 409) {
      print("Notification already liked.");
      return;
    }
    // Treat any 2xx as success (201 Created is common)
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Failed to like the notification: ${response.body}");
    }
  }

  Future<void> unlikeNotification(int notificationId) async {
    final uri = Uri.parse("$_baseUrl/api/notifications-interactions/unlike");
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('userId');
    final userId = userIdStr == null ? null : int.tryParse(userIdStr);

    if (userId == null) {
      throw Exception("User ID not found. Please log in again.");
    }

    final like = Like(
      notificationId: notificationId,
      userType: "parent",
      userId: userId,
    );

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode(like.toJson()),
    );

    // Treat 2xx (including 204 No Content) as success
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Failed to unlike the notification: ${response.body}");
    }
  }
}
