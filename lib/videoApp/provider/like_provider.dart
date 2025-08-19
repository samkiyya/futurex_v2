import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/services/like_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikeProvider extends ChangeNotifier {
  final LikeService _likeService = LikeService();
  final Map<int, bool> _likedStatus = {};
  final Map<int, int> _likeCounts = {};

  Map<int, bool> get likedStatus => _likedStatus;
  Map<int, int> get likeCounts => _likeCounts;

  // Initialize likes by fetching them from the backend
  Future<void> initializeLikes() async {
    try {
      final likes = await _likeService.fetchLikesForUser();
      _likedStatus.addAll(likes);
      notifyListeners();
    } catch (e) {
      print("Error initializing likes: $e");
    }
  }

  Future<void> toggleLike(int notificationId) async {
    try {
      // Ensure there's a logged-in user before attempting like/unlike.
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('userId');
      final userId = userIdStr == null ? null : int.tryParse(userIdStr);
      if (userId == null) {
        print(
          'Cannot toggle like: user not logged in (userId is null or empty).',
        );
        return; // Early return to avoid service throwing an exception
      }

      if (_likedStatus[notificationId] == true) {
        // Dislike it
        await _likeService.unlikeNotification(notificationId);
        _likedStatus[notificationId] = false;
        _likeCounts[notificationId] = (_likeCounts[notificationId] ?? 1) - 1;
      } else {
        // Like it
        await _likeService.likeNotification(notificationId);
        _likedStatus[notificationId] = true;
        _likeCounts[notificationId] = (_likeCounts[notificationId] ?? 0) + 1;
      }
      notifyListeners();
    } catch (e) {
      print("Error toggling like/dislike: $e");
    }
  }

  // Set initial values for a specific notification (used if needed)
  void setInitialLikes(int notificationId, bool isLiked, int likeCount) {
    _likedStatus[notificationId] = isLiked;
    _likeCounts[notificationId] = likeCount;
    notifyListeners();
  }
}
