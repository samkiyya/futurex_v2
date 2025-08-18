// lib/providers/comment_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/constants.dart';
import 'package:http/http.dart' as http;
import '../models/comment.dart';

class ForumCommentProvider with ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Comment> _comments = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Comment> get comments => _comments;

  Future<void> fetchComments(int postId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final url = Networks.forumService + '/posts/all/$postId';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final jsonMap = jsonDecode(res.body);
        _comments = (jsonMap['comments'] as List<dynamic>)
            .map((c) => Comment.fromJson(c))
            .toList();
      } else {
        _error = 'Error ${res.statusCode}: ${res.reasonPhrase}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
