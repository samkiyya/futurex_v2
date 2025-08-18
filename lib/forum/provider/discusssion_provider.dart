import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiscussionProvider with ChangeNotifier {
  bool _isSubmittingPost = false;
  String? _submitPostError;

  bool get isSubmittingPost => _isSubmittingPost;
  String? get submitPostError => _submitPostError;

  Future<bool> createPost({
    required String title,
    required String description,
  }) async {
    _isSubmittingPost = true;
    _submitPostError = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        _submitPostError = 'User ID not found in storage.';
        _isSubmittingPost = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('https://courseservice.futurexapp.net/api/posts'),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId.toString(),
        },
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isSubmittingPost = false;
        notifyListeners();
        return true;
      } else {
        _submitPostError = 'Server responded with ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      _submitPostError = 'Network error: $e';
    }

    _isSubmittingPost = false;
    notifyListeners();
    return false;
  }
}
