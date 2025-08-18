import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:futurex_app/game/model/question_by_level_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static final Map<String, Database> _databases = {};

  DatabaseHelper._init();

  factory DatabaseHelper(String dbName) {
    _instance ??= DatabaseHelper._init();
    return _instance!;
  }

  Future<Database> getDatabase(String dbName) async {
    if (_databases.containsKey(dbName)) {
      return _databases[dbName]!;
    }
    _databases[dbName] = await _initDB(dbName);
    return _databases[dbName]!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY,
        subjectId INTEGER,
        level TEXT,
        chapter TEXT,
        question TEXT,
        passage TEXT,
        optionA TEXT,
        optionB TEXT,
        optionC TEXT,
        optionD TEXT,
        answer TEXT,
        explanation TEXT,
        time TEXT,
        category TEXT,
        image TEXT,
        expimage TEXT
      )
    ''');
  }

  Future<void> insertQuestions(
    List<QuestionByLevel> questions,
    String dbName,
  ) async {
    final db = await getDatabase(dbName);
    final batch = db.batch();

    for (var question in questions) {
      print(
        'Inserting question ID: ${question.id}, chapter: ${question.chapter}, level: ${question.level}',
      );
      batch.insert('questions', {
        'id': question.id,
        'subjectId': question.subjectId,
        'level': question.level,
        'chapter': question.chapter.toString(), // Store as string
        'question': question.question,
        'passage': question.passage,
        'optionA': question.optionA,
        'optionB': question.optionB,
        'optionC': question.optionC,
        'optionD': question.optionD,
        'answer': question.answer,
        'explanation': question.explanation,
        'time': question.time,
        'category': question.category,
        'image': question.image,
        'expimage': question.expimage,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    print('Inserted ${questions.length} questions into $dbName');
  }

  Future<List<QuestionByLevel>> getQuestions(String dbName) async {
    final db = await getDatabase(dbName);
    final maps = await db.query('questions');
    print('Retrieved ${maps.length} questions from $dbName: $maps');
    return maps
        .map(
          (json) => QuestionByLevel.fromJson({
            'id': json['id'],
            'question': json['question'] ?? '',
            'subjectId': json['subjectId'],
            'passage': json['passage'] ?? '',
            'A': json['optionA'] ?? '',
            'B': json['optionB'] ?? '',
            'C': json['optionC'] ?? '',
            'D': json['optionD'] ?? '',
            'answer': json['answer'] ?? '',
            'explanation': json['explanation'] ?? '',
            'time': json['time']?.toString() ?? '0',
            'level': json['level']?.toString() ?? '0',
            'category': json['category'] ?? '',
            'image': json['image'] ?? '',
            'expimage': json['expimage'] ?? '',
            'chapter':
                json['chapter'], // Pass as string, conversion handled in fromJson
          }),
        )
        .toList();
  }

  Future<void> clearQuestions(String dbName) async {
    final db = await getDatabase(dbName);
    await db.delete('questions');
    print('Cleared questions from $dbName');
  }

  Future<void> close(String dbName) async {
    if (_databases.containsKey(dbName)) {
      await _databases[dbName]!.close();
      _databases.remove(dbName);
    }
  }
}
