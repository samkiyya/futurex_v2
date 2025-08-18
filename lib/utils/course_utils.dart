String getGradeKey(String title) {
  String normalizedTitle = title.toLowerCase().trim();

  if (normalizedTitle.contains('solved') ||
      normalizedTitle.contains('entrance') ||
      normalizedTitle.contains('exam')) {
    return 'Solved Entrance Exams';
  }

  if (normalizedTitle.contains('revision') ||
      normalizedTitle.contains('advanced')) {
    return 'Advanced Revision';
  }

  RegExp gradeRegex = RegExp(r'\b(9|10|11|12)\b');
  Match? match = gradeRegex.firstMatch(title);

  if (match != null) {
    return 'Grade ${match.group(0)}';
  }

  return 'General Courses';
}
