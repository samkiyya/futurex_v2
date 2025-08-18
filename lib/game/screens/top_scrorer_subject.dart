import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/screens/userRank_screen.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:http/http.dart' as http;

class Subject {
  final String id;
  final String name;
  final String grade;
  final String category;
  final String image;
  final String cid;
  final String curriculumName;
  final String curriculumDescription;
  final String curriculumGrade;

  Subject({
    required this.id,
    required this.name,
    required this.grade,
    required this.category,
    required this.image,
    required this.cid,
    required this.curriculumName,
    required this.curriculumDescription,
    required this.curriculumGrade,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'] ?? "",
      grade: json['grade'] ?? " ",
      category: json['category'] ?? " ",
      image: json['image'] ?? "",
      cid: json['cid'] ?? "",
      curriculumName: json['curriculum_name'] ?? "",
      curriculumDescription: json['curriculum_description'] ?? "",
      curriculumGrade: json['curriculum_grade'] ?? "",
    );
  }
}

class TopScorerBySubject extends StatefulWidget {
  @override
  _TopScorerBySubjectState createState() => _TopScorerBySubjectState();
}

class _TopScorerBySubjectState extends State<TopScorerBySubject> {
  late Future<List<Subject>> futureSubjects;
  final network = new Networks();

  @override
  void initState() {
    super.initState();
    futureSubjects = fetchSubjects();
  }

  Future<List<Subject>> fetchSubjects() async {
    final response = await http.get(
      Uri.parse(network.gurl + '/game_subject/get_subjects'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['subjects'];
      return data.map((json) => Subject.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load subjects');
    }
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
      body: FutureBuilder<List<Subject>>(
        future: futureSubjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('please try again!'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No subjects found'));
          } else {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Subject to View Top Scorers',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose a subject to see the top 10 students ranked by their exam scores',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  ...snapshot.data!.map((subject) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserRankScreen(
                                subjectId: subject.id,
                                name: subject.name,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                network.gurl + '/' + subject.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              subject.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Grade ${subject.grade} - ${subject.curriculumDescription} Curriculum',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}
