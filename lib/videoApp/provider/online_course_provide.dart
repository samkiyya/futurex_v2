import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';

class OnlineCourseProvider with ChangeNotifier {
  final Dio _dio = Dio();

  List<Course> _courses = [];
  bool _isLoading = false;
  String _error = '';
  List<Course> _newCourses = [];
  Map<String, List<Course>> _categorizedCourses = {};

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String get error => _error;
  List<Course> get newCourses => _newCourses;
  Map<String, List<Course>> get categorizedCourses => _categorizedCourses;

  Future<void> fetchData() async {
    _isLoading = true;
    _error = '';
    _courses = [];
    _newCourses = [];
    _categorizedCourses = {};
    notifyListeners();

    try {
      final response = await _dio.get('${Networks().courseAPI}/courses');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (kDebugMode) {
          print('API Response of the data from Online course provider: $data');
        }

        _courses = data.map((json) => Course.fromJson(json)).toList();
        _categorizeCourses();
      } else {
        throw Exception('Failed to load data: Status ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Error: Failed to connect to server, please try again!';
      if (kDebugMode) {
        print('Fetch Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _categorizeCourses() {
    _newCourses = List.from(_courses)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
      ..take(10).toList();

    final gradeOrder = ['Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
    final gradeCourses = <String, List<Course>>{};
    final otherCourses = <String, List<Course>>{};

    for (var course in _courses) {
      final categoryName = course.category?.catagory;
      if (categoryName != null) {
        if (gradeOrder.contains(categoryName)) {
          gradeCourses.putIfAbsent(categoryName, () => []).add(course);
        } else if (categoryName != 'New Courses') {
          otherCourses.putIfAbsent(categoryName, () => []).add(course);
        }
      }
    }

    _categorizedCourses = {
      for (var grade in gradeOrder)
        if (gradeCourses.containsKey(grade)) grade: gradeCourses[grade]!,
      ...otherCourses,
    };
  }
}
