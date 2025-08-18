import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/curriculumGradeProvider.dart';
import 'package:futurex_app/game/screens/Grade_list_screen.dart';
import 'package:futurex_app/game/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradeSelectionPage extends StatelessWidget {
  void _showGradeSelectionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GradeSelectionModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Grade')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showGradeSelectionModal(context),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Select Grade'),
        ),
      ),
    );
  }
}

class GradeSelectionModal extends StatelessWidget {
  const GradeSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Select Grade:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GradeSelectionButtons(),
          ],
        ),
      ),
    );
  }
}

class GradeSelectionButtons extends StatefulWidget {
  const GradeSelectionButtons({super.key});

  @override
  State<GradeSelectionButtons> createState() => _GradeSelectionButtonsState();
}

class _GradeSelectionButtonsState extends State<GradeSelectionButtons> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedGradeRange == null || _selectedGradeRange == '9-12') ...[
          GradeButton(grade: 9),
          const SizedBox(height: 10),
          GradeButton(grade: 10),
          SizedBox(height: 10),
          GradeButton(grade: 11),
          const SizedBox(height: 10),
          GradeButton(grade: 12),
          const SizedBox(height: 20),
          GradeButton(grade: 0, isAllGrades: true),
        ] else if (_selectedGradeRange == '7-8') ...[
          GradeButton(grade: 7),
          const SizedBox(height: 10),
          GradeButton(grade: 8),
        ],
      ],
    );
  }
}

class GradeButton extends StatelessWidget {
  final int grade;
  final bool isAllGrades;

  GradeButton({required this.grade, this.isAllGrades = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Provider.of<CurriculumGradeProvider>(
          context,
          listen: false,
        ).fetchCurriculum(grade);
        Navigator.pop(context);
        isAllGrades
            ? Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameAppScreen()),
              )
            : Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GradeListScreen()),
              );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(isAllGrades ? 'All Grades' : 'Grade $grade'),
    );
  }
}
