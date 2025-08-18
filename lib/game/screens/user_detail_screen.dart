import 'package:flutter/material.dart';
import 'package:futurex_app/constants/styles.dart';
import 'package:futurex_app/game/model/user_detail_model.dart';
import 'package:futurex_app/game/provider/user_detail_provider.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  final int userId;
  final String score;

  const UserScreen({super.key, required this.score, required this.userId});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserDataProvider>(
      context,
      listen: false,
    ).fetchUserData(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.blue),
              SizedBox(width: 6),
              Text("Back to Top Scorers", style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: userData != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                            'assets/images/logo.png',
                          ), // Change if dynamic
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userData.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Score: ${widget.score}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _infoRow("Grade", userData.grade),
                        _infoRow("Stream", userData.category),
                        _infoRow("School Name", userData.school),
                        _infoRow("Gender", userData.gender),
                        _infoRow("Region", userData.region),
                        _infoRow("Package Type", userData.status),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : _buildError("User detail not found"),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String? error) {
    return Center(
      child: Text(error ?? "Unknown error", style: FuturexStyles.error),
    );
  }
}
