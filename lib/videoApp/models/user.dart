class User {
  final int id;
  final String fullName;
  final String phone;
  final String email;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String firstName = json['first_name'] ?? '';
    String lastName = json['last_name'] ?? '';
    String fullName = (firstName + ' ' + lastName).trim();
    if (fullName.isEmpty) {
      fullName = 'Unknown';
    }

    // email may not exist in your backend, so default to 'Unknown'
    return User(
      id: json['id'],
      fullName: fullName,
      phone: json['phone'] ?? 'Unknown',
      email: json['email'] ?? 'Unknown',
    );
  }
}