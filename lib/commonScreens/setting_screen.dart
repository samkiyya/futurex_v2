// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';

import 'package:futurex_app/widgets/bottomNav.dart';

import 'package:futurex_app/widgets/responsive_image_with_text_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic> userProfile = {
    "first_name": "",
    "last_name": "",
    "phone": "",
    "password": "",
    "grade": "",
    "category": "",
    "school": "",
    "gender": "",
    "region": "",
  };

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  final baseApi = Networks();
  bool isLoading = false;
  String errorMessage = '';
  String userId = "0";

  @override
  void initState() {
    super.initState();
    setControllers();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';

      final response = await http.get(
        Uri.parse('${baseApi.furl}/users/getUserProfile/$userId/'),
      );
      if (response.statusCode == 200) {
        setState(() {
          userProfile = json.decode(response.body);
          isLoading = false;
          setControllers();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load user profile';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred please try again!: ';
        isLoading = false;
      });
    }
  }

  void setControllers() {
    firstNameController.text = userProfile['first_name'];
    lastNameController.text = userProfile['last_name'];
    phoneController.text = userProfile['phone'];
    passwordController.text = userProfile['password'];
    gradeController.text = userProfile['grade'];
    categoryController.text = userProfile['category'];
    schoolController.text = userProfile['school'];
    genderController.text = userProfile['gender'];
    regionController.text = userProfile['region'];
  }

  Future<void> updateUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    if (userId.isEmpty || userId == '') {
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${baseApi.furl}/users/updateUserProfile/$userId'),
        body: {
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "phone": phoneController.text,
          "password": passwordController.text,
          "grade": gradeController.text,
          "category": categoryController.text,
          "school": schoolController.text,
          "gender": genderController.text,
          "region": regionController.text,
        },
      );

      if (response.statusCode == 200) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You Profile Updated successfully')),
        );
      } else {
        // Handle error
        json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: ResponsiveImageTextWidget(
                imageUrl: 'assets/images/nointernet.gif',
                text: "please try again some thing went wrong!.",
              ),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: ResponsiveImageTextWidget(
              imageUrl: 'assets/images/nointernet.gif',
              text: "please try again some thing went wrong!.",
            ),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  buildTextField('First Name', firstNameController),
                  buildTextField('Last Name', lastNameController),
                  buildTextField('Phone', phoneController),
                  buildTextField('Password', passwordController),
                  buildTextField('Grade', gradeController),
                  buildTextField('Category', categoryController),
                  buildTextField('School', schoolController),
                  buildTextField('Gender', genderController),
                  buildTextField('Region', regionController),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: updateUserProfile,
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(16.0),
        ),
        style: const TextStyle(fontSize: 18.0),
      ),
    );
  }
}
