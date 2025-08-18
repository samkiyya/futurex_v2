import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/model/student_level_model.dart';
import 'package:http/http.dart' as http;

class StudentLevelProvider extends ChangeNotifier {
  final network = Networks();
  List<UserLevel> _userLevelList = [];
  String? _error;
  bool _isLoading = false;

  List<UserLevel> get userLevelList => _userLevelList;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchUserLevel(String userId) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      'https://gameapp.futurexapp.net/gamequestion/userlevel-by-userid/$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        if (dataList.isNotEmpty) {
          // Map each dynamic data to a UserLevel object
          _userLevelList = dataList
              .map((data) => UserLevel.fromJson(data))
              .toList();
        } else {
          _error = 'Empty response list';
        }
      } else {
        _error = 'Failed to load user level. Status code: ';
      }
    } catch (error) {
      _error = 'Error: Failed to connect to server please try Again!';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
