import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/curriculumGradeProvider.dart';
import 'package:futurex_app/game/screens/puzzle_screen.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradeListScreen extends StatefulWidget {
  const GradeListScreen({super.key});

  @override
  State<GradeListScreen> createState() => _GradeListScreenState();
}

class _GradeListScreenState extends State<GradeListScreen> {
  String? _selectedGradeRange;

  @override
  void initState() {
    super.initState();
    // Load stored grade range
    _loadGradeRange();
  }

  // Load the saved grade range from shared_preferences
  Future<void> _loadGradeRange() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGradeRange = prefs.getString('gradeRange');
    });
  }

  // Filter curriculums based on stored grade range
  List<String> _getAllowedGrades() {
    if (_selectedGradeRange == '7-8') {
      return ['7', '8'];
    } else {
      // Default case: gradeRange is null or '9-12'
      return ['9', '10', '11', '12'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curriculum'), centerTitle: true),
      body: Consumer<CurriculumGradeProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter curriculums based on allowed grades
          final allowedGrades = _getAllowedGrades();
          final filteredCurriculums = dataProvider.curriculums
              .where(
                (curriculum) =>
                    allowedGrades.contains(curriculum.curriculum_grade),
              )
              .toList();

          if (filteredCurriculums.isEmpty) {
            return ResponsiveImageTextWidget(
              imageUrl: 'assets/images/nodata.gif',
              text: 'No curriculums available for selected grades.',
            );
          }

          return ListView.builder(
            itemCount: filteredCurriculums.length,
            itemBuilder: (context, index) {
              final curriculum = filteredCurriculums[index];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PuzzleScreen(
                          grade: curriculum.curriculum_grade,
                          cid: curriculum.id.toString(),
                          subId: 0,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      curriculum.name,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    subtitle: Text(
                      "${curriculum.description} Curriculum",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 2,
      ),
    );
  }
}
