import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/howtoStart.dart';
import 'package:futurex_app/videoApp/services/telegram_service.dart';
import 'package:futurex_app/order_screens/course_selections_screen.dart';

void showNotEnrolledDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text(
        'Not Enrolled',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are not enrolled in this course.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "1. አንድ ኮርስ መርጦ መግዛት",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("• 499 ብር ከፍለው የመረጡትን 1 ኮርስ ያገኛሉ"),
            const Text("• ያንን ኮርስ ብቻ Download ማድረግና ያለ ኢንተርኔት ማጥናት ይችላሉ"),
            const Text("• ሌላ ኮርስ ማግኘት ሲፈልጉ ተጨማሪ 499 ይከፍላሉ"),
            const SizedBox(height: 10),
            const Text(
              "2. በክፍል ደረጃችን ያሉ ኮርሶችን ማግኘት",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("• በመረጡት የክፍል ደረጃ ያሉ ትምህርቶችን ያገኛሉ..."),
            const SizedBox(height: 10),
            const Text(
              "3. ሁሉንም ኮርስ ማግኘት",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("• 1999 ብር ከፍለው ሁሉንም ኮርስ ያገኛሉ"),
            const Text("• ዋጋ: 2999 ብር"),
            const SizedBox(height: 10),
            const Text(
              "ማስታወሻ፡ በየጊዜው የዋጋ ጭማሪ ስለሚደረግ ቶሎ ከፍለው ይጀምሩ።",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart, size: 20),
                    SizedBox(width: 8.0),
                    Text(
                      'Purchase Courses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoWithRegistrationScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              child: const Text(
                "አሁን እንዴት ልጀምር?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: TelegramService.launchTelegram,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(8.0),
              ),
              child: const Text(
                'የከፈሉበትን ደረሰኝ ይሄንን ተጭነው ይላኩ',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
