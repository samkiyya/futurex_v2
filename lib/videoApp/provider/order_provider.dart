import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider with ChangeNotifier {
  Order _order = Order(full_name: '', phone: '', type: '', bank_name: '');

  Order get order => _order;

  void updateUserInfo(String fullName, String phoneNumber) {
    _order.phone = fullName;
    _order.phoneNumber = phoneNumber;
    notifyListeners();
  }

  void setEnrollmentType(String type) {
    _order.type = type;
    notifyListeners();
  }

  void setCategories(List<String> categories) {
    _order.selectedCategories = categories;
    notifyListeners();
  }

  void setCourses(List<String> courses) {
    _order.selectedCourses = courses;
    notifyListeners();
  }

  void setScreenshot(File screenshot) {
    _order.screenshot = screenshot;
    notifyListeners();
  }

  void reset() {
    _order = Order(full_name: '', phone: '', type: '', bank_name: '');
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') != null &&
        prefs.getString('userId')!.isNotEmpty;
  }
}
