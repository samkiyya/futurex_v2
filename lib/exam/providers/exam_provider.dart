import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/exam/models/exam.dart';
import 'package:http/http.dart' as http;

// Exam Provider
class ExamProvider with ChangeNotifier {
  List<Exam> _exams = [];
  bool _isLoading = false;
  String? _error;

  List<Exam> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchExams({int? subjectId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Construct the URL with optional subjectId query parameter
      final url = subjectId != null
          ? "https://sectionservice.futurexapp.net/api/exams/subject/$subjectId"
          : "https://sectionservice.futurexapp.net/api/exams";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _exams = (data['data'] as List)
            .map((examJson) => Exam.fromJson(examJson))
            .toList();
        _error = null;
      } else {
        _error = 'Failed to load exams';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
