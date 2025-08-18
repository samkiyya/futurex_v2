import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurex_app/game/model/users_score_by-subject_model.dart';
import 'package:http/http.dart' as http;

class UserRankProvider with ChangeNotifier {
  final String apiUrl =
      'https://gameapp.futurexapp.net/gamequestion/all-user-rank/';
  List<UserRank> _userRanks = [];
  bool _loading = false;
  String? _error;

  List<UserRank> get userRanks => _userRanks;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchUserRanks() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _userRanks = data.map((json) => UserRank.fromJson(json)).toList();
        print('API Response: ${response.body}');
      } else {
        _error = 'Failed to load top scorers';
      }
    } catch (e) {
      _error = 'Error: Failed to connect to server please try Again!';
      // print('Error: Failed to connect to server please try Again!');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
