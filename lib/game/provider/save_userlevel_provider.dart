import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/game/db/user_level_db.dart';
import 'package:http/http.dart' as http;
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/db/result_databse.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class UserLevelProvider extends ChangeNotifier {
  final network = Networks();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String errorMessage = '';
  String? _error;
  String? get error => _error;
  int userLevel = 0;
  List<String> _debugLogs = [];
  List<String> get debugLogs => _debugLogs;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _addDebugLog(String log) {
    _debugLogs.add('${DateTime.now()}: $log');
    if (_debugLogs.length > 50) _debugLogs.removeAt(0);
    debugPrint(log);
    notifyListeners();
  }

  Future<bool> _sendResultToServer({
    required String userId,
    required int level,
    required int score,
    required int subjectId,
    required String grade,
    required String cid,
    required bool status,
  }) async {
    try {
      final url = Uri.parse(
        '${network.gurl}result/create/$grade/$subjectId/$score/${status ? level + 1 : level}/$userId/$level',
      );
      _addDebugLog('Sending result to server: $url');
      final response = await http.post(url).timeout(Duration(seconds: 10));
      _addDebugLog('Server response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        _addDebugLog('Success: Result submitted to server');
        return true;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> data = json.decode(response.body);
        errorMessage = data['error'] ?? 'Unknown error';
        _addDebugLog('Error 400: $errorMessage');
        // Handle case where user already passed the exam
        if (errorMessage.contains('You have already passed')) {
          _addDebugLog(
            'Result rejected by server (already passed), marking as handled',
          );
          return true; // Treat as success to delete from local database
        }
        return false;
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        _addDebugLog('Failed: Status code ${response.statusCode}');
        return false;
      }
    } catch (error) {
      errorMessage = 'Network error: $error';
      _addDebugLog('Error sending result: $error');
      return false;
    }
  }

  Future<void> sendLocalResults() async {
    try {
      final localResults = await _dbHelper.getResults();
      _addDebugLog('Found ${localResults.length} local results');
      if (localResults.isEmpty) {
        _addDebugLog('No local results to send');
        return;
      }

      for (var result in localResults) {
        _addDebugLog('Sending local result: $result');
        bool success = await _sendResultToServer(
          userId: result['userId'],
          level: result['level'],
          score: result['score'],
          subjectId: result['subjectId'],
          grade: result['grade'],
          cid: result['cid'],
          status: result['status'] == 1,
        );
        if (success) {
          await _dbHelper.deleteResult(result['id']);
          _addDebugLog('Deleted synced result: ${result['id']}');
        } else {
          _addDebugLog(
            'Failed to send result: ${result['id']}, keeping in database',
          );
        }
      }

      final remainingResults = await _dbHelper.getResults();
      if (remainingResults.isEmpty) {
        _addDebugLog('All local results sent and database cleared');
        _error = null;
      } else {
        _addDebugLog(
          '${remainingResults.length} local results remain unsynced',
        );
        _error = 'Some results not synced. Will retry later.';
      }
      notifyListeners();
    } catch (error) {
      _addDebugLog('Error sending local results: $error');
      _error = 'Error syncing offline results: $error';
      notifyListeners();
    }
  }

  Future<void> clearLocalResults() async {
    try {
      await _dbHelper.clearResults();
      _addDebugLog('Local database cleared');
    } catch (error) {
      _addDebugLog('Error clearing local database: $error');
    }
  }

  Future<bool> checkResultsExist() async {
    try {
      final results = await _dbHelper.getResults();
      _addDebugLog('Database check: ${results.length} results found');
      return results.isNotEmpty;
    } catch (error) {
      _addDebugLog('Error checking database: $error');
      return false;
    }
  }

  Future<void> postUserLevel(
    String userId,
    int level,
    int score,
    int subjectId,
    String grade,
    String cid,
    bool status,
  ) async {
    _isLoading = true;
    _error = null;
    errorMessage = '';
    notifyListeners();

    try {
      _addDebugLog(
        'Posting result: userId=$userId, level=$level, score=$score, subjectId=$subjectId, grade=$grade, cid=$cid, status=$status',
      );
      userLevel = status ? level + 1 : level;
      _addDebugLog('Updated userLevel to $userLevel');

      final result = {
        'userId': userId,
        'level': level,
        'score': score,
        'subjectId': subjectId,
        'grade': grade,
        'cid': cid,
        'status': status ? 1 : 0,
      };

      bool serverSuccess = await _sendResultToServer(
        userId: userId,
        level: level,
        score: score,
        subjectId: subjectId,
        grade: grade,
        cid: cid,
        status: status,
      );

      if (serverSuccess) {
        _addDebugLog('Result submitted successfully to server');
        await sendLocalResults();
      } else {
        _addDebugLog('Server submission failed: $errorMessage');
        await _dbHelper.insertResult(result);
        final results = await _dbHelper.getResults();
        bool resultExists = results.any(
          (r) =>
              r['userId'] == userId &&
              r['subjectId'] == subjectId &&
              r['level'] == level &&
              r['grade'] == grade &&
              r['cid'] == cid,
        );
        if (!resultExists) {
          _error = 'Failed to store result in local database';
          _addDebugLog('Error: $_error');
        } else {
          _addDebugLog('Result stored successfully in local database');
          if (status) {
            final userLevelDb = UserLevelDatabase();
            int? currentLocalLevel = await userLevelDb.getUserLevel(
              userId,
              subjectId,
            );
            if (currentLocalLevel == null || level + 1 > currentLocalLevel) {
              await userLevelDb.insertOrUpdateUserLevel(
                userId: userId,
                subjectId: subjectId,
                userLevel: level + 1,
                score: score.toDouble(), // Cast int to double to fix the error
                grade: grade,
              );
              userLevel = level + 1; // Update in-memory value
              _addDebugLog('Updated local user level to ${level + 1}');
            }
          }
          if (errorMessage.contains('Network error')) {
            _error = null; // Treat as success if stored locally
          } else {
            _error = errorMessage;
          }
        }
      }
    } catch (error) {
      _error = 'Error: $error';
      _addDebugLog('Error in postUserLevel: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
