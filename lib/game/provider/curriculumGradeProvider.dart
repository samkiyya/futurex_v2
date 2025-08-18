// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:futurex_app/game/model/curriculum_model.dart';

class ApiService {
  Future<List<Curriculum>> fetchCurriculumByGrade(int grade) async {
    String apiUrl =
        'https://gameapp.futurexapp.net/gamequestion/mygrades/$grade';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Curriculum> curriculums = data
          .map((json) => Curriculum.fromJson(json))
          .toList();
      return curriculums;
    } else {
      throw Exception('Failed to load curriculum');
    }
  }
}

class CurriculumGradeProvider with ChangeNotifier {
  List<Curriculum> _curriculums = [];
  bool _isLoading = false;

  List<Curriculum> get curriculums => _curriculums;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  Future<void> fetchCurriculum(int grade) async {
    try {
      _isLoading = true;
      notifyListeners();

      _curriculums = await _apiService.fetchCurriculumByGrade(grade);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to fetch curriculum');
    }
  }
}
