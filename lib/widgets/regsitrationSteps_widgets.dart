import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationStepsWidget extends StatelessWidget {
  const RegistrationStepsWidget({Key? key}) : super(key: key);
 final String telegramUsername = 'futurexhelp';

  // Function to open Telegram directly to a user message
Future<void> _launchTelegram() async {
  final String telegramAppUrl = 'tg://resolve?domain=$telegramUsername';
  final String telegramWebUrl = 'https://t.me/$telegramUsername';

  if (await canLaunch(telegramAppUrl)) {
    await launch(telegramAppUrl);
  } else if (await canLaunch(telegramWebUrl)) {
    await launch(telegramWebUrl);
  } else {
    throw 'Could not launch Telegram.';
  }
}


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Registration Successful",style: TextStyle(color: const Color.fromARGB(255, 20, 114, 24),fontSize: 23),),
          const Text(
            'እንዴት ልጀምር?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Step 1. መመዝገብ - ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'Register የሚለውን ምልክት በመንካት ፎርሙን ሞልቶ መመዝገብ',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Step 2. መክፈል - ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      'አሁኑኑ ለመጀመር በመረጡት የክፍያ አማራጭ ገንዘቡን በኢትዮጵያ ንግድ ባንክ የባንክ ቁጥር 1000530747445 ገቢ ማድረግ። በቀላሉ ማለትም በሞባይል *889# ወይም በ CBE አፕሊኬሽን ወይም በ Tele-Birr ወዲያው መክፈል ይችላሉ።',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Step 3. የከፈሉብትን አሳይተው መጀመር - ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '0911 07 06 63 በሚለው ስልክ ቁጥር በቴሌግራም የከፈሉበትን Screenshot ፎቶ ወይም የደረሰኝ ፎቶ መላክ። በተጨማሪም የእርሶን ስምና ስልክ ቁጥር መላክ አይርሱ።',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ልክ ይሄን ሲያደርጉ ወዲያው አባል እንደሆኑ እና ኮርሶቹን መጀመር እንደሚችሉ ወዲያው ቴሌግራም ላይ መልዕክት ይደርሶታል። Login ብለው ገብተው የፈለጉትን ኮርስ እየከፈቱ ማጥናት ይችላሉ ማለት ነው። ለማንኛውም ጥያቄና ማብራሪያ በ 0911 07 06 63 ይደውሉ።',
          ),
          ElevatedButton(
      onPressed: _launchTelegram,
      child: Text('Send Recipt  via Telegram and Start'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.blue,
      ),
          )
        ],
      ),
    );
  }
}
