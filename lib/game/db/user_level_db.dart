import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserLevelDatabase {
  static final UserLevelDatabase _instance = UserLevelDatabase._internal();
  factory UserLevelDatabase() => _instance;
  UserLevelDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_levels.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_levels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT,
            subjectId INTEGER,
            userLevel INTEGER,
            score REAL,
            grade TEXT
          );
        ''');
      },
    );
  }

  Future<void> insertOrUpdateUserLevel({
    required String userId,
    required int subjectId,
    required int userLevel,
    double? score,
    String? grade,
  }) async {
    final db = await database;
    final existing = await db.query(
      'user_levels',
      where: 'userId = ? AND subjectId = ?',
      whereArgs: [userId, subjectId],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert(
        'user_levels',
        {
          'userId': userId,
          'subjectId': subjectId,
          'userLevel': userLevel,
          'score': score,
          'grade': grade,
        },
      );
    } else {
      await db.update(
        'user_levels',
        {
          'userLevel': userLevel,
          'score': score,
          'grade': grade,
        },
        where: 'userId = ? AND subjectId = ?',
        whereArgs: [userId, subjectId],
      );
    }
  }

  Future<int?> getUserLevel(String userId, int subjectId) async {
    final db = await database;
    final result = await db.query(
      'user_levels',
      where: 'userId = ? AND subjectId = ?',
      whereArgs: [userId, subjectId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['userLevel'] as int;
    }
    return null;
  }
}