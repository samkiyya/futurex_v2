// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:futurex_app/videoApp/provider/themProvider.dart';
import 'package:provider/provider.dart';
import 'payment_details_screen.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  _CourseSelectionScreenState createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  List<Category> _categories = [];
  Map<int, List<Course>> _categoryCourses = {}; // categoryId -> list of courses
  Map<int, List<int>> _selectedCourseIds =
      {}; // categoryId -> selected course ids
  List<int> _expandedCategoryIds = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final primary = await _dio.get('${Networks().courseAPI}/categories');
      Response fallback;
      Response use;
      if (primary.statusCode == 200) {
        use = primary;
      } else {
        fallback = await _dio.get('${Networks().courseAPI}/catagories');
        use = fallback;
      }

      if (use.statusCode == 200) {
        final raw = use.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map<String, dynamic>
                  ? (raw['data'] as List?) ?? (raw['categories'] as List?) ?? []
                  : []);
        _categories = data
            .map(
              (json) => Category.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ),
            )
            .toList();
        setState(() {
          _isLoading = false;
        });

        // Fetch courses for each category
        for (var category in _categories) {
          await _fetchCoursesForCategory(category.id);
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load categories. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load categories. Please try again.';
      });
    }
  }

  Future<void> _fetchCoursesForCategory(int categoryId) async {
    try {
      final response = await _dio.get(
        '${Networks().courseAPI}/courses/semister/$categoryId',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200) {
        List<Course> courses = (response.data as List)
            .map((json) => Course.fromJson(json))
            .toList();
        setState(() {
          _categoryCourses[categoryId] = courses;
          _selectedCourseIds[categoryId] = [];
        });
      } else {
        _categoryCourses[categoryId] = [];
      }
    } catch (_) {
      _categoryCourses[categoryId] = [];
    }
  }

  void _toggleCourseSelection(int categoryId, int courseId) {
    setState(() {
      final selected = _selectedCourseIds[categoryId] ?? [];
      if (selected.contains(courseId)) {
        selected.remove(courseId);
      } else {
        selected.add(courseId);
      }
      _selectedCourseIds[categoryId] = selected;
    });
  }

  void _toggleExpansion(int categoryId) {
    setState(() {
      if (_expandedCategoryIds.contains(categoryId)) {
        _expandedCategoryIds.remove(categoryId);
      } else {
        _expandedCategoryIds.add(categoryId);
      }
    });
  }

  void _handleNext() {
    final selectedCourses = <Course>[];

    for (var categoryId in _selectedCourseIds.keys) {
      final selectedIds = _selectedCourseIds[categoryId]!;
      final courses = _categoryCourses[categoryId] ?? [];
      selectedCourses.addAll(courses.where((c) => selectedIds.contains(c.id)));
    }

    if (selectedCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one course')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentDetailsScreen(
          selectedCategories: [],
          selectedCourses: selectedCourses,
          type: 'Single course',
        ),
      ),
    );
  }

  Widget _buildExpandableCategory(Category category) {
    final isExpanded = _expandedCategoryIds.contains(category.id);
    final courses = _categoryCourses[category.id] ?? [];
    final selectedIds = _selectedCourseIds[category.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            category.catagory,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          ),
          onTap: () => _toggleExpansion(category.id),
        ),
        if (isExpanded)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: courses.map((course) {
                return CheckboxListTile(
                  title: Text(
                    course.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  value: selectedIds.contains(course.id),
                  onChanged: (_) =>
                      _toggleCourseSelection(category.id, course.id),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.blueAccent,
                  checkColor: Colors.white,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Selection'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _fetchCategories();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose specific subjects for your enrollment',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Select Courses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._categories.map(_buildExpandableCategory).toList(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleNext,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
