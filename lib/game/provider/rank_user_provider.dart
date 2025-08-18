import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;

class UserRankbySubjectProvider with ChangeNotifier {
  List<UserRank> _ranks = [];
  bool _loading = false;
  String _error = '';

  List<UserRank> get ranks => _ranks;
  bool get loading => _loading;
  String get error => _error;

  Future<void> fetchRanks(String subjectId) async {
    _loading = true;
    notifyListeners();

    final url =
        Networks().gurl +
        '/rank/getRankBySubject/$subjectId'; // Adjust URL if necessary
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status']) {
          final List<dynamic> rankData = data['data'];
          _ranks = rankData.map((json) => UserRank.fromJson(json)).toList();
          _error = '';
        } else {
          _error =
              'No students Taken this Subject be the first to take this subject Game';
        }
      } else {
        _error = 'Failed to load data';
      }
    } catch (e) {
      _error = 'An error occurred: please try again';
    }

    _loading = false;
    notifyListeners();
  }
}

class UserRank {
  final String userId;
  final String totalScore;
  final String rank;
  final String firstName;
  final String lastName;
  final String grade;
  final String school;

  UserRank({
    required this.userId,
    required this.totalScore,
    required this.rank,
    required this.firstName,
    required this.lastName,
    required this.grade,
    required this.school,
  });

  factory UserRank.fromJson(Map<String, dynamic> json) {
    return UserRank(
      userId: json['user_id'] ?? "",
      totalScore: json['total_score'] ?? "",
      rank: json['rank'] ?? "",
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      grade: json['grade'] ?? "",
      school: json['school'] ?? "",
    );
  }
}

class RankingResponse {
  final bool status;
  final String message;
  final List<UserRank> data;

  RankingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RankingResponse.fromJson(Map<String, dynamic> json) {
    return RankingResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => UserRank.fromJson(item))
              .toList() ??
          [],
    );
  }
}
