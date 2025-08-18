import 'dart:convert';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import 'package:futurex_app/videoApp/models/blog_model.dart';

class BlogService {
  Future<List<Blog>> fetchBlogs({String? notificationType}) async {
    final uri = Uri.parse(
      Networks().userAPI + "/notification/broadcast-notifications",
    );
    final response = await http.get(uri);

    print("Fetching blogs from: ${uri.toString()}");

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Filter by notification type if specified
      if (notificationType != null) {
        data = data
            .where((e) => e['notificationType']?['name'] == notificationType)
            .toList();
      }

      return data.map((json) => Blog.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load blogs");
    }
  }
}
