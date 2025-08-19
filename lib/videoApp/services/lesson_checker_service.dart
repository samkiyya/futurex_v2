// lesson_service.dart

class LessonCheckerService {
  // Determine lesson type based on provided fields. All inputs are nullable-safe.
  static String getLessonType(
    String? lessonType,
    String? videoType,
    String? link,
    String? attachmentType,
  ) {
    // Google forms / exams
    if (lessonType == 'google' || attachmentType == 'google') {
      return 'exam';
    }

    // Video
    if (lessonType == 'video' ||
        attachmentType == 'video' ||
        videoType == 'system') {
      return 'video';
    }

    // PDF / documents
    if (attachmentType == 'pdf' ||
        lessonType == 'other' ||
        lessonType == 'online' ||
        lessonType == 'pdf') {
      return 'pdf';
    }

    // HTML content
    if (lessonType == 'html' || attachmentType == 'html') {
      return 'html';
    }

    // 3D model
    if (lessonType == '3dmodel') {
      return '3dmodel';
    }

    // Default: fall back to lessonType or empty string
    return lessonType ?? '';
  }
}
