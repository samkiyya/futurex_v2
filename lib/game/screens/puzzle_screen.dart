import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/db/user_level_db.dart';
import 'package:futurex_app/game/provider/puzzle_provider.dart';
import 'package:futurex_app/game/provider/save_userlevel_provider.dart';
import 'package:futurex_app/game/screens/puzzle_box.dart';
import 'package:futurex_app/game/screens/question_level_screen.dart';
import 'package:futurex_app/widgets/auth_widgets.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/drawer.dart';
import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:futurex_app/db/result_databse.dart';
import 'dart:async';

// ignore: must_be_immutable
class PuzzleScreen extends StatefulWidget {
  PuzzleScreen({
    super.key,
    required this.grade,
    required this.cid,
    required this.subId,
  });
  String grade;
  String cid;
  int subId;

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late PuzzleProvider puzzleProvider;
  late List<TabController> _tabControllers;
  bool isLoggedIn = false;
  String userId = "";
  final network = Networks();
  bool _debugMode = false;
  final ValueNotifier<int> _downloadNotifier = ValueNotifier(0);

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  int _userLevelRefreshCounter = 0;

  @override
  void initState() {
    super.initState();
    getUserId();
    _tabControllers = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      puzzleProvider = Provider.of<PuzzleProvider>(context, listen: false);
      puzzleProvider.fetchSubjectsAndLevels(widget.grade, widget.cid);
      puzzleProvider.addListener(() {
        if (puzzleProvider.subjects.isNotEmpty) {
          _initializeTabControllers();
        }
      });
      Provider.of<UserLevelProvider>(context, listen: false).addListener(() {
        if (Provider.of<UserLevelProvider>(context, listen: false).error !=
            null) {
          final snackBar = SnackBar(
            content: Text(
              Provider.of<UserLevelProvider>(context, listen: false).error!,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor:
                Provider.of<UserLevelProvider>(
                  context,
                  listen: false,
                ).error!.contains('successfully')
                ? Colors.green
                : Colors.red,
            duration: const Duration(seconds: 3),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    });
    _initialize();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        Provider.of<UserLevelProvider>(
          context,
          listen: false,
        ).sendLocalResults();
      }
    });
  }

  Future<void> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    setState(() {
      isLoggedIn = userId.isNotEmpty;
    });
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      isLoggedIn = userId.isNotEmpty;
    });
  }

  void _initializeTabControllers() {
    for (var controller in _tabControllers) {
      controller.dispose();
    }
    _tabControllers.clear();
    for (int i = 0; i < puzzleProvider.subjects.length; i++) {
      _tabControllers.add(
        TabController(
          length: puzzleProvider.subjects[i].levels.length,
          vsync: _CustomTickerProvider(),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _refreshUserLevel(int subjectId) async {
    setState(() {
      _userLevelRefreshCounter++;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    for (var controller in _tabControllers) {
      controller.dispose();
    }
    puzzleProvider.removeListener(() {
      if (puzzleProvider.subjects.isNotEmpty) {
        _initializeTabControllers();
      }
    });
    _downloadNotifier.dispose();
    super.dispose();
  }

  Future<int?> fetchUserLevel(String userId, int subjectId) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      final userLevelDb = UserLevelDatabase();
      int? localLevel = await userLevelDb.getUserLevel(userId, subjectId);
      if (localLevel != null) {
        debugPrint('fetchUserLevel: Found local userLevel=$localLevel');
        return localLevel;
      }

      if (isConnected) {
        final response = await http.get(
          Uri.parse(
            '${network.gurl}/result/get_user_level_data/$userId/$subjectId',
          ),
        );
        print("the user id is $userId and subject id is $subjectId");
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final userLevel = int.tryParse(jsonData['userlevel'].toString()) ?? 0;
          final score = jsonData['score'] != null
              ? double.tryParse(jsonData['score'].toString())
              : null;
          final grade = jsonData['grade']?.toString();

          await userLevelDb.insertOrUpdateUserLevel(
            userId: userId,
            subjectId: subjectId,
            userLevel: userLevel,
            score: score,
            grade: grade,
          );
          debugPrint(
            'fetchUserLevel: API userLevel=$userLevel, stored locally',
          );
          return userLevel;
        } else {
          debugPrint(
            'fetchUserLevel: API error status=${response.statusCode}, returning 0',
          );
          return 0;
        }
      } else {
        debugPrint('fetchUserLevel: Offline and no local value, returning 0');
        return 0;
      }
    } catch (e) {
      debugPrint('fetchUserLevel: error=$e, returning 0');
      return 0;
    }
  }

  Future<void> _showDebugInfo() async {
    final dbHelper = DatabaseHelper();
    final results = await dbHelper.getResults();
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;
    final debugInfo = [
      'User ID: $userId',
      'Connectivity: ${isConnected ? 'Online' : 'Offline'}',
      'Local Results (${results.length}):',
      ...results.map(
        (r) =>
            'Level: ${r['level']}, Subject: ${r['subjectId']}, Score: ${r['score']}, Status: ${r['status'] == 1 ? 'Passed' : 'Failed'}',
      ),
    ].join('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(child: Text(debugInfo)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, int level) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You have not passed Level $level!'),
          content: Text(
            'You cannot access this level. Please play and pass Level $level first by scoring the required marks.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subject Game Levels",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'Fetch Offline Data',
            onPressed: () {
              Provider.of<PuzzleProvider>(
                context,
                listen: false,
              ).fetchSubjectsFromLocal(widget.grade, widget.cid);
            },
          ),
          IconButton(
            icon: Icon(
              _debugMode ? Icons.bug_report : Icons.bug_report_outlined,
            ),
            tooltip: 'Toggle Debug Mode',
            onPressed: () {
              setState(() {
                _debugMode = !_debugMode;
              });
              if (_debugMode) _showDebugInfo();
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Consumer<PuzzleProvider>(
        builder: (context, puzzleProvider, _) {
          if (puzzleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (puzzleProvider.error != null) {
            return ResponsiveImageTextWidget(
              imageUrl: 'assets/images/nointernet.gif',
              text: puzzleProvider.error!,
            );
          } else if (puzzleProvider.subjects.isEmpty) {
            return Center(
              child: ResponsiveImageTextWidget(
                imageUrl: 'assets/images/nodata.gif',
                text: 'No subjects available',
              ),
            );
          } else {
            return DefaultTabController(
              length: puzzleProvider.subjects.length,
              initialIndex: widget.subId == 0
                  ? 0
                  : puzzleProvider.subjects.indexWhere(
                      (subject) => subject.id == widget.subId,
                    ),
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: puzzleProvider.subjects.map((subject) {
                      return Tab(
                        child: Row(
                          children: [
                            const SizedBox(width: 8.0),
                            Text(
                              subject.name.toString(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth < 600
                            ? 4
                            : 5;
                        return TabBarView(
                          children: puzzleProvider.subjects.asMap().entries.map((
                            entry,
                          ) {
                            final subjectIndex = entry.key;
                            final subject =
                                puzzleProvider.subjects[subjectIndex];
                            return FutureBuilder<int?>(
                              key: ValueKey(
                                'userlevel_${subject.id}_$_userLevelRefreshCounter',
                              ),
                              future: fetchUserLevel(userId, subject.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  return ResponsiveImageTextWidget(
                                    imageUrl: 'assets/images/nointernet.gif',
                                    text:
                                        'Failed to connect to the server. Please check your connection.',
                                  );
                                } else {
                                  int userLevel = snapshot.data!;
                                  return ValueListenableBuilder<int>(
                                    valueListenable: _downloadNotifier,
                                    builder: (context, _, __) {
                                      return GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: 3.0,
                                              mainAxisSpacing: 3.0,
                                            ),
                                        itemCount: subject.levels.length,
                                        itemBuilder: (context, index) {
                                          final level = subject.levels[index];
                                          final subjectName = subject.name;
                                          return PuzzleBox(
                                            level: level.level,
                                            userLevel: userLevel,
                                            chapter: level.unit,
                                            subjectId: subject.id,
                                            cid: widget.cid,
                                            grade: widget.grade,
                                            subjectName: subjectName,
                                            time: level.time,
                                            passing: level.passing,
                                            isLoggedIn: isLoggedIn,
                                            onTap: () async {
                                              if (!isLoggedIn) {
                                                AuthUtils.showLoginPrompt(
                                                  context,
                                                );
                                                return;
                                              }
                                              if (level.level > userLevel &&
                                                  level.level != 1) {
                                                _showDialog(
                                                  context,
                                                  level.level - 1,
                                                );
                                                return;
                                              }
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          QuestionByLevelScreen(
                                                            subjectId:
                                                                subject.id,
                                                            level: level.level,
                                                            chapter: level.unit,
                                                            time: level.time,
                                                            passing:
                                                                level.passing,
                                                            grade: widget.grade,
                                                            cid: widget.cid,
                                                            subjectName:
                                                                subjectName,
                                                          ),
                                                    ),
                                                  );
                                              if (result == true) {
                                                await _refreshUserLevel(
                                                  subject.id,
                                                );
                                              }
                                            },
                                            onDownloadSuccess: () {
                                              _downloadNotifier.value++;
                                            },
                                            showDialogCallback: (int level) =>
                                                _showDialog(context, level),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
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

class _CustomTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
