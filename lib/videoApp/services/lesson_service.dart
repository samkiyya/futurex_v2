import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:futurex_app/db/video_database.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';

class LessonService {
  static Future<void> _saveStreamToFile(
    YoutubeExplode yt,
    StreamInfo stream,
    String filePath,
    Function(double) onProgress,
  ) async {
    final client = yt.videos.streamsClient;
    final file = File(filePath);
    final writer = file.openWrite();
    final total = stream.size.totalBytes;
    int received = 0;
    await for (final chunk in client.get(stream)) {
      writer.add(chunk);
      received += chunk.length;
      if (total > 0) {
        final progress = (received / total).clamp(0.0, 1.0);
        onProgress(progress);
      }
    }
    await writer.close();
  }

  static const _secureStorage = FlutterSecureStorage();

  static Future<String> _getFilePath(
    String videoId,
    String fileExtension,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$videoId.$fileExtension';
  }

  static Future<bool> isFileDownloaded(String videoId) async {
    try {
      final storedPath = await _secureStorage.read(key: videoId);
      if (storedPath != null) {
        final file = File(storedPath);
        return file.existsSync();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<StreamInfo>> fetchVideoStreams(String url) async {
    final yt = YoutubeExplode();
    try {
      final videoId = VideoId(url).value;
      final manifest = await yt.videos.streams.getManifest(videoId);
      final muxedMp4 = manifest.muxed.where(
        (s) => s.container.name.toLowerCase() == 'mp4',
      );
      final videoOnlyMp4 = manifest.videoOnly.where(
        (s) => s.container.name.toLowerCase() == 'mp4',
      );
      final Map<String, StreamInfo> unique = {};
      for (final s in [...muxedMp4, ...videoOnlyMp4]) {
        unique[s.qualityLabel] = s;
      }
      final all = unique.values.toList();
      all.sort((a, b) {
        final qa =
            int.tryParse(a.qualityLabel.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final qb =
            int.tryParse(b.qualityLabel.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return qb.compareTo(qa);
      });
      return all;
    } catch (e) {
      return [];
    } finally {
      yt.close();
    }
  }

  static Future<bool> downloadVideoFile({
    required String videoId,
    required String url,
    required String videoTitle,
    required Function(double) onProgress,
    required StreamInfo selectedStream,
  }) async {
    if (url.isEmpty) {
      print('downloadVideoFile aborted: empty URL');
      return false;
    }
    print(
      'downloadVideoFile started: videoId=$videoId, url=$url, selectedStream=$selectedStream',
    );
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(videoId);
      print(
        'Fetched video info: title=${video.title}, duration=${video.duration}',
      );
      String videoFilePath = '';
      if (selectedStream is MuxedStreamInfo) {
        print('Downloading muxed stream: ${selectedStream.url}');
        final fileExtension = selectedStream.container.name;
        videoFilePath = await _getFilePath(videoId, fileExtension);
        await _saveStreamToFile(yt, selectedStream, videoFilePath, onProgress);
        print('Downloaded muxed file to $videoFilePath');
      } else if (selectedStream is VideoOnlyStreamInfo) {
        print('Downloading video-only stream: ${selectedStream.url}');
        final fileExtension = selectedStream.container.name;
        final videoPath = await _getFilePath(videoId, 'video.$fileExtension');
        final manifest = await yt.videos.streams.getManifest(videoId);
        final bestAudio = manifest.audioOnly
            .where(
              (a) =>
                  a.container.name.toLowerCase() == 'mp4' ||
                  a.container.name.toLowerCase() == 'm4a',
            )
            .toList()
            .fold<AudioOnlyStreamInfo?>(
              null,
              (prev, curr) =>
                  prev == null || curr.bitrate.compareTo(prev.bitrate) > 0
                  ? curr
                  : prev,
            );
        final audioExt = bestAudio?.container.name ?? 'm4a';
        final audioPath = await _getFilePath(videoId, 'audio.$audioExt');
        await _saveStreamToFile(
          yt,
          selectedStream,
          videoPath,
          (p) => onProgress(p * 0.7),
        );
        print('Downloaded video-only file to $videoPath');
        if (bestAudio != null) {
          print('Downloading audio-only stream: ${bestAudio.url}');
          await _saveStreamToFile(
            yt,
            bestAudio,
            audioPath,
            (p) => onProgress(0.7 + p * 0.3),
          );
          print('Downloaded audio-only file to $audioPath');
        }
        print('Merging streams via FFmpeg');
        final mergedPath = await _getFilePath(videoId, 'mp4');
        final ffmpegCmd =
            '-y -i "$videoPath" -i "$audioPath" -c copy "$mergedPath"';
        final session = await FFmpegKit.execute(ffmpegCmd);
        print('FFmpeg merge session started');
        final returnCode = await session.getReturnCode();
        if (returnCode == null || returnCode.getValue() != 0) {
          final logs = await session.getAllLogsAsString();
          print('FFmpeg logs: $logs');
          throw Exception(
            'FFmpeg merge failed with return code ${returnCode?.getValue()}',
          );
        }
        try {
          await File(videoPath).delete();
        } catch (_) {}
        try {
          await File(audioPath).delete();
        } catch (_) {}
        videoFilePath = mergedPath;
        print('Merged file created at $mergedPath');
      } else {
        final fileExtension = selectedStream.container.name;
        videoFilePath = await _getFilePath(videoId, fileExtension);
        await _saveStreamToFile(yt, selectedStream, videoFilePath, onProgress);
      }
      await _secureStorage.write(key: videoId, value: videoFilePath);
      print('Stored path in secure storage: $videoFilePath');
      final dbHelper = DatabaseHelper();
      await dbHelper.insertVideo({
        'id': videoId,
        'title': videoTitle,
        'duration': video.duration.toString(),
        'path': videoFilePath,
      });
      print('Download and insert completed successfully for $videoId');
      return true;
    } catch (e, st) {
      print('downloadVideoFile exception: $e');
      print('Stack trace: $st');
      return false;
    } finally {
      print('Closing YoutubeExplode instance');
      yt.close();
    }
  }

  static Future<String?> getSecurePath(String videoId) async {
    try {
      return await _secureStorage.read(key: videoId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteFile(String videoId, BuildContext context) async {
    try {
      final storedPath = await _secureStorage.read(key: videoId);
      if (storedPath != null) {
        final file = File(storedPath);
        if (await file.exists()) {
          await file.delete();
        }
        await _secureStorage.delete(key: videoId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<Map<String, String>> getAllDownloadedFiles() async {
    try {
      final allEntries = await _secureStorage.readAll();
      final downloadedFiles = <String, String>{};
      for (var entry in allEntries.entries) {
        final file = File(entry.value);
        if (await file.exists()) {
          downloadedFiles[entry.key] = entry.value;
        }
      }
      return downloadedFiles;
    } catch (e) {
      return {};
    }
  }

  static Future<VideoPlayerController?> getOfflineVideoController(
    String videoId,
  ) async {
    try {
      final path = await _secureStorage.read(key: videoId);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final controller = VideoPlayerController.file(file);
          await controller.initialize();
          return controller;
        }
      }
    } catch (e) {
      print('Error initializing offline video controller: $e');
    }
    return null;
  }
}
