import 'dart:io';

class Order {
  String full_name;
  String phone;
  String type;
  String bank_name;
  List<String>? selectedCategories;
  List<String>? selectedCourses;
  File? screenshot;

  Order(
      {required this.full_name,
      required this.phone,
      this.selectedCategories,
      this.selectedCourses,
      this.screenshot,
      required this.type,
      required this.bank_name});

  set phoneNumber(String phoneNumber) {}
}
