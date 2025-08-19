import 'dart:convert';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import 'package:futurex_app/videoApp/models/blog_model.dart';

class BlogService {
  Future<List<Blog>> fetchBlogs({String? notificationType}) async {
    final uri = Uri.parse(
      "${Networks().courseAPI}/notifications/broadcast-notifications",
    );
    final response = await http.get(uri);

    print("Fetching blogs from: ${uri.toString()}");

    try {
      // Accept any 2xx status as success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body);

        // Normalize to a List<dynamic>
        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // Common envelope keys
          if (decoded['data'] is List) {
            data = decoded['data'];
          } else if (decoded['notifications'] is List) {
            data = decoded['notifications'];
          } else {
            // Try to find the first List value in the map
            final firstList = decoded.values.firstWhere(
              (v) => v is List,
              orElse: () => null,
            );
            if (firstList is List) {
              data = firstList;
            } else {
              throw Exception(
                'Unexpected JSON structure: expected a List or map containing a List.',
              );
            }
          }
        } else {
          throw Exception('Unexpected JSON payload');
        }

        // Filter by notification type if specified
        if (notificationType != null) {
          data = data
              .where((e) => e['notificationType']?['name'] == notificationType)
              .toList();
        }

        return data.map((json) => Blog.fromJson(json)).toList();
      }

      // Non-2xx response
      print(
        'Failed to load blogs. Status: ${response.statusCode}\nBody: ${response.body}',
      );
      throw Exception('Failed to load blogs: ${response.statusCode}');
    } catch (e) {
      // Provide the response body in the error when possible to help debugging
      try {
        print('Error loading blogs: $e\nResponse body: ${response.body}');
      } catch (_) {}
      rethrow;
    }
  }
}
