import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/model/curriculum_model.dart';

class CurriculumProvider extends ChangeNotifier {
  final network = Networks();
  List<Curriculum> _curriculums = [];
  List<Curriculum> get curriculums => _curriculums;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  static const String _curriculumsKey = 'curriculums';

  Future<void> fetchCurriculums() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if data exists in local storage
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_curriculumsKey);

      if (storedData != null) {
        // Data exists in local storage, load it
        final List<dynamic> data = json.decode(storedData);
        _curriculums = data.map((json) => Curriculum.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch from network if no local data
      final response = await http.get(
        Uri.parse('${network.baseApiUrl}/grades'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _curriculums = data.map((json) => Curriculum.fromJson(json)).toList();

        // Store data in local storage
        await prefs.setString(_curriculumsKey, json.encode(data));
      } else {
        _error =
            'Failed to load curriculums. Status code: ${response.statusCode}';
      }
    } catch (error) {
      _error = 'Error: Failed to connect to server, please try again!';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurriculumsFromLocal() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_curriculumsKey);

      if (storedData != null) {
        final List<dynamic> data = json.decode(storedData);
        _curriculums = data.map((json) => Curriculum.fromJson(json)).toList();
      } else {
        _error = 'No offline data available. Please fetch online first.';
      }
    } catch (error) {
      _error = 'Error: Failed to load offline data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
