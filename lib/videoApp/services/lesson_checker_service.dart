// lesson_service.dart

class LessonCheckerService {
  // Function to determine lesson type based on lessonType, videoType, and link
  static String getLessonType(String? lessonType, String? videoType, String? link,String attachment_type) {
    
     // Check if the link is not null and not empty
   if (lessonType=="google"|| attachment_type=="google") {
    return 'exam'; // Use a separate type to handle Google Forms or quizzes
  }
    // Check if the lesson type is "video" or video type is "system"
    else if (lessonType == 'video' || attachment_type=="video") {
      return 'video'; // If it's a video lesson
    }

   

    // Check if the lesson type is "other", "online", or "pdf"
    else if ( attachment_type=="pdf"|| lessonType == 'other' || lessonType == 'online' || lessonType == 'pdf') {
      return 'pdf'; // If it's a PDF document
    }

    // Check if the lesson type is "html"
    else if (lessonType == 'html' || attachment_type=="html" ) {
      return 'html'; // If it's an HTML document
    }
     else if (lessonType == '3dmodel' ) {
      return '3dmodel'; // If it's an HTML document
    }

    // Default return if none of the conditions match
   else  return lessonType.toString();
  }
}
