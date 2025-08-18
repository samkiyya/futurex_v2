import 'package:dio/dio.dart';
import 'package:futurex_app/constants/constants.dart';
import 'package:futurex_app/videoApp/models/order.dart';
import 'package:futurex_app/videoApp/models/section_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikeResponse {
  final bool success;
  final String message;
  final bool liked;
  final int code;

  LikeResponse({
    required this.success,
    required this.message,
    required this.liked,
    required this.code,
  });
}

class ApiService {
  static const String _baseUrl =
      "https://111.21.27.29.futurex.et/restful/get_banner";
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> fetchBanners() async {
    try {
      final response = await _dio.get(
        Networks().lessonAPI + "/lessons/banner/all",
      );
      if (response.statusCode == 200) {
        return List<dynamic>.from(response.data)
            .map((item) => {'url': "$_baseUrl/uploads/addons/${item['image']}"})
            .toList();
      }
    } catch (e) {
      print("Error fetching banners: $e");
    }
    return [];
  }

  Future<List<Map<String, String>>> fetchComingSoon() async {
    try {
      final response = await _dio.get(
        "$_baseUrl/futurexbackend/course/getComingSoon",
      );
      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        if (jsonResponse['status'] == 'success') {
          return List<dynamic>.from(jsonResponse['data'])
              .map(
                (item) => {
                  'course': item['course'].toString(),
                  'image': item['image'].toString(),
                },
              )
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching coming soon courses: $e");
    }
    return [];
  }

  Future<LikeResponse> toggleLike(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        return LikeResponse(
          success: false,
          message: 'Not logged in',
          liked: false,
          code: 000,
        );
      }

      final response = await _dio.post(
        Networks().courseAPI + '/like',
        data: {'course_id': courseId, 'user_id': userId},
      );

      if (response.statusCode == 200) {
        return LikeResponse(
          success: true,
          message: response.data['message'] ?? 'Course liked',
          liked: response.data['liked'] ?? false,
          code: 200,
        );
      } else if (response.statusCode == 400) {
        return LikeResponse(
          success: false,
          code: 400,
          message: response.data['message'] ?? 'Already liked',
          liked: true, // Course is still liked
        );
      }

      return LikeResponse(
        success: false,
        message: 'Unexpected error',
        liked: false,
        code: 500,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        // Check if the status code is 400 and return the exact server message
        if (e.response!.statusCode == 400) {
          return LikeResponse(
            success: false,
            code: 400,
            message: e.response!.data['message'] ?? 'Bad request',
            liked: false,
          );
        }
      }

      // Handle connection errors separately
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return LikeResponse(
          success: false,
          message: 'Connection Error!',
          liked: false,
          code: 500,
        );
      }

      print("Error toggling like: $e");
      return LikeResponse(
        success: false,
        message: 'Error: ${e.message}',
        liked: false,
        code: 500,
      );
    } catch (e) {
      print("Error toggling like: $e");
      return LikeResponse(
        success: false,
        message: 'Error: $e',
        liked: false,
        code: 500,
      );
    }
  }

  Future<List<Section>> fetchSections(int courseId) async {
    final dio = Dio();

    try {
      final response = await dio.get(
        Networks().sectionAPI + '/sections/course/$courseId',
      );
      print(
        "the course id is $courseId and the url is ${Networks().sectionAPI}/sections/course/$courseId",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Section.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sections');
      }
    } catch (e) {
      throw Exception('Error fetching sections: $e');
    }
  }

  static fetchCategories() {}
  static fetchCourses(String categoryId) {}
  static submitOrder(Order order) {}
}
