// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:futurex_app/videoApp/models/section_model.dart';

class SectionProvider with ChangeNotifier {
  final baseApi = Networks();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final Dio _dio = Dio(); // Initialize Dio
  List<Section> _sections = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<Section> get sections => _sections;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchData(int courseId) async {
    bool hasConnection = await _hasConnection();
    _isLoading = true;
    _errorMessage = '';
    final String apiUrl = Networks().sectionAPI + '/sections/course/$courseId/';
    if (hasConnection) {
      try {
        final response = await _dio.get(apiUrl);

        if (response.statusCode == 200) {
          final List<dynamic> jsonData = response.data;

          final List<Section> fetchedSections = jsonData.map((item) {
            final section = Section.fromJson(item);
            return section;
          }).toList();

          _sections = fetchedSections;
          await _storeDataLocally(courseId, fetchedSections);
        } else {
          print("Non-200 status code: ${response.statusCode}");
          _errorMessage =
              'Failed to fetch data. Status code: ${response.statusCode}';
        }
      } catch (e) {
        print("Exception caught: $e");
        if (e is DioException) {
          print(
            "DioException details: ${e.response?.statusCode} - ${e.message}",
          );
          _errorMessage =
              'Request failed: ${e.response?.statusCode} - ${e.message}';
        } else {
          _errorMessage = 'Failed to fetch data. Error: check your connection';
        }
      }

      _isLoading = false;
      notifyListeners();
    } else {
      fetchDataFromLocalStorage(courseId);
    }
  }

  Future<void> _storeDataLocally(int courseId, List<Section> sections) async {
    final List<dynamic> newData = sections
        .map((section) => section.toJson())
        .toList();
    await _secureStorage.write(
      key: 'sections_$courseId',
      value: jsonEncode(newData),
    );
  }

  Future<void> fetchDataFromLocalStorage(int courseId) async {
    _isLoading = true;
    _errorMessage = '';
    print('Fetching for courseId: $courseId');

    try {
      final existingData = await _secureStorage.read(key: 'sections_$courseId');
      print('Raw data: $existingData');
      if (existingData != null) {
        final List<dynamic> jsonData = jsonDecode(existingData);
        print('Decoded JSON: $jsonData');
        final List<Section> storedSections = jsonData
            .map((item) => Section.fromJson(item))
            .toList();
        print('Mapped sections: $storedSections');
        _sections = storedSections;
        print('Assigned _sections: $_sections');
      } else {
        _errorMessage = 'No stored data found for course';
        print(_errorMessage);
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch data from local storage. Error: $e';
      print(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> _hasConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}
