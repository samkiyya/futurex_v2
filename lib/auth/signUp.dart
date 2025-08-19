// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:futurex_app/commonScreens/device_info.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/auth/login_screen.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/widgets/regsitration_steps_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true; // Add this state variable
  bool _obscureConfirmPassword = true; // Add for confirm password
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  String deviceName = '';

  // Controllers for text fields
  final Map<String, TextEditingController> _controllers = {
    'first_name': TextEditingController(),
    'last_name': TextEditingController(),
    'phone': TextEditingController(),
    'password': TextEditingController(),
    'confirm_password': TextEditingController(),
    'school': TextEditingController(),
  };

  // Dropdown and radio selections
  String? _selectedRegion;
  String? _selectedGender;
  String? _selectedGrade;
  String? _selectedCategory;

  // Updated list of all Ethiopian regions as of 2025
  final List<String> _regions = [
    'Addis Ababa',
    'Afar',
    'Amhara',
    'Benishangul-Gumuz',
    'Central Ethiopia',
    'Dire Dawa',
    'Gambela',
    'Harari',
    'Oromia',
    'Sidama',
    'Somali',
    'South Ethiopia',
    'South West Ethiopia',
    'Tigray',
  ];

  final List<String> _grades = [
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
  ];

  final List<String> _categories = [
    'Natural Science',
    'Social Science',
    'Grade 9 or 10',
    'Grade 7 or 8',
  ];

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _clearForm() {
    for (var controller in _controllers.values) {
      controller.clear();
    }
    setState(() {
      _selectedRegion = null;
      _selectedGender = null;
      _selectedGrade = null;
      _selectedCategory = null;
    });
  }

  Future<void> _getDeviceInfo() async {
    final deviceData = await _deviceInfoService.getDeviceData();
    String brand = deviceData['brand'] ?? 'Unknown';
    String board = deviceData['board'] ?? 'Unknown';
    String model = deviceData['model'] ?? 'Unknown';
    String deviceId = deviceData['id'] ?? 'Unknown';
    String deviceType = _deviceInfoService.detectDeviceType(context);
    setState(() {
      deviceName = '$brand $board $model $deviceId $deviceType';
    });
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await _getDeviceInfo();

    final Map<String, dynamic> data = {
      for (var key in _controllers.keys) key: _controllers[key]!.text,
      'status': 'inactive',
      'device': deviceName,
      'region': _selectedRegion,
      'gender': _selectedGender,
      'grade': _selectedGrade,
      'category': _selectedCategory,
    };

    final dio = Dio();
    try {
      final response = await dio.post(
        '${Networks().userAPI}/users',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode(data),
      );
      setState(() => _isLoading = false);

      final responseData = response.data;

      if (response.statusCode == 201 && responseData['code'] == 201) {
        _clearForm();
        _showSuccessDialog();
      } else if (response.statusCode == 400) {
        _showErrorDialog(
          title: 'Registration Failed',
          message: responseData['message'] ?? 'Phone number already in use.',
          icon: Icons.error,
          color: Colors.red,
        );
      } else {
        _showErrorDialog(
          title: 'Unexpected Error',
          message: responseData['message'] ?? 'Something went wrong.',
          icon: Icons.error_outline,
          color: Colors.orange,
        );
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      if (e.response != null) {
        _showErrorDialog(
          title: 'Server Error',
          message: e.response!.data['message'] ?? 'Unexpected server response.',
          icon: Icons.error_outline,
          color: Colors.orange,
        );
      } else {
        _showErrorDialog(
          title: 'Network Error',
          message: 'Unable to connect. Please check your internet.',
          icon: Icons.wifi_off,
          color: Colors.amber,
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const RegistrationStepsWidget(),
      ),
    );
  }

  void _showErrorDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: GradientAppBar(title: "Sign Up"),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent.withOpacity(0.2), Colors.white],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Create Your Account',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Fill in the details below to get started.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildTextField('first_name', 'First Name'),
                              _buildTextField('last_name', 'Last Name'),
                              _buildTextField(
                                'phone',
                                'Phone Number',
                                isPhone: true,
                              ),
                              _buildTextField(
                                'password',
                                'Password',
                                isPassword: true,
                              ),
                              _buildTextField(
                                'confirm_password',
                                'Confirm Password',
                                isPassword: true,
                              ),
                              _buildTextField('school', 'School'),
                              _buildDropdown(
                                label: 'Stream',
                                value: _selectedCategory,
                                items: _categories,
                                onChanged: (value) =>
                                    setState(() => _selectedCategory = value),
                                validator: (value) => value == null
                                    ? 'Please select a stream'
                                    : null,
                              ),
                              _buildDropdown(
                                label: 'Region',
                                value: _selectedRegion,
                                items: _regions,
                                onChanged: (value) =>
                                    setState(() => _selectedRegion = value),
                                validator: (value) => value == null
                                    ? 'Please select a region'
                                    : null,
                              ),
                              _buildGenderSelector(),
                              _buildDropdown(
                                label: 'Grade',
                                value: _selectedGrade,
                                items: _grades,
                                onChanged: (value) =>
                                    setState(() => _selectedGrade = value),
                                validator: (value) => value == null
                                    ? 'Please select a grade'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              const SizedBox(height: 32),
                              // Full-width register button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _registerUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.blueAccent.withOpacity(
                                      0.5,
                                    ),
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: const [
                                            Icon(Icons.person_add, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Register',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Login prompt moved outside the button to match the screenshot
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  GestureDetector(
                                    onTap: _isLoading
                                        ? null
                                        : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen(),
                                            ),
                                          ),
                                    child: const Text(
                                      'Login here',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ), // Column
                        ), // Form
                      ), // Padding
                    ), // Card
                  ), // ConstrainedBox
                ), // Center
              ), // SingleChildScrollView
            ), // SafeArea
          ), // Container

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 0,
      ),
    );
  }

  Widget _buildTextField(
    String key,
    String label, {
    bool isPassword = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          prefixIcon: _getPrefixIcon(key),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (key == 'password'
                            ? _obscurePassword
                            : _obscureConfirmPassword)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      if (key == 'password') {
                        _obscurePassword = !_obscurePassword;
                      } else if (key == 'confirm_password') {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }
                    });
                  },
                )
              : null,
        ),
        obscureText: isPassword
            ? (key == 'password' ? _obscurePassword : _obscureConfirmPassword)
            : false,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${label.toLowerCase()}';
          }
          if (isPassword && key == 'confirm_password') {
            if (value != _controllers['password']!.text) {
              return 'Passwords do not match';
            }
          }
          if (isPhone) {
            if (value.length < 10 || value.length > 13) {
              return 'Phone number must be 10-13 digits';
            }
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              return 'Phone number must be numeric';
            }
          }
          return null;
        },
      ),
    );
  }

  Icon? _getPrefixIcon(String key) {
    switch (key) {
      case 'first_name':
      case 'last_name':
        return const Icon(Icons.person, color: Colors.blueAccent);
      case 'phone':
        return const Icon(Icons.phone, color: Colors.blueAccent);
      case 'password':
      case 'confirm_password':
        return const Icon(Icons.lock, color: Colors.blueAccent);
      case 'school':
        return const Icon(Icons.school, color: Colors.blueAccent);
      default:
        return null;
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: _isLoading ? null : onChanged,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 16)),
              ),
            )
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          prefixIcon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.blueAccent,
          ),
        ),
        validator: validator,
        dropdownColor: Colors.white,
        isExpanded: true,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Center(
            child: ToggleButtons(
              isSelected: [
                _selectedGender == 'Male',
                _selectedGender == 'Female',
              ],
              onPressed: _isLoading
                  ? null
                  : (index) => setState(() {
                      _selectedGender = index == 0 ? 'Male' : 'Female';
                    }),
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: Colors.blueAccent,
              color: Colors.black87,
              constraints: const BoxConstraints(minWidth: 120, minHeight: 44),
              children: const [
                Text('Male', style: TextStyle(fontSize: 16)),
                Text('Female', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
