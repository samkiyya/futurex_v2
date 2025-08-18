// models/puzzle_model.dart

class Level {
  final int id;
  final int level;
  final int subject;
  final int time;
  final int passing;
   final String unit;
  Level({required this.id, required this.level,required this.subject,required this.time,required this.passing,required this.unit});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      level: json['level'],
      subject: json['subject'],
      time:json['time']?? 0,
      passing:json['passing']?? 0 ,
      unit:json['unit']?? "",
    );
  }
}

class Subject {
  final int id;
  final String name;
  final List<Level> levels;

  Subject({required this.name, required this.id, required this.levels});
  factory Subject.fromJson(Map<String, dynamic> json) {
    final List<dynamic> levelsData = json['levels'];
    final List<Level> levels = levelsData.map((levelJson) => Level.fromJson(levelJson)).toList();

    return Subject(
      id:json['subject']['id'],
      name: json['subject']['name'],
      levels: levels,
    );
  }
}
