import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ResultProvider with ChangeNotifier {
  final String _baseUrl = 'https://sectionservice.futurexapp.net/api/results';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> submitResult({
    required int total,
    required String resultStatus,
    required String examStatus,
    required int examId,
    required int subjectId,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

     final userIdStr = prefs.getString('userId');

if (userIdStr == null) {
  _isLoading = false;
  notifyListeners();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("User not logged in.")),
  );
  return false;
}

final userId = int.tryParse(userIdStr);
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in.")),
        );
        return false;
      }

      final payload = {
        "total": total,
        "result_status": resultStatus,
        "exam_status": examStatus,
        "exam_id": examId,
        "subject_id": subjectId,
        "user_id": 2,
      };

      print("Submitting result: $payload");

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      _isLoading = false;
      notifyListeners();

      print("Response code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Result submitted successfully!")),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to submit result: ${response.statusCode}")),
        );
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting result: $e")),
      );
      return false;
    }
  }
}
