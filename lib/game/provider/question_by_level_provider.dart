import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/model/question_by_level_model.dart';
import 'package:futurex_app/game/db/question_db.dart';

class QuestionByLevelProvider extends ChangeNotifier {
  final network = Networks();
  List<QuestionByLevel> _questions = [];
  List<QuestionByLevel> get questions => _questions;
  int _score = 0;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  int get score => _score;
  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<QuestionByLevel>> getLocalQuestions(
    int subjectId,
    int level,
    String chapter,
  ) async {
    final dbName = 'questions_${subjectId}_${level}_$chapter.db';
    final dbHelper = DatabaseHelper(dbName);
    return await dbHelper.getQuestions(dbName);
  }

  Future<void> fetchQuestions(int subjectId, int level, String chapter) async {
    _isLoading = true;
    _error = null;
    _downloadProgress = 0.0;
    notifyListeners();

    final dbName = 'questions_${subjectId}_${level}_$chapter.db';
    final dbHelper = DatabaseHelper(dbName);

    try {
      // Try to load from SQLite first
      final cachedQuestions = await dbHelper.getQuestions(dbName);
      if (cachedQuestions.isNotEmpty) {
        _questions = cachedQuestions;
        _downloadProgress = 1.0;
        _isLoading = false;
        notifyListeners();
        print(
          'Loaded ${cachedQuestions.length} questions from SQLite for $dbName',
        );
        return;
      }

      // Check for internet connectivity
      bool isConnected = await _checkConnectivity();
      if (!isConnected) {
        _error =
            'No internet connection. Please connect to the internet to fetch questions.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch from network
      final response = await http.get(
        Uri.parse(
          '${network.baseApiUrl}/gamequestion-detail/$level/$subjectId/$chapter/',
        ),
      );
      print('API URL: ${response.request?.url}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> questionsData = data['data'];
        _questions = questionsData
            .map((json) => QuestionByLevel.fromJson(json))
            .toList();

        // Simulate progress for UI
        for (int i = 0; i <= 10; i++) {
          _downloadProgress = i / 10.0;
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Store in SQLite
        await dbHelper.insertQuestions(_questions, dbName);
        print('Stored ${_questions.length} questions in SQLite for $dbName');
      } else {
        _error =
            'Failed to load questions. Status code: ${response.statusCode}';
      }
    } catch (error) {
      _error = 'Error: Failed to connect to server, please try again! ($error)';
    } finally {
      _isLoading = false;
      _downloadProgress = _error == null ? 1.0 : 0.0;
      notifyListeners();
    }
  }

  Future<bool> checkAnswer(
    QuestionByLevel question,
    String selectedOption,
  ) async {
    try {
      bool isCorrect = selectedOption == question.answer;
      print(
        'Selected Option: $selectedOption, Correct Answer: ${question.answer}, Is Correct: $isCorrect',
      );
      return isCorrect;
    } catch (error) {
      _error = 'Error checking answer: $error';
      notifyListeners();
      return false;
    }
  }

  void resetScore() {
    _score = 0;
    notifyListeners();
  }

  void incrementScore() {
    _score++;
    notifyListeners();
  }

  Future<void> clearQuestions(int subjectId, String level, int chapter) async {
    final dbName = 'questions_${subjectId}_${level}_$chapter.db';
    final dbHelper = DatabaseHelper(dbName);
    await dbHelper.clearQuestions(dbName);
    _questions = [];
    notifyListeners();
  }
}
