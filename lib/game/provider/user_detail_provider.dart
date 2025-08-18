import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurex_app/game/model/user_detail_model.dart';
import 'package:http/http.dart' as http;

class UserDataProvider extends ChangeNotifier {
  UserData? _userData;
  String? _error;

  UserData? get userData => _userData;
  String? get error => _error;

  Future<void> fetchUserData(int userId) async {
    final url = Uri.parse(
      'https://111.21.27.29.futurex.et/futurexbackend/users/getUser/$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _userData = UserData.fromJson(data);
        _error = null;
      } else {
        _userData = null;
        _error = 'Failed to load user data';
      }
    } catch (e) {
      _userData = null;
      _error = 'Error: Failed to connect to server please try Again!';
    } finally {
      notifyListeners();
    }
  }
}
