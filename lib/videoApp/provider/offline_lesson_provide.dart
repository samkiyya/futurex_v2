import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineLessonProvider extends ChangeNotifier {
  List<dynamic> _lessons = [];
  bool _isLoading = false;

  List<dynamic> get lessons => _lessons;
  bool get isLoading => _isLoading;

  Future<void> fetchLessons(int sectionId, String type) async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Dio dio = Dio(); // Initialize Dio

    // First, check for internet connection
    bool hasConnection = await _hasConnection();

    if (hasConnection) {
      try {
        Response response;
        print("Fetching lessons for Section ID: $sectionId");

        print("Fetching video lessons...");
        response = await dio.get(
          Networks().lessonAPI + '/lessons/section/$sectionId',
        );

        if (response.statusCode == 200) {
          _lessons = response.data; // Dio auto-parses JSON
          print(_lessons);
          await prefs.setString(sectionId.toString(), jsonEncode(_lessons));
        } else {
          throw Exception('Failed to load lessons from the server');
        }
      } catch (e) {
        print("Error fetching lessons: $e");
        _loadFromStorage(prefs, sectionId);
      }
    } else {
      _loadFromStorage(prefs, sectionId);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Helper function to load lessons from SharedPreferences
  void _loadFromStorage(SharedPreferences prefs, int sectionId) {
    String? storedData = prefs.getString('$sectionId');
    if (storedData != null) {
      _lessons = jsonDecode(storedData);
    } else {
      _lessons = []; // If no data in storage, return empty list
    }
  }

  // Check for internet connection
  Future<bool> _hasConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}
