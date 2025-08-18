import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'results.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE results (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              userId TEXT,
              level INTEGER,
              score INTEGER,
              subjectId INTEGER,
              grade TEXT,
              cid TEXT,
              status INTEGER
            )
          ''');
          debugPrint('Database created at $path');
        },
        onOpen: (db) {
          debugPrint('Database opened: $path');
        },
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> insertResult(Map<String, dynamic> result) async {
    final db = await database;
    try {
      if (result['userId'] == null || result['userId'].toString().isEmpty) {
        debugPrint('Error: userId is null or empty');
        throw Exception('Invalid userId');
      }
      if (result['level'] == null || result['subjectId'] == null || result['grade'] == null || result['cid'] == null) {
        debugPrint('Error: Missing required fields in result: $result');
        throw Exception('Missing required fields');
      }

      final existingResults = await db.query(
        'results',
        where: 'userId = ? AND subjectId = ? AND level = ? AND grade = ? AND cid = ?',
        whereArgs: [
          result['userId'],
          result['subjectId'],
          result['level'],
          result['grade'],
          result['cid'],
        ],
      );

      if (existingResults.isEmpty) {
        await db.insert('results', result, conflictAlgorithm: ConflictAlgorithm.replace);
        debugPrint('Inserted new result: $result');
      } else {
        await db.update(
          'results',
          result,
          where: 'userId = ? AND subjectId = ? AND level = ? AND grade = ? AND cid = ?',
          whereArgs: [
            result['userId'],
            result['subjectId'],
            result['level'],
            result['grade'],
            result['cid'],
          ],
        );
        debugPrint('Updated existing result: $result');
      }
    } catch (e) {
      debugPrint('Error inserting result: $e');
      throw Exception('Failed to insert result: $e');
    }
  }

  Future<void> deleteResult(int id) async {
    final db = await database;
    try {
      await db.delete('results', where: 'id = ?', whereArgs: [id]);
      debugPrint('Deleted result with id: $id');
    } catch (e) {
      debugPrint('Error deleting result: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await database;
    try {
      final results = await db.query('results');
      debugPrint('Retrieved ${results.length} results from database');
      return results;
    } catch (e) {
      debugPrint('Error retrieving results: $e');
      return [];
    }
  }

  Future<void> clearResults() async {
    final db = await database;
    try {
      await db.delete('results');
      debugPrint('Cleared all results from database');
    } catch (e) {
      debugPrint('Error clearing results: $e');
    }
  }

  Future<int> getHighestPassedLevel(String userId, int subjectId) async {
  final db = await database;
  try {
    final List<Map<String, dynamic>> results = await db.query(
      'results',
      columns: ['level'],
      where: 'userId = ? AND subjectId = ? AND status = ?',
      whereArgs: [userId, subjectId, 1],
      orderBy: 'level DESC',
      limit: 1,
    );
    if (results.isNotEmpty) {
      debugPrint('Highest passed level for user $userId, subject $subjectId: ${results.first['level']}');
      return results.first['level'] as int;
    }
    debugPrint('No passed levels found for user $userId, subject $subjectId');
    return 0; // <-- Fixed: return 0 if no passed level found (user never played)
  } catch (e) {
    debugPrint('Error getting highest passed level: $e');
    return 0; // <-- Fixed: treat error as no progress
  }
}
}