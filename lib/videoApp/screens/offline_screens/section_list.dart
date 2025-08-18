// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/services/auth_servie.dart';
import 'package:futurex_app/widgets/offline_course_widgets/notEnrolled_modal.dart';
import 'package:futurex_app/videoApp/screens/offline_screens/lessons_screen.dart';
import 'package:futurex_app/videoApp/provider/section_provider.dart';
import 'package:futurex_app/widgets/auth_widgets.dart';
import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:provider/provider.dart';

class SectionList extends StatelessWidget {
  final int courseId;
  final String userId;
  final Function(String)
  onSectionSelected; // New callback for section selection

  const SectionList({
    super.key,
    required this.courseId,
    required this.userId,
    required this.onSectionSelected,
  });

  void _navigateToLessonScreen(
    BuildContext context,
    int sectionId,
    String section,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          sectionId: sectionId,
          section: section,
          isOnline: false,
        ),
      ),
    );
  }

  Future<void> _checkAccessAndNavigate(
    BuildContext context,
    int index,
    int sectionId,
    String section,
  ) async {
    bool isLoggedIn = userId.isNotEmpty;
    if (index != 0 && !isLoggedIn) {
      AuthUtils.showLoginPrompt(context);
      return;
    }
    bool isEnrolled = await AuthService.isCourseEnrolled(courseId);
    if (!isEnrolled && index != 0) {
      showNotEnrolledDialog(context);
    } else {
      onSectionSelected(section); // Call callback to track section title
      _navigateToLessonScreen(context, sectionId, section);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SectionProvider>(
      builder: (context, dataProvider, _) {
        if (dataProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (dataProvider.errorMessage.isNotEmpty) {
          return _buildError(context, dataProvider);
        }
        if (dataProvider.sections.isEmpty) {
          return _buildEmpty(context, dataProvider);
        }
        return _buildList(context, dataProvider);
      },
    );
  }

  Widget _buildError(BuildContext context, SectionProvider dataProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResponsiveImageTextWidget(
          imageUrl: 'assets/images/nodata.gif',
          text:
              "Failed to connect to server. Please check your internet connection or use offline access.",
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () => dataProvider.fetchDataFromLocalStorage(courseId),
          child: const Text(
            'Offline Access',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, SectionProvider dataProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ResponsiveImageTextWidget(
          imageUrl: 'assets/images/nointernet.gif',
          text: "No Data Available for this course",
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => dataProvider.fetchData(courseId),
          child: const Text('Reload'),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, SectionProvider dataProvider) {
    final courseSections = dataProvider.sections.where((section) {
      return section.courseId == courseId;
    }).toList();

    return ListView.builder(
      itemCount: courseSections.length,
      itemBuilder: (context, index) {
        final section = courseSections[index];
        return ListTile(
          leading: const Icon(Icons.book_online, color: Colors.blue),
          title: Text(section.title),
          trailing: const Icon(Icons.arrow_forward, color: Colors.blue),
          onTap: () => _checkAccessAndNavigate(
            context,
            index,
            section.id,
            section.title,
          ),
        );
      },
    );
  }
}
