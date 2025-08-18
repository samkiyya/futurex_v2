import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futurex_app/videoApp/models/comment_model.dart';
import 'package:futurex_app/videoApp/models/replay_model.dart';
import 'package:futurex_app/videoApp/services/comment_service.dart';

class CommentProvider extends ChangeNotifier {
  final CommentService _commentService = CommentService();

  List<Comment> _comments = [];
  Map<int, List<Reply>> _repliesMap = {};
  bool _isLoading = false;
  bool _isAddingComment = false;
  bool _isAddingReply = false;

  List<Comment> get comments => _comments;
  Map<int, List<Reply>> get repliesMap => _repliesMap;
  bool get isLoading => _isLoading;
  bool get isAddingComment =>
      _isAddingComment; // Getter for adding comment loading state
  bool get isAddingReply =>
      _isAddingReply; // Getter for adding reply loading state

  /// Fetch comments for a specific notification ID
  Future<void> fetchComments(int notificationId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _comments = await _commentService.fetchCommentsByNotificationId(
        notificationId,
      );
      notifyListeners(); // Ensure UI is updated
    } catch (e) {
      print("Error fetching comments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a comment using the userId from SharedPreferences (stored as String)
  Future<void> addComment(int notificationId, String comment) async {
    _isAddingComment = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('userId');
      final userId = userIdStr == null ? null : int.tryParse(userIdStr);

      print("the person to be added thic comment user id is : $userId");

      if (userId == null) {
        throw Exception("User ID not found. Please log in again.");
      }

      // Create the new comment and add it to the list
      final newComment = await _commentService.createComment(
        notificationId,
        userId,
        comment,
      );
      _comments.insert(0, newComment);
      notifyListeners();
    } catch (e) {
      print("Error adding comment: $e");
    } finally {
      _isAddingComment = false;
      notifyListeners();
    }
  }

  /// Fetch replies for a specific comment ID
  Future<void> fetchReplies(int commentId) async {
    try {
      final replies = await _commentService.fetchRepliesByCommentId(commentId);
      _repliesMap[commentId] = replies;
      notifyListeners();
    } catch (e) {
      print("Error fetching replies: $e");
    }
  }

  /// Add a reply using the userId from SharedPreferences (stored as String)
  Future<void> addReply(int commentId, String reply) async {
    _isAddingReply = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('userId');
      final userId = userIdStr == null ? null : int.tryParse(userIdStr);

      if (userId == null) {
        throw Exception("User ID not found. Please log in again.");
      }

      // Create the new reply and add it to the list
      final newReply = await _commentService.createReply(
        commentId,
        userId,
        reply,
      );
      if (_repliesMap.containsKey(commentId)) {
        _repliesMap[commentId]!.insert(0, newReply);
      } else {
        _repliesMap[commentId] = [newReply];
      }
      notifyListeners();
    } catch (e) {
      print("Error adding reply: $e");
    } finally {
      _isAddingReply = false;
      notifyListeners();
    }
  }
}
