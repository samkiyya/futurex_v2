import 'package:flutter/material.dart';
import 'package:futurex_app/auth/signUp.dart';
import 'package:futurex_app/constants/styles.dart';
import 'package:futurex_app/commonScreens/device_info.dart';

import 'package:futurex_app/videoApp/screens/offline_screens/offline_course_screen.dart';

import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:futurex_app/videoApp/provider/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  String _deviceName = '';
  bool _isLoading = false;
  String? _userId;

  final _deviceInfoService = DeviceInfoService();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _fetchDeviceInfo();
    _checkUserId();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchDeviceInfo() async {
    final deviceData = await _deviceInfoService.getDeviceData();
    final brand = deviceData['brand'] ?? 'Unknown';
    final board = deviceData['board'] ?? 'Unknown';
    final model = deviceData['model'] ?? 'Unknown';
    final deviceId = deviceData['id'] ?? 'Unknown';
    final deviceType = _deviceInfoService.detectDeviceType(context);
    _deviceName = '$brand $board $model $deviceId $deviceType';
  }

  Future<void> _checkUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    if (_userId != null && _userId!.isNotEmpty) {
      _navigateToCourses(false);
    }
  }

  void _navigateToCourses(bool isOnline) async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OfflineCourseScreen(userId: _userId!, isOnline: isOnline),
        ),
      );
    });
  }

  Future<void> _handleLogin(LoginProvider loginProvider) async {
    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    await loginProvider.handleLogin(
      _phoneController.text,
      _passwordController.text,
      _deviceName,
    );

    setState(() => _isLoading = false);

    if (loginProvider.errorMessage != null &&
        loginProvider.errorMessage!.isNotEmpty) {
      _showErrorDialog(loginProvider.errorMessage!);
    } else {
      _phoneController.clear();
      _passwordController.clear();
      _navigateToCourses(true);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(
              'Login Failed',
              style: FuturexStyles.ftext.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: FuturexStyles.error.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Icon(Icons.warning, color: Colors.red.shade300, size: 48),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Try Again', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.withOpacity(0.2), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),
                    _buildLoginButton(loginProvider),
                    const SizedBox(height: 16),
                    _buildSignUpLink(),
                    const SizedBox(height: 16),
                    _buildContactInfo(),
                  ],
                ),
              ),
              if (_isLoading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (_) {},
        currentSelectedIndex: 0,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.school, size: 60, color: Colors.blueAccent),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.blueAccent, Colors.cyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Base color for gradient
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Log in to continue your learning journey',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginProvider loginProvider) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleLogin(loginProvider),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: Colors.blueAccent.withOpacity(0.5),
        animationDuration: const Duration(milliseconds: 200),
        splashFactory: InkRipple.splashFactory,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login, size: 20),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.cyanAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSignUpLink() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
            ),
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          children: [
            TextSpan(
              text: 'Register',
              style: TextStyle(
                color: _isLoading ? Colors.grey : Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return const Text(
      'For support, call: 0911070663',
      style: TextStyle(color: Colors.grey, fontSize: 14),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      ),
    );
  }
}
