import 'package:flutter/foundation.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRankScoreProvider extends ChangeNotifier {
  final network = new Networks();
  List<Map<String, dynamic>> _data = [];

  List<Map<String, dynamic>> get data => _data;

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse(network.baseApiUrl + '/all-user-rank'),
    );
    final extractedData = json.decode(response.body) as List<dynamic>;
    _data = extractedData.cast<Map<String, dynamic>>();
    notifyListeners();
  }
}
