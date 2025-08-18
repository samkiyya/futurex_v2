import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:futurex_app/forum/models/reply.dart';

class ReplyProvider with ChangeNotifier {
  Map<int, List<Reply>> _repliesByCommentId = {};
  Map<int, bool> _isLoadingForCommentId = {};
  Map<int, String?> _errorForCommentId = {};
  Map<int, bool> _allRepliesLoadedForCommentId = {};

  List<Reply> repliesForComment(int commentId) =>
      _repliesByCommentId[commentId] ?? [];
  bool isLoadingForComment(int commentId) =>
      _isLoadingForCommentId[commentId] ?? false;
  String? errorForComment(int commentId) => _errorForCommentId[commentId];
  bool allRepliesLoadedForComment(int commentId) =>
      _allRepliesLoadedForCommentId[commentId] ?? false;

  final String _apiBaseUrl;
  final _storage = FlutterSecureStorage();

  ReplyProvider(this._apiBaseUrl);

  Future<String?> _getUserId() async {
    return await _storage.read(key: 'loggeduserId');
  }

  List<Reply> _buildReplyTree(List<Reply> flatReplies) {
    Map<int, Reply> map = {};
    List<Reply> roots = [];

    for (var reply in flatReplies) {
      map[reply.id] = reply.copyWith(childReplies: []);
    }

    for (var reply in flatReplies) {
      var current = map[reply.id]!;
      if (reply.parentReplyId == null) {
        roots.add(current);
      } else {
        var parent = map[reply.parentReplyId];
        if (parent != null) {
          List<Reply> updatedChildren = List<Reply>.from(parent.childReplies)
            ..add(current);
          map[reply.parentReplyId!] = parent.copyWith(
            childReplies: updatedChildren,
          );

          int rootIndex = roots.indexWhere((r) => r.id == reply.parentReplyId);
          if (rootIndex != -1) {
            roots[rootIndex] = map[reply.parentReplyId!]!;
          }
        } else {
          print(
            "Parent reply ${reply.parentReplyId} not found for reply ${reply.id}",
          );
          roots.add(current);
        }
      }
    }

    for (var root in roots) {
      _sortRepliesRecursively(root);
    }
    roots.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return roots;
  }

  void _sortRepliesRecursively(Reply reply) {
    if (reply.childReplies.isNotEmpty) {
      reply.childReplies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      for (var child in reply.childReplies) {
        _sortRepliesRecursively(child);
      }
    }
  }

  Future<void> fetchRepliesForComment(
    int commentId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _repliesByCommentId.containsKey(commentId) &&
        !(_isLoadingForCommentId[commentId] ?? false) &&
        (_allRepliesLoadedForCommentId[commentId] ?? false)) {
      return;
    }

    _isLoadingForCommentId[commentId] = true;
    _errorForCommentId[commentId] = null;
    if (forceRefresh) {
      _allRepliesLoadedForCommentId[commentId] = false;
    }
    notifyListeners();

    final url = Uri.parse('$_apiBaseUrl/post-comments/$commentId/replies');

    try {
      final response = await http.get(
        url,
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Reply> flatReplies = data
            .map((rJson) {
              try {
                return Reply.fromJson(rJson);
              } catch (e) {
                print("Parse error: $e");
                return null;
              }
            })
            .whereType<Reply>()
            .toList();

        _repliesByCommentId[commentId] = _buildReplyTree(flatReplies);
        _errorForCommentId[commentId] = null;
        _allRepliesLoadedForCommentId[commentId] = true;
      } else {
        _errorForCommentId[commentId] =
            "Failed to load replies: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      _errorForCommentId[commentId] = "Fetch error: ${e.toString()}";
    } finally {
      _isLoadingForCommentId[commentId] = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createReply({
    required int parentCommentId,
    required String content,
    int? parentReplyId,
  }) async {
    final userId = await _getUserId();
    if (userId == null)
      return {'success': false, 'message': "User not authenticated."};

    final url = Uri.parse(
      '$_apiBaseUrl/post-comments/$parentCommentId/replies',
    );
    final body = {
      'content': content,
      'userId': userId,
      if (parentReplyId != null) 'parentReplyId': parentReplyId,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-User-ID": userId,
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        await fetchRepliesForComment(parentCommentId, forceRefresh: true);
        return {'success': true, 'message': "Reply created."};
      } else {
        return {
          'success': false,
          'message': "Failed: ${response.statusCode} ${response.body}",
        };
      }
    } catch (e) {
      return {'success': false, 'message': "Error: ${e.toString()}"};
    }
  }

  Future<Map<String, dynamic>> updateReply({
    required int parentCommentId,
    required int replyId,
    required String newContent,
  }) async {
    final userId = await _getUserId();
    if (userId == null)
      return {'success': false, 'message': "User not authenticated."};

    final url = Uri.parse('$_apiBaseUrl/comment-replies/$replyId');

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-User-ID": userId,
        },
        body: json.encode({'content': newContent}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchRepliesForComment(parentCommentId, forceRefresh: true);
        return {'success': true, 'message': "Reply updated."};
      } else {
        return {
          'success': false,
          'message': "Failed: ${response.statusCode} ${response.body}",
        };
      }
    } catch (e) {
      return {'success': false, 'message': "Error: ${e.toString()}"};
    }
  }

  Future<Map<String, dynamic>> deleteReply({
    required int parentCommentId,
    required int replyId,
  }) async {
    final userId = await _getUserId();
    if (userId == null)
      return {'success': false, 'message': "User not authenticated."};

    final url = Uri.parse('$_apiBaseUrl/comment-replies/$replyId');

    try {
      final response = await http.delete(
        url,
        headers: {"Accept": "application/json", "X-User-ID": userId},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchRepliesForComment(parentCommentId, forceRefresh: true);
        return {'success': true, 'message': "Reply deleted."};
      } else {
        return {
          'success': false,
          'message': "Failed: ${response.statusCode} ${response.body}",
        };
      }
    } catch (e) {
      return {'success': false, 'message': "Error: ${e.toString()}"};
    }
  }
}
