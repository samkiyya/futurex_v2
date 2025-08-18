import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostCommentProvider with ChangeNotifier {
  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> postComment({
    required int postId,
    required String content,
    required BuildContext context,
    VoidCallback? onSuccess,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final url = Uri.parse('${Networks.forumService}/post-comments');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences");
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'X-User-ID': userId},
        body: jsonEncode({"postId": postId, "comment": content}),
      );

      if (response.statusCode == 201) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Comment submitted successfully')),
        );
        onSuccess?.call();
      } else {
        String errorMsg = response.statusCode.toString();

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> postReply({
    required int commentId,
    required String content,
    required BuildContext context,
    VoidCallback? onSuccess,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final url = Uri.parse(
      '${Networks.forumService}/post-comments/$commentId/replies',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences");
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'X-User-ID': userId},
        body: jsonEncode({"content": content}),
      );

      if (response.statusCode == 201) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Reply posted successfully')),
        );
        onSuccess?.call();
      } else {
        String msg = 'Failed to post reply';
        try {
          final data = jsonDecode(response.body);
          msg = data['message'] ?? msg;
        } catch (_) {
          msg = 'Unexpected server error: ${response.body}';
        }
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
