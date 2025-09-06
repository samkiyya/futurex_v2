import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
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
    final dio = Dio();
    final res = await dio.get(
      url,
      options: Options(responseType: ResponseType.json),
    );
    print('[UploadService] response status: ${res.statusCode}');
    if (res.statusCode != 200) {
      print('[UploadService] fetch failed body: ${res.data}');
      throw Exception('Failed to fetch uploads status=${res.statusCode}');
    }

    final Map<String, dynamic> body = res.data is Map<String, dynamic>
        ? (res.data as Map<String, dynamic>)
        : json.decode(res.data.toString()) as Map<String, dynamic>;
    print('[UploadService] fetch body: $body');
    final List data = body['data'] as List? ?? [];
    final uploads = data
        .map((e) => UploadModel.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final u in uploads) {
      await UploadDb().insertOrReplace(u);
    }

    return uploads;
  }

  Future<String> downloadIfNeeded(
    UploadModel u, {
    void Function(double percent)? onProgress,
  }) async {
    if (u.localPath != null && await File(u.localPath!).exists()) {
      print(
        '[UploadService] downloadIfNeeded: using cached localPath=${u.localPath} for id=${u.id}',
      );
      onProgress?.call(100);
      return u.localPath!;
    }

    if (u.fileExists == false) {
      print(
        '[UploadService] fileExists=false for id=${u.id}, aborting download',
      );
      throw Exception('File does not exist on server');
    }

    // Run in the same isolate to allow progress callbacks and platform channels.
    return await _downloadAndSave(
      u,
      BaseUrls.adminService,
      onProgress: onProgress,
    );
  }

  static Future<String> _downloadAndSave(
    UploadModel u,
    String base, {
    void Function(double)? onProgress,
  }) async {
    final remotePath = '$base/${u.htmlFilePath}';
    print('[UploadService] downloadIfNeeded: GET $remotePath');
    final dio = Dio();
    final res = await dio.get<List<int>>(
      remotePath,
      options: Options(responseType: ResponseType.bytes),
    );
    print('[UploadService] download status: ${res.statusCode}');
    if (res.statusCode != 200 || res.data == null) {
      print('[UploadService] download failed body length: ${res.data?.length}');
      throw Exception('Failed to download html file status=${res.statusCode}');
    }

    final dir = await getApplicationDocumentsDirectory();
    final htmlName = u.htmlFilePath.split('/').last;
    final htmlDir = Directory('${dir.path}/html_game_${u.id}');
    if (!await htmlDir.exists()) await htmlDir.create(recursive: true);

    final htmlBytes = res.data!;
    final htmlString = utf8.decode(htmlBytes);

    final RegExp attrRe = RegExp(
      r'''(?:href|src)\s*=\s*["']([^"']+)["']''',
      caseSensitive: false,
    );
    final matches = attrRe.allMatches(htmlString);
    final assetUrls = <String>{};
    for (final m in matches) {
      final url = m.group(1);
      if (url == null) continue;
      final t = url.trim();
      if (t.isEmpty ||
          t.contains(r'${') ||
          t.contains('course_thumbnails') ||
          t.contains('polyfill.io'))
        continue;
      if (t.startsWith('data:') ||
          t.startsWith('mailto:') ||
          t.startsWith('javascript:'))
        continue;
      assetUrls.add(t);
    }

    String htmlPath = u.htmlFilePath;
    String dirPath = '';
    final lastSlash = htmlPath.lastIndexOf('/');
    if (lastSlash != -1) dirPath = htmlPath.substring(0, lastSlash);

    int doneBytes = 0;
    int totalBytes = htmlBytes.length;

    final assetList = <Map<String, String>>[];
    for (final asset in assetUrls) {
      String remote;
      if (asset.startsWith('http')) {
        remote = asset;
      } else if (asset.startsWith('/')) {
        remote = '$base$asset';
      } else {
        remote = '$base/${dirPath.isNotEmpty ? (dirPath + '/') : ''}$asset';
      }
      assetList.add({
        'remote': remote,
        'asset': asset,
        'local': asset.split('/').last,
      });
      try {
        final head = await dio.head(remote);
        final cl = head.headers.map['content-length']?.first;
        if (head.statusCode == 200 && cl != null) {
          totalBytes += int.tryParse(cl) ?? 20000;
        } else {
          totalBytes += 20000;
        }
      } catch (e) {
        print('[UploadService] error probing asset $remote: $e');
        totalBytes += 20000;
      }
    }

    if (!await htmlDir.exists()) await htmlDir.create(recursive: true);

    for (final info in assetList) {
      final remote = info['remote']!;
      final localName = info['local']!;
      final outFile = File('${htmlDir.path}/$localName');
      try {
        final tempPath = outFile.path;
        int baseDone = doneBytes; // bytes completed before this asset
        await dio.download(
          remote,
          tempPath,
          onReceiveProgress: (received, total) {
            // When total is -1 we still compute using received
            final current = baseDone + (received > 0 ? received : 0);
            final percent = totalBytes > 0 ? (current / totalBytes * 100) : 0.0;
            onProgress?.call(percent.clamp(0.0, 100.0));
          },
          options: Options(receiveTimeout: const Duration(seconds: 60)),
        );
        // Update done bytes after file saved (best effort using length)
        if (await outFile.exists()) {
          doneBytes = baseDone + (await outFile.length());
        }
      } catch (e) {
        print('[UploadService] error downloading asset $remote: $e');
      }
    }

    String rewritten = htmlString;
    for (final info in assetList) {
      final asset = info['asset']!;
      final localName = info['local']!;
      rewritten = rewritten.replaceAll('"$asset"', '"$localName"');
      rewritten = rewritten.replaceAll("'$asset'", "'$localName'");
    }

    final localHtml = File('${htmlDir.path}/$htmlName');
    await localHtml.writeAsString(rewritten, flush: true);
    doneBytes += localHtml.lengthSync();
    final finalPercent = totalBytes > 0
        ? (doneBytes / totalBytes * 100)
        : 100.0;
    onProgress?.call(finalPercent.clamp(0.0, 100.0));

    u.localPath = localHtml.path;
    await UploadDb().insertOrReplace(u);
    print('[UploadService] downloaded and saved to ${localHtml.path}');
    return localHtml.path;
  }

  Future<void> deleteLocal(UploadModel u) async {
    if (u.localPath == null) return;
    final dir = File(u.localPath!).parent;
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
      u.localPath = null;
      await UploadDb().insertOrReplace(u);
      print('[UploadService] deleted local files for id=${u.id}');
    } catch (e) {
      print('[UploadService] deleteLocal error: $e');
    }
  }
}
