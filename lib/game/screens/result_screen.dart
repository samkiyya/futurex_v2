import 'package:flutter/material.dart';
import 'package:futurex_app/game/model/trial_result_model.dart';
import 'package:futurex_app/game/provider/trial_result_provider.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TrialResultProvider trialResultProvider = TrialResultProvider();
  String userId = "";
  List<TrialResult> selectedResults = [];

  @override
  void initState() {
    super.initState();
    getUserId();
    _fetchData();
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
  }

  Future<void> _fetchData() async {
    await trialResultProvider.fetchResultData(userId);
    setState(() {});
  }

  void _shareResults() {
    if (selectedResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one result to share.")),
      );
      return;
    }

    double totalScore = 0.0;
    String tableContent = '';
    for (var result in selectedResults) {
      totalScore += result.score ?? 0.0;
      tableContent +=
          '${result.subjectName} | Grade ${result.grade} | Level ${result.level} | ${result.score}/10\n';
    }

    String message =
        "🔥🔥🔥 አሸነፍኩኝ 💪\n\n"
        "በ FutureX ትምህርታዊ Game ተጫወትኩኝና ምርጥ ውጤት አመጣው!\n\n"
        "❇️ ውጤቴ ይኸውና\n\n"
        "$tableContent\n"
        "✅ Total Score = ${totalScore.toStringAsFixed(2)}/10\n\n"
        "https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2";

    Share.share(message);
  }

  void _shareAllResults() {
    double totalScore = 0.0;
    String tableContent = '';
    for (var result in trialResultProvider.trialData) {
      totalScore += result.score ?? 0.0;
      tableContent +=
          '${result.subjectName} | Grade ${result.grade} | Level ${result.level} | ${result.score}/10\n';
    }

    String message =
        "🔥🔥🔥 አሸነፍኩኝ 💪\n\n"
        "በ FutureX ትምህርታዊ Game ተጫወትኩኝና ምርጥ ውጤት አመጣው!\n\n"
        "$tableContent\n"
        "✅ Total Score = ${totalScore.toStringAsFixed(2)}/10\n\n"
        "https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2";

    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Results",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _shareResults,
            icon: Icon(Icons.check_circle, color: Colors.green),
            label: Text(
              "Share Selected",
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton.icon(
            onPressed: _shareAllResults,
            icon: Icon(Icons.share, color: Colors.blue),
            label: Text("Share All", style: TextStyle(color: Colors.blue)),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: trialResultProvider.trialData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: trialResultProvider.trialData.length,
              itemBuilder: (context, index) {
                final result = trialResultProvider.trialData[index];
                final isSelected = selectedResults.contains(result);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedResults.remove(result);
                      } else {
                        selectedResults.add(result);
                      }
                    });
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu_book, color: Colors.blueAccent),
                              SizedBox(width: 10),
                              Text(
                                result.subjectName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              if (isSelected)
                                Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              _infoChip(
                                Icons.grade,
                                "Grade",
                                result.grade.toString(),
                                Colors.deepPurple,
                              ),
                              SizedBox(width: 8),
                              _levelChip(result.level),
                              SizedBox(width: 8),
                              _infoChip(
                                Icons.emoji_events,
                                "Score",
                                result.score.toString(),
                                Colors.orange,
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (result.score ?? 0) / 10,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.blue,
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNav(
        currentSelectedIndex: 3,
        onTabSelected: (index) {},
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            "$value",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _levelChip(int? level) {
    Color levelColor;
    switch (level) {
      case 1:
        levelColor = Colors.green;
        break;
      case 2:
        levelColor = Colors.blue;
        break;
      case 3:
        levelColor = Colors.purple;
        break;
      default:
        levelColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Level $level",
        style: TextStyle(color: levelColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
