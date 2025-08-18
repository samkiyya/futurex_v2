
class UserProfile {
  final String userId;
  final String name;
  final String phone;
  final String grade;
  final String category;
  final String school;
  final String gender;
  final String region;
  final String status;

  UserProfile({
    required this.userId,
    required this.name,
    required this.phone,
    required this.grade,
    required this.category,
    required this.school,
    required this.gender,
    required this.region,
    required this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
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
    Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'phone': phone,
      'grade': grade,
      'category': category,
      'school': school,
      'gender': gender,
      'region': region,
      'status': status,
    };
  }
}