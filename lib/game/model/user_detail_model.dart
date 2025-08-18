
class UserData {
  final String id;
  final String phone;
  final String grade;
  final String category;
  final String school;
  final String gender;
  final String region;
  final String status;
  final String name;

  UserData({
    required this.id,
    required this.phone,
    required this.grade,
    required this.category,
    required this.school,
    required this.gender,
    required this.region,
    required this.status,
    required this.name,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?? '',
      phone: json['phone']?? '',
      grade: json['grade']?? '',
      category: json['category']??'',
      school: json['school']?? '',
      gender: json['gender']??'',
      region: json['region']??'',
      status: json['status']??'',
      name: json['name']?? '',
    );
  }
}