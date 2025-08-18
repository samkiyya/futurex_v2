import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/model/chapter_model.dart';
import 'package:http/http.dart' as http;

class ChapterProvider extends ChangeNotifier {
  final network = new Networks();
  List<Chapter> _chapters = [];
  List<Chapter> get chapters => _chapters;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchChapters(int subjectId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse(network.baseApiUrl + '/chapter-by-subject/$subjectId/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _chapters = data.map((json) => Chapter.fromJson(json)).toList();
      } else {
        _error = 'Failed to load chapters. Status code: ${response.statusCode}';
      }
    } catch (error) {
      _error = 'Error: Failed to connect to server please try Again!';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
