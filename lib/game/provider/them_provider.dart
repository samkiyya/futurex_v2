import 'package:flutter/material.dart';
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;
  int _selectedThemeIndex = 0; // 0 for lightTheme, 1 for darkTheme, 2 for customTheme1, 3 for customTheme2

  bool get isDarkMode => _isDarkMode;
  int get selectedThemeIndex => _selectedThemeIndex;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTheme(int themeIndex) {
    _selectedThemeIndex = themeIndex;
    notifyListeners();
  }
}