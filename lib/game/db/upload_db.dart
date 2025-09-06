import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:futurex_app/game/model/upload_model.dart';

class UploadDb {
  static final UploadDb _instance = UploadDb._internal();
  factory UploadDb() => _instance;
  UploadDb._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'uploads.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE uploads (
          id INTEGER PRIMARY KEY,
          title TEXT,
          htmlFilePath TEXT,
          createdAt TEXT,
          updatedAt TEXT,
          fileExists INTEGER,
          localPath TEXT,
          onlineUrl TEXT
        )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE uploads ADD COLUMN onlineUrl TEXT');
        }
      },
    );
  }

  Future<void> insertOrReplace(UploadModel m) async {
    final database = await db;
    await database.insert(
      'uploads',
      m.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UploadModel>> getAll() async {
    final database = await db;
    final res = await database.query('uploads');
    return res.map((e) => UploadModel.fromMap(e)).toList();
  }

  Future<void> deleteAll() async {
    final database = await db;
    await database.delete('uploads');
  }
}
