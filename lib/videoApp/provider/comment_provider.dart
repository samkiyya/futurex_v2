// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/models/comment.dart';
import 'package:futurex_app/videoApp/services/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CommentProvider with ChangeNotifier {
  final String courseId;
  int _likesCount;
  bool _isLoading = true;
  List<Comment> _comments = [];
  final TextEditingController _commentTextController = TextEditingController();
  double _rating = 5.0;

  final Dio _dio = Dio();

  // Getters
  int get likesCount => _likesCount;
  bool get isLoading => _isLoading;
  List<Comment> get comments => _comments;
  TextEditingController get commentTextController => _commentTextController;
  double get rating => _rating;

  CommentProvider(this.courseId, this._likesCount) {
    _fetchComments();
  }

  // --- Network Operations ---

  Future<void> _fetchComments() async {
    try {
      final response = await _dio.get(
        Networks().courseAPI + '/comments/$courseId',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        _comments = (data['comments'] as List)
            .map((json) => Comment.fromJson(json))
            .toList();
        _updateLoadingState(false);
      } else {
        _updateLoadingState(false);
      }
    } catch (error) {
      _updateLoadingState(false);
      _showSnackBar('Error fetching comments: please try again');
    }
  }

  Future<void> submitComment(BuildContext context) async {
    final commentText = _commentTextController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final firstName = prefs.getString('first_name') ?? 'Unknown';
    final lastName = prefs.getString('last_name') ?? '';
    final userName = '$firstName $lastName'.trim();

    if (userId == null) {
      _showLoginDialog(context);
      return;
    }

    try {
      final response = await _dio.post(
        Networks().courseAPI + '/comment',
        data: {
          'course_id': courseId,
          'comment': commentText,
          'user_name': userName,
        },
      );

      if (response.statusCode == 201) {
        await _fetchComments();
        _showSuccessDialog(context, 'Commented', 'Thanks for your comment!');
        _commentTextController.clear();
        updateRating(0.0);
      } else {
        print(response);
        _showSnackBar('Failed to submit comment');
      }
    } catch (error) {
      _showErrorDialog(context, 'Network error! please try again');
    }
  }

  Future<void> toggleLike(BuildContext context) async {
    final likeResponse = await ApiService().toggleLike(courseId);

    switch (likeResponse.message) {
      case 'Course liked':
        if (likeResponse.success) {
          _likesCount += 1;
          notifyListeners();
          _showSuccessDialog(context, 'Liked', 'You liked this course!');
        }
        break;
      case 'Already liked':
        _showInfoDialog(
          context,
          'Already Liked',
          'You have already liked this course!',
        );
        break;
      case 'Connection Error!':
        _showSnackBar('Connection Error!');
        break;
      case 'Not logged in':
        _showSnackBar('Please log in to like this course.');
        break;
      default:
        _showSnackBar('Error:please try again');
    }
  }

  // --- State Updates ---

  void updateRating(double newRating) {
    _rating = newRating;
    notifyListeners();
  }

  void _updateLoadingState(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // --- UI Feedback ---

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      _currentContext!,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to comment!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Workaround for context in provider
  BuildContext? _currentContext;
  void setContext(BuildContext context) => _currentContext = context;
}
