import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'video_metadata.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE videos (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            duration TEXT NOT NULL,
            path TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertVideo(Map<String, dynamic> video) async {
    final db = await database;
    return await db.insert('videos', video,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> fetchVideos() async {
    final db = await database;
    return await db.query('videos');
  }

  Future<int> deleteVideo(String id) async {
    final db = await database;
    return await db.delete('videos', where: 'id = ?', whereArgs: [id]);
  }
}
