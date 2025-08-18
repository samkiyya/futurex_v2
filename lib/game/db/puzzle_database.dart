import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:futurex_app/game/model/puzzle_model.dart';

class PuzzleDatabase {
  static final PuzzleDatabase _instance = PuzzleDatabase._internal();
  factory PuzzleDatabase() => _instance;
  PuzzleDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'puzzles.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Create subjects table
          await db.execute('''
            CREATE TABLE subjects (
              id INTEGER PRIMARY KEY,
              name TEXT,
              grade TEXT,
              cid TEXT
            )
          ''');
          // Create levels table
          await db.execute('''
            CREATE TABLE levels (
              id INTEGER PRIMARY KEY,
              subjectId INTEGER,
              level INTEGER,
              unit TEXT,
              time INTEGER,
              passing INTEGER,
              FOREIGN KEY (subjectId) REFERENCES subjects(id)
            )
          ''');
          debugPrint('Puzzle database created at $path');
        },
        onOpen: (db) {
          debugPrint('Puzzle database opened: $path');
        },
      );
    } catch (e) {
      debugPrint('Error initializing puzzle database: $e');
      rethrow;
    }
  }

  Future<void> insertSubjectsAndLevels(
    String grade,
    String cid,
    List<Subject> subjects,
  ) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        // Clear existing subjects and levels for this grade and cid
        await txn.delete(
          'levels',
          where:
              'subjectId IN (SELECT id FROM subjects WHERE grade = ? AND cid = ?)',
          whereArgs: [grade, cid],
        );
        await txn.delete(
          'subjects',
          where: 'grade = ? AND cid = ?',
          whereArgs: [grade, cid],
        );

        // Insert subjects and their levels
        for (var subject in subjects) {
          await txn.insert('subjects', {
            'id': subject.id,
            'name': subject.name,
            'grade': grade,
            'cid': cid,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          for (var level in subject.levels) {
            await txn.insert('levels', {
              'id': level.id,
              'subjectId': subject.id,
              'level': level.level,
              'unit': level.unit,
              'time': level.time,
              'passing': level.passing,
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
        debugPrint(
          'Inserted ${subjects.length} subjects and their levels for grade $grade, cid $cid',
        );
      });
    } catch (e) {
      debugPrint('Error inserting subjects and levels: $e');
      throw Exception('Failed to insert subjects and levels: $e');
    }
  }

  Future<List<Subject>> getSubjectsAndLevels(String grade, String cid) async {
    final db = await database;
    try {
      final subjectResults = await db.query(
        'subjects',
        where: 'grade = ? AND cid = ?',
        whereArgs: [grade, cid],
      );
      List<Subject> subjects = [];
      for (var subjectMap in subjectResults) {
        final levelResults = await db.query(
          'levels',
          where: 'subjectId = ?',
          whereArgs: [subjectMap['id']],
        );
        final levels = levelResults
            .map(
              (levelMap) => Level(
                id: levelMap['id'] as int,
                level: levelMap['level'] as int,
                subject: subjectMap['id'] as int,
                unit: levelMap['unit'] as String,
                time: levelMap['time'] as int,
                passing: levelMap['passing'] as int,
              ),
            )
            .toList();
        subjects.add(
          Subject(
            id: subjectMap['id'] as int,
            name: subjectMap['name'] as String,
            levels: levels,
          ),
        );
      }
      debugPrint(
        'Retrieved ${subjects.length} subjects for grade $grade, cid $cid',
      );
      return subjects;
    } catch (e) {
      debugPrint('Error retrieving subjects and levels: $e');
      return [];
    }
  }

  Future<void> clearSubjectsAndLevels(String grade, String cid) async {
    final db = await database;
    try {
      await db.transaction((txn) async {
        await txn.delete(
          'levels',
          where:
              'subjectId IN (SELECT id FROM subjects WHERE grade = ? AND cid = ?)',
          whereArgs: [grade, cid],
        );
        await txn.delete(
          'subjects',
          where: 'grade = ? AND cid = ?',
          whereArgs: [grade, cid],
        );
        debugPrint('Cleared subjects and levels for grade $grade, cid $cid');
      });
    } catch (e) {
      debugPrint('Error clearing subjects and levels: $e');
    }
  }
}
