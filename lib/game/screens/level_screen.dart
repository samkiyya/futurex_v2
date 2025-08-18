import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';

import 'package:futurex_app/game/model/student_level_model.dart';

import 'package:futurex_app/game/provider/level_info_provider.dart';
import 'package:futurex_app/widgets/bottomNav.dart';

import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserLevelScreen extends StatefulWidget {
  final String userId;

  UserLevelScreen({required this.userId});

  @override
  _UserLevelScreenState createState() => _UserLevelScreenState();
}

class _UserLevelScreenState extends State<UserLevelScreen> {
  final network = new Networks();
  int totalScore = 0;
  String name = "";
  String phone = "";
  String userId = "";
  @override
  void initState() {
    super.initState();
    // Fetch user level when the page loads
    fetchData();
    fetchUserTotalMark(widget.userId);
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('first_name') ?? '';
    phone = prefs.getString('last_name') ?? '';
  }

  // get user total mark
  Future<void> fetchUserTotalMark(id) async {
    final response = await http.get(
      Uri.parse(network.baseApiUrl + '/user-total-score/9072/'),
    ); // Replace with your API URL

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        totalScore = data['total_score'];
      });
    } else {
      totalScore = 0;
    }
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    await Provider.of<StudentLevelProvider>(
      context,
      listen: false,
    ).fetchUserLevel(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Provider.of<StudentLevelProvider>(
        context,
      ).fetchUserLevel(widget.userId),
      builder: (context, snapshot) {
        final studentLevelProvider = Provider.of<StudentLevelProvider>(context);
        if (studentLevelProvider.userLevelList.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('No Data available ')),
            body: ResponsiveImageTextWidget(
              imageUrl: 'assets/images/nodata.gif',
              text: 'No data available',
            ),
          );
        }
        if (studentLevelProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading....')),
            body: CircularProgressIndicator(),
          );
        }
        final List<UserLevel> userLevels = studentLevelProvider.userLevelList;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue, // Add a background color
            title: Row(
              // Customize the title
              children: [
                Icon(Icons.person), // Add an icon
                SizedBox(width: 8), // Add some spacing
                Text('my results for subjects'), // Add the title text
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                  // Make the DataTable responsive
                  child: SingleChildScrollView(
                    // Wrap the DataTable in a SingleChildScrollView
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('Result')),
                        DataColumn(label: Text('Level')),
                      ],
                      rows: userLevels.map((userLevel) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${userLevel.name}')),
                            DataCell(Text('${userLevel.score}')),
                            DataCell(Text('${userLevel.level}')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNav(
            onTabSelected: (index) {},
            currentSelectedIndex: 2,
          ),
        );
      },
    );
  }
}
