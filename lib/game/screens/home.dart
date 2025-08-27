import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/curriculum_provider.dart';
import 'package:futurex_app/game/screens/puzzle_screen.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/drawer.dart';
import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:provider/provider.dart';

class GameAppScreen extends StatefulWidget {
  const GameAppScreen({super.key});

  @override
  State<GameAppScreen> createState() => _GameAppScreenState();
}

class _GameAppScreenState extends State<GameAppScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch curriculums
    Future.delayed(Duration.zero, () {
      Provider.of<CurriculumProvider>(
        context,
        listen: false,
      ).fetchCurriculums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curriculums', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'Fetch Offline Data',
            onPressed: () {
              Provider.of<CurriculumProvider>(
                context,
                listen: false,
              ).fetchCurriculumsFromLocal();
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Consumer<CurriculumProvider>(
        builder: (context, curriculumProvider, _) {
          return _buildBody(curriculumProvider);
        },
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 2,
      ),
    );
  }

  Widget _buildBody(CurriculumProvider curriculumProvider) {
    if (curriculumProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (curriculumProvider.error != null) {
      return ResponsiveImageTextWidget(
        imageUrl: 'assets/images/nointernet.gif',
        text: curriculumProvider.error!,
      );
    } else if (curriculumProvider.curriculums.isEmpty) {
      return ResponsiveImageTextWidget(
        imageUrl: 'assets/images/nodata.gif',
        text: 'No curriculums available.',
      );
    } else {
      return ListView.builder(
        itemCount: curriculumProvider.curriculums.length,
        itemBuilder: (context, index) {
          final curriculum = curriculumProvider.curriculums[index];
          return InkWell(
            child: Container(
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
            ),
          );
        },
      );
    }
  }
}
