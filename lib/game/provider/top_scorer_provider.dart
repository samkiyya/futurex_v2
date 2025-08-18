import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/model/top_scorer_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopUserProvider extends ChangeNotifier {
  final network = new Networks();
  List<TopUser> _users = [];
  bool _loading = false;
  String? _error;

  List<TopUser> get users => _users;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchTopUsers() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(network.baseApiUrl + '/top-scorer-user/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _users = data.map((json) => TopUser.fromJson(json)).toList();
      } else {
        _error = 'Failed to load users';
      }
    } catch (e) {
      _error = 'Error: Failed to connect to server please try Again!';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

class AdditionalInfoProvider extends ChangeNotifier {
  AdditionalInfo? _additionalInfo;
  bool _loading = false;
  String? _error;

  AdditionalInfo? get additionalInfo => _additionalInfo;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchAdditionalInfo(String userId) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          'https://111.21.27.29.futurex.et/futurexbackend/users/getUser/$userId',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _additionalInfo = AdditionalInfo.fromJson(data);
        print("success");
      } else {
        _error = 'Failed to load additional info';
      }
    } catch (e) {
      _error = 'Error: Failed to connect to server please try Again!';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
