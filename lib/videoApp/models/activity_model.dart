import 'dart:convert';

class Activity {
  final int? id; // Added id field
  final String userId;
  final int courseId;
  final List<String> actions;
  final String sessionStart;
  final String sessionEnd;
  final bool isSynced;

  Activity({
    this.id, // Nullable id
    required this.userId,
    required this.courseId,
    required this.actions,
    required this.sessionStart,
    required this.sessionEnd,
    this.isSynced = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int?, // Include id
      userId: json['user_id'] ?? '',
      courseId: json['course_id'] ?? 0,
      actions: List<String>.from(json['actions'] ?? []),
      sessionStart: json['session_start'] ?? '',
      sessionEnd: json['session_end'] ?? '',
      isSynced: json['is_synced'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include id
      'user_id': userId,
      'course_id': courseId,
      'actions': actions,
      'session_start': sessionStart,
      'session_end': sessionEnd,
      'is_synced': isSynced,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  Activity copyWith({
    int? id,
    String? userId,
    int? courseId,
    List<String>? actions,
    String? sessionStart,
    String? sessionEnd,
    bool? isSynced,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      actions: actions ?? this.actions,
      sessionStart: sessionStart ?? this.sessionStart,
      sessionEnd: sessionEnd ?? this.sessionEnd,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}