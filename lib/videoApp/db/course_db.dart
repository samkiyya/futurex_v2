import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class CourseDatabaseHelper {
  static final CourseDatabaseHelper _instance = CourseDatabaseHelper._internal();
  factory CourseDatabaseHelper() => _instance;
  CourseDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'courses.db');
  return await openDatabase(
    path,
    version: 2,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE courses (
          id INTEGER PRIMARY KEY,
          title TEXT,
          short_description TEXT,
          description TEXT,
          outcomes TEXT,
          language TEXT,
          category_id INTEGER,
          section TEXT,
          requirements TEXT,
          price TEXT,
          discount_flag INTEGER,
          discounted_price TEXT,
          thumbnail TEXT,
          localThumbnailPath TEXT,
          video_url TEXT,
          is_top_course INTEGER,
          status TEXT,
          video TEXT,
          is_free_course INTEGER,
          multi_instructor INTEGER,
          creator TEXT,
          createdAt TEXT,
          updatedAt TEXT,
          like_count INTEGER,
          comment_count INTEGER,
          category TEXT
        )
      ''');
      debugPrint('Course database created at $path');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Check if localThumbnailPath column exists
        final columns = await db.rawQuery('PRAGMA table_info(courses)');
        final hasLocalThumbnailPath = columns.any((column) => column['name'] == 'localThumbnailPath');

        if (!hasLocalThumbnailPath) {
          await db.execute('ALTER TABLE courses ADD COLUMN localThumbnailPath TEXT');
          debugPrint('Added localThumbnailPath column');
        } else {
          debugPrint('localThumbnailPath column already exists, skipping ALTER TABLE');
        }
      }
    },
  );
}
Future<int> insertCourses(List<Map<String, dynamic>> courses) async {
  int insertedCount = 0;

  try {
    final db = await database;
    await db.delete('courses'); // Clear existing data
    Batch batch = db.batch();

    for (var course in courses) {
      // Validate required fields
      if (!course.containsKey('id') || !course.containsKey('title')) {
        debugPrint('⚠️ Skipping invalid course: $course');
        continue;
      }

      // Normalize fields
      course['outcomes'] = course['outcomes'] is String
          ? course['outcomes']
          : (course['outcomes'] != null ? jsonEncode(course['outcomes']) : '[]');
      course['section'] = course['section'] is String
          ? course['section']
          : (course['section'] != null ? jsonEncode(course['section']) : '[]');
      course['requirements'] = course['requirements'] is String
          ? course['requirements']
          : (course['requirements'] != null ? jsonEncode(course['requirements']) : '[]');
      course['category'] = course['category'] is String
          ? course['category']
          : (course['category'] != null ? jsonEncode(course['category']) : null);
      course['discount_flag'] = course['discount_flag'] is bool
          ? (course['discount_flag'] ? 1 : 0)
          : course['discount_flag'] ?? 0;
      course['is_top_course'] = course['is_top_course'] is bool
          ? (course['is_top_course'] ? 1 : 0)
          : course['is_top_course'] ?? 0;
      course['is_free_course'] = course['is_free_course'] is bool
          ? (course['is_free_course'] ? 1 : 0)
          : course['is_free_course'] ?? 0;
      course['multi_instructor'] = course['multi_instructor'] is bool
          ? (course['multi_instructor'] ? 1 : 0)
          : course['multi_instructor'] ?? 0;
      course['localThumbnailPath'] = course['localThumbnailPath'] ?? null;

      debugPrint('🟢 Adding course to batch: ${course['title']}');
      batch.insert('courses', course, conflictAlgorithm: ConflictAlgorithm.replace);
      insertedCount++;
    }

    await batch.commit(noResult: true);
    debugPrint('✅ Inserted $insertedCount courses into DB');
    return insertedCount;
  } catch (e, stack) {
    debugPrint('❌ Error inserting courses: $e');
    debugPrint('Course Insert Error');
    rethrow;
  }
}

  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final db = await database;
      final courses = await db.query('courses');
      debugPrint('Queried ${courses.length} courses from db');
      return courses;
    } catch (e, stack) {
      debugPrint('Error querying courses: $e');
      return [];
    }
  }

  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete('courses');
      debugPrint('Database cleared');
    } catch (e, stack) {
      debugPrint('Error clearing database: $e');
    }
  }
}