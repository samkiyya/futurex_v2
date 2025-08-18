// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:futurex_app/exam/providers/My_Result_provider.dart';
import 'package:futurex_app/exam/providers/exam_provider.dart';
import 'package:futurex_app/exam/providers/question_provider.dart';
import 'package:futurex_app/exam/providers/result_provider.dart';
import 'package:futurex_app/exam/providers/subject_provider.dart';
import 'package:futurex_app/forum/provider/comment_provider.dart';
import 'package:futurex_app/forum/provider/discusssion_provider.dart';

import 'package:futurex_app/forum/provider/postCommnetProvider.dart';
import 'package:futurex_app/forum/provider/post_provider.dart';
import 'package:futurex_app/forum/provider/reply_provider.dart';
import 'package:futurex_app/forum/provider/testimonial_provider.dart';
import 'package:futurex_app/game/provider/chapter_provider.dart';
import 'package:futurex_app/game/provider/current_level_provider.dart';
import 'package:futurex_app/game/provider/curriculumGradeProvider.dart';
import 'package:futurex_app/game/provider/curriculum_provider.dart';
import 'package:futurex_app/game/provider/level_info_provider.dart';
import 'package:futurex_app/game/provider/puzzle_provider.dart';
import 'package:futurex_app/game/provider/question_by_level_provider.dart';
import 'package:futurex_app/game/provider/rank_user_provider.dart';
import 'package:futurex_app/game/provider/save_userlevel_provider.dart';
import 'package:futurex_app/game/provider/score_rank_level_provider.dart';
import 'package:futurex_app/game/provider/top_scorer_provider.dart';
import 'package:futurex_app/game/provider/trial_result_provider.dart';
import 'package:futurex_app/game/provider/user_detail_provider.dart';
import 'package:futurex_app/game/provider/users_score_by_subject_provider.dart';
import 'package:futurex_app/game/screens/users_score_by_subject_screen.dart';
import 'package:futurex_app/videoApp/provider/activity_provider.dart';
import 'package:futurex_app/videoApp/provider/banner_provider.dart';
import 'package:futurex_app/videoApp/provider/blog_comment_provider.dart';
import 'package:futurex_app/videoApp/provider/blog_provider.dart';
import 'package:futurex_app/videoApp/provider/like_provider.dart';
import 'package:futurex_app/videoApp/provider/online_course_provide.dart';
import 'package:futurex_app/videoApp/provider/order_provider.dart';
import 'package:futurex_app/commonScreens/splashscreen.dart';
import 'package:futurex_app/videoApp/provider/home_course_provider.dart';
import 'package:futurex_app/videoApp/provider/themProvider.dart';
import 'package:futurex_app/videoApp/provider/export_provider.dart';
import 'package:futurex_app/videoApp/provider/offline_lesson_provide.dart';
import 'package:media_kit/media_kit.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

//final _noScreenshot = NoScreenshot.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // Disable screenshot and screen recording globally
  // await _noScreenshot.screenshotOff();

  // Initialize OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('32ef0435-91cb-4b7c-8627-49f5b5eb47bc');
  OneSignal.Notifications.requestPermission(true);
  // Load initial theme preference

  // Run the appwait
  runApp(
    MultiProvider(
      providers: [
        //BlogProvider
        ChangeNotifierProvider(create: (_) => BlogProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => OfflineLessonProvider()),
        ChangeNotifierProvider(create: (_) => SectionProvider()),
        ChangeNotifierProvider(create: (_) => OnlineCourseProvider()),
        ChangeNotifierProvider(create: (_) => HomeCourseProvider()),
        ChangeNotifierProvider(create: (_) => CurriculumProvider()),
        ChangeNotifierProvider(create: (_) => PuzzleProvider()),
        ChangeNotifierProvider(create: (_) => QuestionByLevelProvider()),
        ChangeNotifierProvider(create: (_) => ChapterProvider()),
        ChangeNotifierProvider(create: (_) => UserLevelProvider()),
        ChangeNotifierProvider(create: (_) => StudentLevelProvider()),
        ChangeNotifierProvider(create: (_) => CurrentUserLevelProvider()),
        ChangeNotifierProvider(create: (_) => UserRankScoreProvider()),
        ChangeNotifierProvider(create: (_) => TopUserProvider()),
        ChangeNotifierProvider(create: (_) => AdditionalInfoProvider()),
        ChangeNotifierProvider(create: (_) => TrialResultProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => UserRankProvider()),
        ChangeNotifierProvider(create: (_) => CurriculumGradeProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(
          create: (context) => UserRankbySubjectProvider(),
        ),
        ChangeNotifierProvider(create: (context) => TotalScoreProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // exam providers
        ChangeNotifierProvider(create: (context) => SubjectProvider()),
        ChangeNotifierProvider(create: (context) => ExamProvider()),
        ChangeNotifierProvider(create: (context) => ResultProvider()),
        ChangeNotifierProvider(create: (context) => QuestionProvider()),
        ChangeNotifierProvider(create: (context) => ResultFetchProvider()),

        //  forum provider
        ChangeNotifierProvider(create: (context) => TestimonialProvider()),
        ChangeNotifierProvider(create: (context) => ReplyProvider("")),
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => ForumCommentProvider()),
        ChangeNotifierProvider(create: (context) => PostCommentProvider()),
        ChangeNotifierProvider(create: (context) => DiscussionProvider()),
      ],
      child:
          Futurex(), // Ensure `Futurex` widget exists and is correctly implemented
    ),
  );
}

class Futurex extends StatefulWidget {
  const Futurex({super.key});

  @override
  _FuturexState createState() => _FuturexState();
}

class _FuturexState extends State<Futurex> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start the timer when the app is opened
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool canGoBack(context) {
    if (Navigator.canPop(context)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flutter Theme Demo',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
