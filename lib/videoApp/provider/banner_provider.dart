import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class BannerProvider extends ChangeNotifier {
  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBanners() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(Networks().lessonAPI + '/lessons/banner/all'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        _banners = jsonList.map((item) => BannerModel.fromJson(item)).toList();
      } else {
        _errorMessage =
            'Failed to load banners (Status: ${response.statusCode})';
      }
    } catch (e) {
      // check for network error
      _errorMessage =
          'Failed to load banners please check your network or try again later';
    }

    _isLoading = false;
    notifyListeners();
  }
}

class BannerModel {
  final int id;
  final String banner;
  final String imageUrl;

  BannerModel({required this.id, required this.banner, required this.imageUrl});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      banner: json['banner'] ?? '',
      imageUrl: json['image_path'] ?? '',
    );
  }
}
