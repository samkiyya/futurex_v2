// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:futurex_app/game/provider/save_userlevel_provider.dart';

import 'package:futurex_app/videoApp/screens/home_screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late double screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _startApp() async {
    // Sync local results
    final provider = Provider.of<UserLevelProvider>(context, listen: false);
    try {
      await provider.sendLocalResults();
      print('Local results synced successfully');
    } catch (e) {
      print('Error syncing local results: $e');
    }

    // Check connectivity for HomeScreen
    bool isOnline = await _checkConnectivity();

    // Navigate to HomeScreen after a short delay to show splash screen
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userId: '', // Replace with actual userId if available
            isOnline: isOnline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: screenHeight,
          width: screenWidth,
          color: const Color.fromARGB(255, 9, 134, 192),
          child: Image.asset(
            'assets/images/logo.gif',
            height: screenHeight,
            width: screenWidth,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
