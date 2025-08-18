import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  final dio = Dio();
  // Get the local directory to save files
  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    return directory.path;
  }

  // Download the file and save it locally
  Future<String?> downloadPDFFile({
    required String url,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      final path = await getLocalPath(); // Get the local path for saving files
      final filePath = '$path/$fileName'; // Full file path
      await dio.download(
        processPdfUrl(url),
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress); // Update progress callback
          }
        },
      );
      // Return the file path if successful
      return filePath;
    } on DioException {
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if the file exists locally
  static Future<bool> fileExists(String fileName) async {
    final path = await getLocalPath();
    final file = File('$path/$fileName');
    return file.exists();
  }

  static String processPdfUrl(String pdfName) {
    String baseUrl = 'https://111.21.27.29.futurex.et/uploads/lesson_files/';
    if (!pdfName.startsWith(baseUrl)) {
      pdfName = baseUrl + pdfName;
    }

    if (pdfName.endsWith('.1')) {
      pdfName = '${pdfName.substring(0, pdfName.length - 2)}.pdf';
    }

    return pdfName;
  }
}
