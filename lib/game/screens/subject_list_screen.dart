// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurex_app/game/model/subject_model.dart';
import 'package:futurex_app/game/screens/users_score_by_subject_screen.dart';
import 'package:futurex_app/widgets/drawer.dart';
import 'package:http/http.dart' as http;

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  _SubjectListScreenState createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  late List<Subject> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/subject/subject-list/'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      subjects = data.map((json) => Subject.fromJson(json)).toList();
      setState(() {});
    } else {
      //throw Exception('('Failed to fetch subjects');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (subjects == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Score of students by Subjects')),
        drawer: MyDrawer(),
        body: ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return ListTile(
              title: Text(subject.name),
              subtitle: Text(
                'Grade: ${subject.grade}, stream: ${subject.category}',
              ),
              leading: Image.network(
                "https://gameapp.futurexapp.net/${subject.image}",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserRankScoreBySubjectScreen(),
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
}

class SubjectDetailsScreen extends StatelessWidget {
  final Subject subject;

  const SubjectDetailsScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      drawer: MyDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Grade: ${subject.grade}'),
            Text('Category: ${subject.category}'),
            Image.network(subject.image),
          ],
        ),
      ),
    );
  }
}
