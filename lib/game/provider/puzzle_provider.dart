import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/game/db/puzzle_database.dart';
import 'package:http/http.dart' as http;
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/model/puzzle_model.dart';

class PuzzleProvider extends ChangeNotifier {
  final network = Networks();
  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final PuzzleDatabase _dbHelper = PuzzleDatabase();

  Future<void> fetchSubjectsAndLevels(String grade, String cid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Try to load from local database first
      _subjects = await _dbHelper.getSubjectsAndLevels(grade, cid);
      if (_subjects.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch from server if no local data
      final response = await http.get(
        Uri.parse('${network.baseApiUrl}/subject-level/$grade/$cid'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _subjects = data.map((json) => Subject.fromJson(json)).toList();
        // Store in SQLite
        await _dbHelper.insertSubjectsAndLevels(grade, cid, _subjects);
      } else {
        _error =
            'Failed to load subjects and levels. Status code: ${response.statusCode}';
      }
    } catch (error) {
      _error = 'Error: Failed to connect to server, please try again!';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubjectsFromLocal(String grade, String cid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load from SQLite database
      _subjects = await _dbHelper.getSubjectsAndLevels(grade, cid);
      if (_subjects.isEmpty) {
        _error =
            'No offline data available for this grade and curriculum. Please fetch online first.';
      }
    } catch (error) {
      _error = 'Error: Failed to load offline data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
