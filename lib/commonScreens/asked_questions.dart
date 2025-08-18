import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'እንዴት ልጀምር?',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Step 1. መመዝገብ - Register የሚለውን ምልክት በ...',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Step 2. መክፈል - አባል ለመሆን 2999 ብር በኢትዮጵያ ንግድ ባንክ የባንክ...',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'በቀላሉ ማለትም በሞባይል *889# ወይም በ CBE አፕሊኬሽን ወይም በ Tele-Birr ወዲያው መክፈል ይችላሉ።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'የከፈሉበትን በስልኮ Screenshot አርገው ፎቶ ያንሱት።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'በአካል የኢትዮጵያ ንግድ ባንክ ቅርንጫፍ በመሄድ ክፍያውን ገቢ ማድረግ ይችላሉ።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'የከፈሉበትን ደረሰኝ ፎቶ ያንሱት።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Step 3. የከፈሉብትን አሳይተው መጀመር - 0911 07 06 63 በ ሚለው ስልክ ቁጥር በቴሌግራም የከፈሉበትን Screenshot ፎቶ ወይም የደረሰኝ ፎቶ መላክ።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'በተጨማሪም የእርሶን ስምና ስልክ ቁጥር መላክ አይርሱ።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'ልክ ይሄን ሲያደርጉ ወዲያው አባል እንደሆኑ እና ኮርሶቹን መጀመር እንደሚችሉ ወዲያው ቴሌግራም ላይ መልዕክት ይደርሶታል።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Login ብለው ገብተው የፈለጉትን ኮርስ እየከፈቱ ማጥናት ይችላሉ ማለት ነው።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. አንድ ኮርስ መርጦ መግዛት',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('499 ብር ከፍለው የመረጡትን 1 ኮርስ ያገኛሉ'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('ያንን ኮርስ ብቻ Download ማድረግና ያለ ኢንተርኔት ማጥናት ይችላሉ'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('ሌላ ኮርስ ማግኘት ሲፈልጉ ተጨማሪ 499 ይከፍላሉ'),
            ),
            SizedBox(height: 16.0),
            Text(
              '2. አባል መሆንና ሁሉንም ኮርስ ማግኘት',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('2999 ብር ከፍለው አባል ይሆናሉ'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('ሁሉንም ኮርስ ያገኛሉ (አሁን ያሉትንም ወደፊት የሚለቀቁትንም ጨምሮ)'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('ሁሉንም ኮርስ Download ማድረግና ያለ ኢንተርኔት ማጥናት ይችላሉ'),
            ),
            SizedBox(height: 16.0),
            Text(
              'ማስታወሻ:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'የአባልነት ክፍያ ዋጋ በየጊዜው ይጨምራል፤ በ 2999 ብር አባል መሆን የሚቻለው ለአጭር ጊዜ ብቻ ነው።',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class QAScreen extends StatelessWidget {
  const QAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'የተማሪዎች ተደጋጋሚ ጥያቄ',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                '1. ክፍያውን ሌላ ሰው ቢከፍልልኝስ?',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'መልስ፡ ይቻላል፤ ቤተሰብ፣ ዘመድ ወይ ማንኛውም ሰው ሊከፍልልህ ይችላል ዋናው የከፈልክበትን ማሳየትህ ነው',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                '2. አባል ከሆንኩኝ በኋላ ለአዲስ ኮርስ ክፈል እባላለው?',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'መልስ፡ አባል የሆነ ሰው ድጋሚ ምንም ገንዘብ አይከፍልም፤ አሁን ያሉትንም ወደፊት የሚለቀቁትንም ኮርሶች በሙሉ ያገኛል።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                '3. Register ሳደርግ ወይም Login ብዬ ልገባ ስል ቢያስቸግረኝ ምን ላርግ?',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'መልስ፡ 0911 07 06 63 ላይ መደወል ወይም በቴሌግራም ያጋጠመህን በመናገር ወዲያው ችግሩ ይፈታል።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                '4. የምታስጠኑን በአዲሱ ካሪኩለም ነው?',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'መልስ: አዎ፤ ሁሉም ኮርሶች የሚዘጋጁት በአዲሱ ካሪኩለም መሰረት ነው። ለ 12 ኛ ክፍል ማትሪክ ተፈታኞች ደግሞ ከ 11 ክፍል እስከ 9 ክፍል ያሉ አብዛኛው የድሮ ካሪኩለም ቻፕተሮች በአዲሱ ካሪኩለም ላይ አሉ፣ ብዙ ልዩነት የላቸውም ስለዚህ የሚመሳሰሉትን መርጠው እንዲያጠኑ እንመክራለን።',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AskedQuestionScreen extends StatelessWidget {
  const AskedQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Students Questions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'እንዴት ልጀምር'),
              Tab(text: 'የክፍያ አማራጮች'),
              Tab(text: 'ተደጋጋሚ ጥያቄዎች'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StartScreen(),
            PaymentScreen(),
            QAScreen(),
          ],
        ),
      ),
    );
  }
}
