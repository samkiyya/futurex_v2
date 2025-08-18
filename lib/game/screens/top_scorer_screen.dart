import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/constants/styles.dart';
import 'package:futurex_app/game/provider/top_scorer_provider.dart';
import 'package:futurex_app/game/screens/user_detail_screen.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/drawer.dart';
import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';

class TopScorer extends StatefulWidget {
  const TopScorer({super.key});

  @override
  State<TopScorer> createState() => _TopScorerState();
}

class _TopScorerState extends State<TopScorer> {
  @override
  void initState() {
    super.initState();
    Provider.of<TopUserProvider>(context, listen: false).fetchTopUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<TopUserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top Scorers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      drawer: const MyDrawer(),
      body: userProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : userProvider.error != null
          ? Center(
              child: ResponsiveImageTextWidget(
                imageUrl: 'assets/images/nointernet.gif',
                text: "Failed to connect. Please try again!",
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 80),
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                final rank = user.rank;
                final avatar = CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                );

                final badgeIcon = _buildRankIcon(rank);

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.topRight,
                          children: [
                            avatar,
                            if (badgeIcon != null)
                              Positioned(top: -4, right: -4, child: badgeIcon),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.full_name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Score: ${user.totalScore}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserScreen(
                                  userId: user.userId,
                                  score: user.totalScore.toString(),
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: const [
                              Text(
                                "Details",
                                style: TextStyle(color: Colors.blue),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => userProvider.fetchTopUsers(),
        child: const Icon(Icons.refresh),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }

  Widget? _buildRankIcon(int rank) {
    if (rank == 1) {
      return _trophyIcon(Colors.blue);
    } else if (rank == 2) {
      return _trophyIcon(Colors.lightBlue);
    } else if (rank == 3) {
      return _trophyIcon(Colors.deepPurple);
    }
    return null;
  }

  Widget _trophyIcon(Color color) {
    return CircleAvatar(
      radius: 10,
      backgroundColor: color,
      child: const Icon(Icons.emoji_events, size: 14, color: Colors.white),
    );
  }
}
