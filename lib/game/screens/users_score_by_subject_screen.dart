import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TotalScore {
  final String subjectName;
  final double totalScore;
  final int rank;

  TotalScore({
    required this.subjectName,
    required this.totalScore,
    required this.rank,
  });

  factory TotalScore.fromJson(Map<String, dynamic> json) {
    return TotalScore(
      subjectName: json['subject_name'] as String, // Ensure this is a String
      totalScore: double.parse(
        json['total_score'] as String,
      ), // Parse string to double
      rank: json['rank'] as int, // Parse rank as int
    );
  }
}

class TotalScoreProvider with ChangeNotifier {
  List<TotalScore> _scores = [];
  bool _isLoading = false;
  String _error = '';

  List<TotalScore> get scores => _scores;
  bool get isLoading => _isLoading;
  String get error => _error;
  Future<void> fetchTotalScores(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final url = Uri.parse(
      'https://gamedashboard.futurexapp.net/rank/getStudentScores/$userId',
    );
    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _scores = (jsonResponse as List)
            .map((data) => TotalScore.fromJson(data))
            .toList();
      } else {
        _error = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception: $e');
      _error = 'Failed to connect to server';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class UserRankScoreBySubjectScreen extends StatefulWidget {
  @override
  _UserRankScoreBySubjectScreenState createState() =>
      _UserRankScoreBySubjectScreenState();
}

class _UserRankScoreBySubjectScreenState
    extends State<UserRankScoreBySubjectScreen> {
  List<TotalScore> selectedScores = [];
  String userId = "";

  @override
  void initState() {
    super.initState();
    getUserId().then((_) {
      Provider.of<TotalScoreProvider>(
        context,
        listen: false,
      ).fetchTotalScores(userId);
    });
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  void _shareSelectedResults() {
    if (selectedScores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one result to share.")),
      );
      return;
    }

    double totalScore = selectedScores.fold(
      0,
      (sum, item) => sum + item.totalScore,
    );

    String tableContent = selectedScores
        .map((score) {
          return '${score.subjectName.padRight(11)} | ${score.totalScore.toStringAsFixed(2).padRight(5)} | my Rank ${score.rank}';
        })
        .join('\n');

    String message =
        "🔥🔥🔥 አሸነፍኩኝ 💪\n\n"
        "በ FutureX ትምህርታዊ Game ተጫወትኩኝና ምርጥ ውጤት አመጣው!\n\n"
        "❇️ ውጤቴ ይኸውና\n\n"
        "Subject         | Score  \n"
        "-------------------------\n"
        "$tableContent\n"
        "✅ Total Score = ${totalScore.toStringAsFixed(2)}\n\n"
        "FutureX ላይ Game ተጫውተህ በትምህርት ከኔ ጋር መወዳደር ከፈለክ ከታች ያለውን ሊንክ ነክተህ ስልክህ ላይ አፕሊኬሽኑን ጫነውና ጀምር👇\n"
        "https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2";

    Share.share(message, subject: 'Check out Futurex app results!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Results', style: TextStyle(fontSize: 22)),
        actions: [
          ElevatedButton(
            onPressed: _shareSelectedResults,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "Share Selected Result",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<TotalScoreProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (provider.error.isNotEmpty) {
              return Center(
                child: Text(
                  provider.error,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            } else {
              return _buildTable(provider.scores);
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }

  Widget _buildTable(List<TotalScore> scores) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color?>((
            Set<MaterialState> states,
          ) {
            return Colors.blueAccent.withOpacity(0.2);
          }),
          columnSpacing: 30,
          dataRowHeight: 60,
          columns: const [
            DataColumn(
              label: Text(
                'Subject ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Total Score',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Rank',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: scores.map((score) {
            final isSelected = selectedScores.contains(score);
            return DataRow(
              selected: isSelected,
              onSelectChanged: (selected) {
                setState(() {
                  if (selected ?? false) {
                    selectedScores.add(score);
                  } else {
                    selectedScores.remove(score);
                  }
                });
              },
              cells: [
                DataCell(
                  Text(score.subjectName, style: TextStyle(fontSize: 16)),
                ),
                DataCell(
                  Text(
                    score.totalScore.toStringAsFixed(2),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                DataCell(
                  Text(score.rank.toString(), style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
