import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/rank_user_provider.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';

class UserRankScreen extends StatefulWidget {
  final String subjectId;
  final String name;

  UserRankScreen({required this.subjectId, required this.name});

  @override
  _UserRankScreenState createState() => _UserRankScreenState();
}

class _UserRankScreenState extends State<UserRankScreen> {
  late UserRankbySubjectProvider _userRankProvider;

  @override
  void initState() {
    super.initState();
    _userRankProvider = Provider.of<UserRankbySubjectProvider>(
      context,
      listen: false,
    );
    _userRankProvider.fetchRanks(widget.subjectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Student Exam Results'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<UserRankbySubjectProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.error,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          if (provider.ranks.isEmpty) {
            return Center(
              child: Text(
                'No ranks available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name + ' Top Scorers',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Showing the top 10 students ranked by their exam scores',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 16),
                ...provider.ranks.take(10).map((rank) {
                  int index = provider.ranks.indexOf(rank);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: _getRankIcon(index + 1),
                        title: Text(
                          '${rank.firstName} ${rank.lastName}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Score: ${double.parse(rank.totalScore).toStringAsFixed(2)}/100',
                        ),
                        trailing: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }

  Widget _getRankIcon(int rank) {
    if (rank == 1) return Icon(Icons.emoji_events, color: Colors.orange);
    if (rank == 2) return Icon(Icons.emoji_events_outlined, color: Colors.grey);
    if (rank == 3) return Icon(Icons.emoji_events_sharp, color: Colors.brown);
    return Container(width: 24, height: 24); // Empty space for other ranks
  }
}
