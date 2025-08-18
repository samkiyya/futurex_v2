class TopUser {
  final int userId;
  final double totalScore;
  final int rank;
  final String full_name;

  TopUser({required this.userId, required this.totalScore, required this.full_name,required this.rank});

  factory TopUser.fromJson(Map<String, dynamic> json) {
    return TopUser(
        userId: json['user_id'],
        totalScore: json['total_score'].toDouble(),
        rank: json['rank'],
        full_name: json['full_name']);
  }
}

class AdditionalInfo {
  final String name;
  final String phone;
  final String grade;
  final String category;
  final String school;
  final String gender;
  final String region;
  final String status;

  AdditionalInfo({
    required this.name,
    required this.phone,
    required this.grade,
    required this.category,
    required this.school,
    required this.gender,
    required this.region,
    required this.status,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(
      name: json['name'],
      phone: json['phone'],
      grade: json['grade'],
      category: json['category'],
      school: json['school'],
      gender: json['gender'],
      region: json['region'],
      status: json['status'],
    );
  }
}
