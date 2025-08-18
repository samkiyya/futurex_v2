import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/models/blog_model.dart';
import 'package:futurex_app/videoApp/services/blog_service.dart';

class BlogProvider extends ChangeNotifier {
  List<Blog> _blogs = [];
  bool _isLoading = false;

  List<Blog> get blogs => _blogs;
  bool get isLoading => _isLoading;

  final BlogService _blogService = BlogService();

  Future<void> loadBlogs({String? notificationType}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _blogs = await _blogService.fetchBlogs(
        notificationType: notificationType,
      );
    } catch (e) {
      print("Error loading blogs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to filter blogs by notification type
  void filterBlogsByType(String notificationType) {
    loadBlogs(notificationType: notificationType);
  }

  fetchBlogs() {}
}
