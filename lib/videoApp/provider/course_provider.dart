import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:futurex_app/constants/constants.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CourseProvider with ChangeNotifier {
  final api = Networks();
  final Dio _dio = Dio();
  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String userId = "";
  final storage = FlutterSecureStorage();

  Future<void> fetchCourses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _dio.get(Networks().courseAPI + '/course');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        _courses = jsonList.map((json) => Course.fromJson(json)).toList();
        await storage.write(key: 'courses', value: response.data.toString());
      } else {
        throw Exception('Failed to fetch courses');
      }
    } catch (e) {
      print('Error fetching courses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCoursesFromStorage() async {
    try {
      final response = await storage.read(key: 'courses');
      if (response != null) {
        final List<dynamic> jsonList = json.decode(response);
        _courses = jsonList.map((json) => Course.fromJson(json)).toList();
      }
    } catch (e) {
      // throw Exception('Failed to get courses from storage');
    }
    notifyListeners();
  }
}
