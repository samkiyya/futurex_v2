import 'package:shared_preferences/shared_preferences.dart';

class PrefsUtils {
  static Future<bool> getDontShowAgain() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dontShow') ?? false;
  }

  static Future<void> setDontShowAgain(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dontShow', value);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}
