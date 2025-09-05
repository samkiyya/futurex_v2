import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:futurex_app/constants/base_urls.dart';
import 'package:futurex_app/game/db/upload_db.dart';
import 'package:futurex_app/game/model/upload_model.dart';

class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  Future<List<UploadModel>> fetchUploads() async {
    final url = '${BaseUrls.adminService}/api/uploads';
    print('[UploadService] fetchUploads: GET $url');
    final res = await http.get(Uri.parse(url));
    print('[UploadService] response status: ${res.statusCode}');
    if (res.statusCode != 200) {
      print('[UploadService] fetch failed body: ${res.body}');
      throw Exception('Failed to fetch uploads status=${res.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(res.body);
    print('[UploadService] fetch body: $body');
    final List data = body['data'] as List? ?? [];
    final uploads = data
        .map((e) => UploadModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // persist to local db
    for (final u in uploads) {
      await UploadDb().insertOrReplace(u);
    }

    return uploads;
  }

  Future<String> downloadIfNeeded(UploadModel u) async {
    // if localPath exists and file found, return it
    if (u.localPath != null && await File(u.localPath!).exists()) {
      print(
        '[UploadService] downloadIfNeeded: using cached localPath=${u.localPath} for id=${u.id}',
      );
      return u.localPath!;
    }

    final base = BaseUrls.adminService;
    final remotePath = '${base}/${u.htmlFilePath}';
    print('[UploadService] downloadIfNeeded: GET $remotePath');

    final res = await http.get(Uri.parse(remotePath));
    print('[UploadService] download status: ${res.statusCode}');
    if (res.statusCode != 200) {
      print('[UploadService] download failed body: ${res.body}');
      throw Exception('Failed to download html file status=${res.statusCode}');
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = u.htmlFilePath.split('/').last;
    final local = File('${dir.path}/$fileName');
    await local.writeAsBytes(res.bodyBytes);
    print('[UploadService] downloaded and saved to ${local.path}');

    u.localPath = local.path;
    await UploadDb().insertOrReplace(u);

    return local.path;
  }
}
