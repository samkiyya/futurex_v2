import 'package:flutter/foundation.dart';

import 'package:futurex_app/game/model/upload_model.dart';
import 'package:futurex_app/game/services/upload_service.dart';
import 'package:futurex_app/game/db/upload_db.dart';

class UploadProvider extends ChangeNotifier {
  final UploadService _service = UploadService();
  List<UploadModel> uploads = [];
  bool loading = false;
  String? error;
  final Map<int, bool> downloading = {};

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      print('[UploadProvider] loading from network...');
      uploads = await _service.fetchUploads();
      print('[UploadProvider] loaded ${uploads.length} uploads from network');
    } catch (e) {
      // network failed - fall back to local DB
      error = e.toString();
      print('[UploadProvider] network load failed: $error');
      try {
        print('[UploadProvider] attempting DB fallback');
        final local = await UploadDb().getAll();
        print('[UploadProvider] db returned ${local.length} items');
        if (local.isNotEmpty) {
          uploads = local;
          error = null; // prefer local silently
        }
      } catch (_) {
        // ignore db errors
      }
    }

    loading = false;
    notifyListeners();
  }

  Future<String> getLocalPath(UploadModel u) async {
    print('[UploadProvider] getLocalPath for id=${u.id}');
    return await _service.downloadIfNeeded(u);
  }

  Future<void> downloadOne(UploadModel u) async {
    print('[UploadProvider] downloadOne start id=${u.id}');
    downloading[u.id] = true;
    notifyListeners();
    try {
      final path = await _service.downloadIfNeeded(u);
      print('[UploadProvider] downloadOne saved path=$path');
      u.localPath = path;
      // ensure DB updated
      await UploadDb().insertOrReplace(u);
    } catch (e) {
      // bubble up error via error field
      error = e.toString();
      print('[UploadProvider] downloadOne error: $error');
    }
    downloading[u.id] = false;
    notifyListeners();
  }

  Future<void> downloadAll() async {
    for (final u in uploads) {
      if (u.localPath == null) {
        await downloadOne(u);
      }
    }
  }
}
