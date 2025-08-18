import 'package:flutter/material.dart';
import 'package:futurex_app/commonScreens/howtoStart.dart';

class EnrollmentDialog {
  static void show(
    BuildContext context, {
    required VoidCallback onLaunchTelegram,
  }) {
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
              const Text("• ዋጋ: 1999 ብር"),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoWithRegistrationScreen(),
                    ),
                  );
                },
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onLaunchTelegram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'የከፈሉበትን ደረሰኝ ይሄንን ተጭነው ይላኩ',
                  style: TextStyle(fontSize: 16),
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
}
