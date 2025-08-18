import 'dart:convert';
import 'package:futurex_app/videoApp/models/activity_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ActivityDb {
  static final ActivityDb instance = ActivityDb._init();
  static Database? _database;

  ActivityDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('activity.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE activities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  course_id INTEGER NOT NULL,
  actions TEXT NOT NULL,
  session_start TEXT NOT NULL,
  session_end TEXT NOT NULL,
  is_synced INTEGER NOT NULL
)
''');
  }

  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    return await db.insert('activities', {
      'user_id': activity.userId,
      'course_id': activity.courseId,
      'actions': jsonEncode(activity.actions),
      'session_start': activity.sessionStart,
      'session_end': activity.sessionEnd,
      'is_synced': activity.isSynced ? 1 : 0,
    });
  }

  Future<List<Activity>> getUnsyncedActivities() async {
    final db = await database;
    final result = await db.query(
      'activities',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return result
        .map(
          (json) => Activity.fromJson({
            'id': json['id'],
            'user_id': json['user_id'],
            'course_id': json['course_id'],
            'actions': jsonDecode(json['actions'] as String),
            'session_start': json['session_start'],
            'session_end': json['session_end'],
            'is_synced': (json['is_synced'] as int) == 1,
          }),
        )
        .toList();
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'activities',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteActivity(int id) async {
    final db = await database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
