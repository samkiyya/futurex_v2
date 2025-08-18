// user_level_provider.dart
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/model/current_level_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrentUserLevelProvider extends ChangeNotifier {
  final network = new Networks();
  int? _userLevel;

  int? get userLevel => _userLevel;

  Future<void> fetchCurrentUserLevel(int id, int subjectId) async {
    try {
      final response = await http.get(
        Uri.parse(network.baseApiUrl + '/top-user-level/$id/$subjectId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final userLevel = CurrentUserLevel.fromJson(jsonData);
        _userLevel = userLevel.level;
        notifyListeners();
      } else {
        //throw Exception('('Failed to load user level');
      }
    } catch (e) {
      //throw Exception('('Error: ');
    }
  }
}
