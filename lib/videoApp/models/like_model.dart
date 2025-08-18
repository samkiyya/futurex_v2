class Like {
  final int notificationId;
  final String userType;
  final int userId;

  Like({
    required this.notificationId,
    required this.userType,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      "notificationId": notificationId,
      "userType": userType,
      "user_id": userId,
    };
  }
}