import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/exam/models/examResult.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResultFetchProvider with ChangeNotifier {
  List<ExamResult> _results = [];
  bool _isLoading = false;
  String? _error;

  List<ExamResult> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchResultsBySubject() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _error = "User not logged in.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url =
          'https://sectionservice.futurexapp.net/api/results/user/$userId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> resultList = data['data'];

        _results = resultList.map((json) => ExamResult.fromJson(json)).toList();
      } else {
        _error = 'Failed to load results: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
