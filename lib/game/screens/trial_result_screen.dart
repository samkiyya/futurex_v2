import 'package:flutter/material.dart';

import 'package:futurex_app/game/provider/trial_result_provider.dart';
import 'package:futurex_app/widgets/bottomNav.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TrialResultScreen extends StatefulWidget {
  @override
  _TrialResultScreenState createState() => _TrialResultScreenState();
}

class _TrialResultScreenState extends State<TrialResultScreen> {
  final TrialResultProvider _trialResultProvider = TrialResultProvider();
  String userId = "";
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen is opened
    getUserId();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _trialResultProvider.fetchData(userId);
    // Call setState to rebuild the UI with the fetched data

    setState(() {});
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trial Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _trialResultProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : _trialResultProvider.error.isNotEmpty
            ? const Center(
                child: Text(
                  "Failed to connect to server please try Again!",
                  style: TextStyle(color: Colors.red),
                ),
              )
            : _buildResultTable(),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }

  Widget _buildResultTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 20.0, // Adjust spacing between columns
          dataRowHeight: 60.0, // Adjust the height of each row
          columns: [
            DataColumn(label: Text('Subject')),
            DataColumn(label: Text('Grade')),
            DataColumn(label: Text('Level')),
            DataColumn(label: Text('Score')),
          ],
          rows: _trialResultProvider.trialData.map((trialResult) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    trialResult.subjectName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Text(
                    "Grade " + trialResult.grade,
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                DataCell(
                  Text(
                    "Level " + trialResult.level.toString(),
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                DataCell(
                  Text(
                    trialResult.score?.toString() ?? '',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
