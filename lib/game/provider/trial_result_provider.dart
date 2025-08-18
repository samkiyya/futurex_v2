import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/game/model/trial_result_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrialResultProvider with ChangeNotifier {
  final network = new Networks();
  List<TrialResult> _trialData = [];
  String _error = '';
  bool _isLoading = false;

  List<TrialResult> get trialData => _trialData;
  String get error => _error;
  bool get isLoading => _isLoading;
  Future<void> fetchData(String userId) async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';

    try {
      final response = await http.get(
        Uri.parse(network.gurl + '/student_result/trialResult/$userId/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _trialData = data.map((item) => TrialResult.fromJson(item)).toList();
      } else {
        _error = 'Failed to load trial data: ${response.statusCode}';
        print('Error: Failed to connect to server please try Again!');
      }
    } catch (error) {
      _error = 'Error: Failed to connect to server please try Again!';
      //print('Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchResultData(String userId) async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    try {
      final response = await http.get(
        Uri.parse(network.gurl + '/student_result/Result/$userId/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _trialData = data.map((item) => TrialResult.fromJson(item)).toList();
      } else {
        _error = 'Failed to load trial data: ';
        //print('Error: $_error');
      }
    } catch (error) {
      _error = 'Error: Failed to connect to server please try Again!';

      ///print('Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
