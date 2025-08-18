class QuestionByLevel {
  final int id;
  final String question;
  final int subjectId;
  final String passage;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String answer;
  final String explanation;
  final String time;
  final String level;
  final String category;
  final String image;
  final String expimage;
  final int chapter;

  QuestionByLevel({
    required this.id,
    required this.question,
    required this.subjectId,
    required this.passage,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.answer,
    required this.explanation,
    required this.time,
    required this.level,
    required this.category,
    required this.image,
    required this.expimage,
    required this.chapter,
  });

  factory QuestionByLevel.fromJson(Map<String, dynamic> json) {
    return QuestionByLevel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      question: json['question']?.toString() ?? '',
      subjectId: json['subjectId'] is int ? json['subjectId'] : int.tryParse(json['subjectId']?.toString() ?? '0') ?? 0,
      passage: json['passage']?.toString() ?? '',
      optionA: json['A']?.toString() ?? '',
      optionB: json['B']?.toString() ?? '',
      optionC: json['C']?.toString() ?? '',
      optionD: json['D']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      time: json['time']?.toString() ?? '0',
      level: json['level']?.toString() ?? '0',
      category: json['category']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      expimage: json['expimage']?.toString() ?? '',
      chapter: json['chapter'] is int ? json['chapter'] : int.tryParse(json['chapter']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'subjectId': subjectId,
      'passage': passage,
      'A': optionA,
      'B': optionB,
      'C': optionC,
      'D': optionD,
      'answer': answer,
      'explanation': explanation,
      'time': time,
      'level': level,
      'category': category,
      'image': image,
      'expimage': expimage,
      'chapter': chapter.toString(), // Store as string for database
    };
  }
}