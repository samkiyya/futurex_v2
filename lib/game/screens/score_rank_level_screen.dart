import 'package:flutter/material.dart';

import 'package:futurex_app/game/provider/users_score_by_subject_provider.dart';
import 'package:futurex_app/game/screens/user_detail_screen.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';

class UserRankScoreScreen extends StatefulWidget {
  const UserRankScoreScreen({super.key});

  @override
  State<UserRankScoreScreen> createState() => _UserRankScoreScreenState();
}

class _UserRankScoreScreenState extends State<UserRankScoreScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserRankProvider>(context, listen: false).fetchUserRanks();
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
      body: UserRankTabView(),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}

class UserRankTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userRankProvider = Provider.of<UserRankProvider>(context);

    if (userRankProvider.error != null) {
      return const Center(
        child: Text(
          'Error: Failed to connect to server please try Again!',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    if (userRankProvider.userRanks.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Math Top Scorers',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Showing the top 10 students ranked by their exam scores',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 16),
            ...userRankProvider.userRanks.take(10).map((userRank) {
              int rank = userRankProvider.userRanks.indexOf(userRank) + 1;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: _getRankIcon(rank),
                    title: Text(
                      userRank.userId.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Score: ${userRank.maxScore}/100'),
                    trailing: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        '#$rank',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserScreen(
                            userId: userRank.userId,
                            score: userRank.maxScore.toString(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _getRankIcon(int rank) {
    if (rank == 1) return Icon(Icons.emoji_events, color: Colors.orange);
    if (rank == 2) return Icon(Icons.emoji_events_rounded, color: Colors.grey);
    if (rank == 3) return Icon(Icons.emoji_events_sharp, color: Colors.brown);
    return SizedBox(width: 24, height: 24); // Empty space for other ranks
  }
}
