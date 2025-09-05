import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:futurex_app/constants/constants.dart';
import 'package:futurex_app/videoApp/db/course_db.dart';
import 'package:futurex_app/videoApp/db/medea_service.dart';
import 'package:futurex_app/videoApp/models/course_model.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';

class HomeCourseProvider with ChangeNotifier {
  final Dio _dio = Dio();
  final api = Networks();
  final MediaService _mediaService = MediaService();

  List<models.Course> _courses = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  bool _isCategoriesLoading = false;
  String userId = "";
  String _errorMessage = "";
  String _categoriesError = "";

  // Quick lookup by id
  final Map<int, models.Category> _categoryById = {};

  List<models.Course> get courses => _courses;
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isCategoriesLoading => _isCategoriesLoading;
  String get errorMessage => _errorMessage;
  String get categoriesError => _categoriesError;

  models.Category? getCategoryById(int? id) {
    if (id == null) return null;
    return _categoryById[id];
  }

  Future<void> fetchCategories() async {
    _isCategoriesLoading = true;
    _categoriesError = "";
    notifyListeners();

    // Primary working endpoint (misspelled): /api/catagories
    final primaryUrl = '${Networks().courseAPI}/catagories';
    // Secondary newer endpoint
    final secondaryUrl = '${Networks().courseAPI}/categories';
    Response? response;
    try {
      response = await _dio.get(
        primaryUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (_) {
      // Try secondary endpoint
      try {
        response = await _dio.get(
          secondaryUrl,
          options: Options(
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
            headers: {'Accept': 'application/json'},
          ),
        );
      } on DioException catch (e) {
        _categoriesError = 'Unable to load categories. Please try again.';
        _isCategoriesLoading = false;
        developer.log(
          'Category fetch error',
          error: e,
          stackTrace: e.stackTrace,
        );
        notifyListeners();
        return;
      }
    }

    try {
      if (response.statusCode == 200) {
        final raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map<String, dynamic>
                  ? (raw['data'] as List?) ?? (raw['categories'] as List?) ?? []
                  : []);

        _categories = data
            .map((j) => models.Category.fromJson(Map<String, dynamic>.from(j)))
            .toList();
        _categoryById
          ..clear()
          ..addEntries(_categories.map((c) => MapEntry(c.id, c)));
        _categoriesError = "";
      } else {
        _categoriesError = 'Unable to load categories. Please try again.';
      }
    } catch (e, stack) {
      developer.log('Category parse error', error: e, stackTrace: stack);
      _categoriesError = 'Unable to load categories. Please try again.';
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
      debugPrint("Fetching courses for userId: $userId");

      _isLoading = true;
      _errorMessage = "";
      notifyListeners();

      final response = await _dio.get(
        '${Networks().courseAPI}/course',
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      debugPrint("API Response: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<Map<String, dynamic>> courseMaps = [];

        for (var json in jsonList) {
          final courseMap = Map<String, dynamic>.from(json);

          // Inject category display name from fetched categories
          final catIdRaw = courseMap['category_id'];
          final catId = catIdRaw is int
              ? catIdRaw
              : int.tryParse(catIdRaw?.toString() ?? '');
          final matched = getCategoryById(catId);
          if (matched != null) {
            // Normalize to the shape Course.fromJson expects now: 'category'
            courseMap['category'] = {
              'id': matched.id,
              'catagory': matched.catagory,
            };
          }

          if (courseMap['thumbnail'] != null &&
              courseMap['thumbnail'].isNotEmpty) {
            final fileName =
                'course_${courseMap['id']}_${courseMap['thumbnail'].split('/').last}';
            final localPath = await _mediaService.getLocalImagePath(fileName);

            // Check if file already exists
            final fileExists = await _mediaService.imageExists(fileName);

            if (fileExists) {
              debugPrint('📁 Image already exists: $fileName');
              courseMap['localThumbnailPath'] = localPath;
            } else {
              final downloadedPath = await _mediaService.downloadImage(
                courseMap['thumbnail'],
                fileName,
              );
              courseMap['localThumbnailPath'] = downloadedPath;
            }
          }

          courseMaps.add(courseMap);
        }

        _courses = courseMaps
            .map((json) => models.Course.fromJson(json))
            .toList();

        try {
          final inserted = await CourseDatabaseHelper().insertCourses(
            courseMaps,
          );

          if (inserted > 0) {
            debugPrint('✅ Successfully inserted $inserted courses into DB.');
          } else {
            debugPrint('⚠️ No courses were inserted.');
            _errorMessage = 'No new courses were inserted into local DB.';
          }
        } catch (dbError) {
          debugPrint('❌ Database error during insert: $dbError');
          _errorMessage = 'Failed to save courses to local storage: $dbError';
        }

        try {
          final storedCourses = await CourseDatabaseHelper().getCourses();
          debugPrint('📦 Stored courses in DB: ${storedCourses.length}');
        } catch (readError) {
          debugPrint('⚠️ Error reading back from DB: $readError');
          _errorMessage += '\nError reading back from local DB.';
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      _errorMessage = _getErrorMessage(e);
      developer.log('API Error', error: e, stackTrace: e.stackTrace);
    } catch (e, stack) {
      _errorMessage = 'Unexpected error occurred: $e';
      developer.log('Unexpected Error', error: e, stackTrace: stack);
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint(
        "Fetch completed: isLoading=$_isLoading, courses=${_courses.length}, error=$_errorMessage",
      );
    }
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your network';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Try again later';
      case DioExceptionType.receiveTimeout:
        return 'Server is not responding';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode ?? 'unknown'})';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return e.toString();
    }
  }

  Future<void> getCoursesFromStorage() async {
    try {
      debugPrint('Attempting to load courses from local storage');
      final courseMaps = await CourseDatabaseHelper().getCourses();
      debugPrint('Retrieved ${courseMaps.length} courses from DB');
      if (courseMaps.isNotEmpty) {
        _courses = courseMaps
            .map((json) {
              try {
                return models.Course.fromJson(json);
              } catch (e) {
                debugPrint('Error parsing course: $json, Error: $e');
                return null;
              }
            })
            .where((course) => course != null)
            .cast<models.Course>()
            .toList();
        _errorMessage = "";
        debugPrint("Courses loaded from local db: ${_courses.length}");
      } else {
        _courses = [];
        _errorMessage = "No offline courses available";
        debugPrint('No courses found in local DB');
      }
    } catch (e, stack) {
      _errorMessage = 'Error reading courses from local db: $e';
      _courses = [];
      developer.log(
        'Error reading courses from local db',
        error: e,
        stackTrace: stack,
      );
    }
    notifyListeners();
  }
}
