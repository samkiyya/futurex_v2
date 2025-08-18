import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MediaService {
  final Dio _dio = Dio();

  Future<String?> downloadImage(String imageUrl, String fileName) async {
    try {
      if (imageUrl.isEmpty) {
        debugPrint('Empty image URL provided');
        return null;
      }

      final filePath = await getLocalImagePath(fileName);

      // Create directory if it doesn't exist
      await Directory(path.dirname(filePath)).create(recursive: true);

      await _dio.download(
        imageUrl,
        filePath,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      debugPrint('✅ Image downloaded to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error downloading image: $e');
      return null;
    }
  }

  /// Updated to include `thumbnails` subfolder
  Future<String> getLocalImagePath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, 'thumbnails', fileName);
  }

  Future<bool> imageExists(String fileName) async {
    final filePath = await getLocalImagePath(fileName);
    return File(filePath).exists();
  }
}
