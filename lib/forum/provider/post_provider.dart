// lib/providers/post_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostProvider with ChangeNotifier {
  static const _baseUrl = Networks.forumService + '/posts';

  bool _isLoading = false;
  String? _error;
  List<Post> _posts = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Post> get posts => _posts;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse(_baseUrl));
      if (res.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(res.body);
        _posts = jsonList.map((e) => Post.fromJson(e)).toList();
      } else {
        _error = 'Error ${res.statusCode}: ${res.reasonPhrase}';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
