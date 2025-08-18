import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:futurex_app/db/activity_db.dart';
import 'package:futurex_app/videoApp/models/activity_model.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ActivityProvider with ChangeNotifier {
  final String _apiUrl = 'https://usersservice.futurexapp.net/api/activity';
  final ActivityDb _activityDb = ActivityDb.instance;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ActivityProvider() {
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        syncActivities();
      }
      notifyListeners();
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }

  // Decides which record method to use
  Future<bool> recordActivity(Activity activity) async {
    if (_isOnline) {
      return await recordActivityOnline(activity);
    } else {
      return await recordActivityOffline(activity);
    }
  }

  /// Use this for online mode ONLY
  Future<bool> recordActivityOnline(Activity activity) async {
    try {
      final success = await _sendToApi(activity);
      if (success) {
        print('Activity sent & deleted from local db.');
        // Not inserting to local DB, but if you want to keep a log, you can insert as isSynced=true and delete.
        return true;
      } else {
        // If failed online, save offline for later sync
        await _activityDb.insertActivity(activity.copyWith(isSynced: false));
        print('API error, activity saved offline.');
        return false;
      }
    } catch (e, stackTrace) {
      print('Online recordActivity failed, saving locally: $e');
      print('Stack trace: $stackTrace');
      await _activityDb.insertActivity(activity.copyWith(isSynced: false));
      return false;
    }
  }

  /// Use this for offline mode ONLY
  Future<bool> recordActivityOffline(Activity activity) async {
    try {
      await _activityDb.insertActivity(activity.copyWith(isSynced: false));
      print('Activity saved to local db (offline)');
      return true;
    } catch (e, stackTrace) {
      print('Offline recordActivity failed: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Send to API, on success delete from local db
  Future<bool> _sendToApi(Activity activity) async {
    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': activity.userId,
              'course_id': activity.courseId,
              'actions': activity.actions,
              'session_start': activity.sessionStart,
              'session_end': activity.sessionEnd,
            }),
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );
      print('the user id is ${activity.userId}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Activity sent successfully: ${response.body}');
        // If activity has an id, delete from local DB (if it exists there)
        if (activity.id != null) {
          await _activityDb.deleteActivity(activity.id!);
        }
        return true;
      } else {
        print(
          'Failed to send activity: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error sending activity: $e');
      return false;
    }
  }

  /// Syncs all local unsynced activities (ONLINE ONLY)
  Future<void> syncActivities() async {
    final unsynced = await _activityDb.getUnsyncedActivities();
    for (var activity in unsynced) {
      final success = await _sendToApi(activity);
      if (success && activity.id != null) {
        await _activityDb.deleteActivity(activity.id!);
      }
    }
  }
}

extension ActivityCopy on Activity {
  Activity copyWith({
    int? id,
    String? userId,
    int? courseId,
    List<String>? actions,
    String? sessionStart,
    String? sessionEnd,
    bool? isSynced,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      actions: actions ?? this.actions,
      sessionStart: sessionStart ?? this.sessionStart,
      sessionEnd: sessionEnd ?? this.sessionEnd,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
