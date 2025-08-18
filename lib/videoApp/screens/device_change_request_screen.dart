import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:futurex_app/constants/constants.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceChangeRequestScreen extends StatefulWidget {
  const DeviceChangeRequestScreen({super.key});

  @override
  _DeviceChangeRequestScreenState createState() =>
      _DeviceChangeRequestScreenState();
}

class _DeviceChangeRequestScreenState extends State<DeviceChangeRequestScreen> {
  final _actualDeviceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  final Dio _dio = Dio();
  String? _currentDeviceInfo;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchCurrentDeviceInfo();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userId') == null ||
        prefs.getString('userId')!.isEmpty) {
      _showLoginPrompt();
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You must be logged in to submit a device change request.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _simulateLogin();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', 'testUser123');
    await prefs.setString('fullName', 'John Doe');
    await prefs.setString('phone', '123-456-7890');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged in successfully!')));
  }

  Future<void> _fetchCurrentDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      setState(() {
        _currentDeviceInfo = '${androidInfo.model}';
      });
    } catch (e) {
      setState(() {
        _currentDeviceInfo = 'Error fetching device info: $e';
      });
    }
  }

  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'first_name': prefs.getString('first_name') ?? '',
      'last_name': prefs.getString("last_name") ?? '',
      'phone': prefs.getString('phone') ?? '',
    };
  }

  Future<void> _handleSubmit() async {
    if (_currentDeviceInfo == null || _currentDeviceInfo!.startsWith('Error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch current device info')),
      );
      return;
    }
    if (_actualDeviceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your new device info')),
      );
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a description')),
      );
      return;
    }

    final userInfo = await _getUserInfo();
    if (userInfo['phone']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information not found in preferences'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final requestData = {
      'full_name': "${userInfo['first_name']} ${userInfo['last_name']}",
      'phone': userInfo['phone'],
      'current_device': _currentDeviceInfo!,
      'actual_device': _actualDeviceController.text,
      'description': _descriptionController.text,
      'status': 'pending',
    };

    try {
      final response = await _dio.post(
        Networks().adminAPI + '/reset',
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device change request submitted successfully!'),
          ),
        );
      } else {
        throw Exception('Failed to submit request: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting request: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Device Change Request'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit a request to change your registered device',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Device Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_android, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentDeviceInfo ?? 'Fetching device info...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'New Device Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _actualDeviceController,
                      decoration: InputDecoration(
                        labelText: 'Device Model',
                        hintText:
                            'Enter new device model (e.g., Samsung Galaxy S21)',
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.device_hub, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Reason for Change',
                        hintText:
                            'Describe the reason for changing your device',
                        hintStyle: TextStyle(
                          color: Colors.grey.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.description, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
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

  @override
  void dispose() {
    _actualDeviceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
