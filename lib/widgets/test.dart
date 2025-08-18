// can i send you a code and will you help me refactor it or make it better?

// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:futurex_app/chat_bottom_sheet.dart';
// import 'package:futurex_app/models/course_model.dart';
// import 'package:futurex_app/video/screens/online_course_screen.dart';
// import 'package:futurex_app/video/screens/section_screen.dart';
// import 'package:futurex_app/widgets/auth_widgets.dart';
// import 'package:futurex_app/widgets/bottomNav.dart';
// import 'package:futurex_app/widgets/game_app_widgets/game_drawer.dart';
// import 'package:futurex_app/widgets/home_screen_widgets/course_card.dart';
// import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
// import 'package:provider/provider.dart';
// import '../provider/home_course_provider.dart';

// class OfflineCourseScreen extends StatefulWidget {
//   final String userId;
//   final bool isOnline;

//   const OfflineCourseScreen(
//       {super.key, required this.userId, required this.isOnline});

//   @override
//   State<OfflineCourseScreen> createState() => _OfflineCourseScreenState();
// }

// class _OfflineCourseScreenState extends State<OfflineCourseScreen>
//     with SingleTickerProviderStateMixin {
//   bool _isOnlineMode = true;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _initializeProvider();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeProvider() async {
//     try {
//       final provider = Provider.of<HomeCourseProvider>(context, listen: false);
//       await (widget.isOnline || _isOnlineMode
//           ? provider.fetchCourses()
//           : provider.getCoursesFromStorage());
//       _animationController.forward(); // Start animation after data load
//     } catch (e) {
//       _showErrorSnackBar("Failed to load courses: $e");
//     }
//   }

//   void _startCourse(String courseId, String title) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (_) => SectionScreen(courseId: courseId, course: title)),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: ResponsiveImageTextWidget(
//           imageUrl: 'assets/images/nointernet.gif',
//           text: message,
//         ),
//         backgroundColor: Colors.redAccent.withOpacity(0.9),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       floatingActionButton: _buildChatFab(),
//       drawer: const MyDrawer(),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue.shade50, Colors.white],
//           ),
//         ),
//         child: _buildBody(),
//       ),
//       bottomNavigationBar:
//           BottomNav(onTabSelected: (_) {}, currentSelectedIndex: 2),
//     );
//   }

//   AppBar _buildAppBar() {
//     return AppBar(
//       title: const Text("Offline Courses",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.blue.shade700, Colors.blue.shade900],
//           ),
//         ),
//       ),
//       actions: [
//         Row(
//           children: [
//             _buildAppBarButton('Online', _switchToOnlineMode),
//             const SizedBox(width: 8),
//             _buildAppBarButton('Offline', _refreshOfflineMode),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildAppBarButton(String label, VoidCallback onPressed) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(label,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600)),
//       ),
//     );
//   }

//   Widget _buildChatFab() {
//     return FloatingActionButton(
//       onPressed: () {
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//           builder: (_) => const ChatBottomSheet(),
//         );
//       },
//       backgroundColor: Colors.blueAccent,
//       shape: const CircleBorder(),
//       elevation: 6,
//       child: Image.asset('assets/images/bot.png',
//           fit: BoxFit.cover, height: 32, width: 32),
//     );
//   }

//   Widget _buildBody() {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Consumer<HomeCourseProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading) {
//             return const Center(
//                 child: CircularProgressIndicator(
//                     color: Colors.blueAccent, strokeWidth: 3));
//           }
//           if (provider.courses.isEmpty) {
//             return _buildEmptyState();
//           }
//           return _buildCourseList(provider.courses);
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           ResponsiveImageTextWidget(
//             imageUrl: 'assets/images/nodata.gif',
//             text: "No courses available. Load them online first!",
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _refreshOfflineMode,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blueAccent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               elevation: 4,
//             ),
//             child: const Text('Retry Offline',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCourseList(List<Course> courses) {
//     final categoryCourses = _categorizeCourses(courses);
//     final gradeOrder = ['Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
//     final otherCategories = categoryCourses.keys
//         .where((cat) => !gradeOrder.contains(cat))
//         .toList()
//       ..shuffle();
//     final orderedCategories = [...gradeOrder, ...otherCategories];

//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: ListView.builder(
//         itemCount: orderedCategories.length,
//         itemBuilder: (context, index) {
//           final category = orderedCategories[index];
//           final coursesInCategory = categoryCourses[category] ?? [];
//           if (coursesInCategory.isEmpty) return const SizedBox.shrink();
//           return _buildCategorySection(category, coursesInCategory, index);
//         },
//       ),
//     );
//   }

//   Map<String, List<Course>> _categorizeCourses(List<Course> courses) {
//     final Map<String, List<Course>> categoryCourses = {};
//     for (var course in courses) {
//       final categoryName = course.category?.catagory ?? 'Uncategorized';
//       categoryCourses.putIfAbsent(categoryName, () => []).add(course);
//     }
//     return categoryCourses;
//   }

//   Widget _buildCategorySection(
//       String category, List<Course> courses, int index) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             child: Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 24,
//                   color: Colors.blueAccent,
//                   margin: const EdgeInsets.only(right: 8),
//                 ),
//                 Text(
//                   category,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade900,
//                     shadows: [
//                       Shadow(
//                           color: Colors.blueAccent.withOpacity(0.5),
//                           blurRadius: 4,
//                           offset: const Offset(2, 2)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 280,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: courses.length,
//               itemBuilder: (context, idx) => Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: CourseCard(
//                   course: courses[idx],
//                   onTap: () => _startCourse(
//                       courses[idx].id.toString(), courses[idx].title),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _switchToOnlineMode() async {
//     if (widget.userId.isEmpty) {
//       AuthUtils.showLoginPrompt(context);
//       return;
//     }
//     try {
//       _isOnlineMode = true;
//       await Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => OnlineCourseScreen(userId: widget.userId)));
//     } catch (e) {
//       _showErrorSnackBar("No internet. Please check your connection!");
//     }
//   }

//   void _refreshOfflineMode() async {
//     try {
//       _isOnlineMode = false;
//       await _initializeProvider();
//     } catch (e) {
//       _showErrorSnackBar("No data available. Please retry!");
//     }
//   }
// }
