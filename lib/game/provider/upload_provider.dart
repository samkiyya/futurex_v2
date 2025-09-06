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
  final Map<int, double> progress = {};

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final local = await UploadDb().getAll();
      print('[UploadProvider] load() immediate DB: ${local.length} items');
      uploads = local;
      notifyListeners();
    } catch (e) {
      print('[UploadProvider] load() DB error: $e');
    }
    try {
      print('[UploadProvider] loading from network...');
      final net = await _service.fetchUploads();
      print('[UploadProvider] loaded ${net.length} uploads from network');
      uploads = net;
      error = null;
    } catch (e) {
      error = e.toString();
      print('[UploadProvider] network load failed: $e');
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
    progress[u.id] = 0.0;
    notifyListeners();
    try {
      final path = await _service.downloadIfNeeded(
        u,
        onProgress: (p) {
          progress[u.id] = p;
          notifyListeners();
        },
      );
      print(
        '[UploadProvider] downloadOne saved path=$path progress=${progress[u.id]}',
      );
      u.localPath = path;
      await UploadDb().insertOrReplace(u);
    } catch (e) {
      error = e.toString();
      print('[UploadProvider] downloadOne error: $e');
    }
    downloading[u.id] = false;
    progress[u.id] = 100.0;
    notifyListeners();
  }

  Future<void> deleteLocal(UploadModel u) async {
    try {
      await UploadService().deleteLocal(u);
      final idx = uploads.indexWhere((e) => e.id == u.id);
      if (idx != -1) {
        uploads[idx] = u;
      }
      notifyListeners();
    } catch (e) {
      print('[UploadProvider] deleteLocal error: $e');
    }
  }
}
