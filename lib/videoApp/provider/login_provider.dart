import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class LoginProvider extends ChangeNotifier {
  final baseApi = Networks();
  final storage = FlutterSecureStorage();
  String? userId;
  bool isLoading = false;
  String? errorMessage;
  bool status = false;

  Future<void> handleLogin(String phone, String password, String device) async {
    Dio dio = Dio();
    isLoading = true;
    errorMessage = null;
    status = false;
    notifyListeners();

    try {
      Response response = await dio.post(
        Networks().userAPI + '/auth/login',
        data: {
          "phone": phone,
          "password": password,
          "device": device, // <-- Device is commented out, as per backend logic
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        print("sssssss");
        final responseData = response.data;
        // "code" may not exist in all backend success responses, so check both
        if (responseData['code'] == 200 ||
            responseData['message']?.toString().toLowerCase().contains(
                  'success',
                ) ==
                true) {
          final user = responseData['user'];

          await setSession(
            id: user['id']?.toString(),
            firstName: user['first_name'],
            lastName: user['last_name'],
            phone: user['phone'],
          );
          status = true;
        } else if (responseData['code'] == 101) {
          errorMessage = "You are not registered with this device!";
        } else if (responseData['code'] == 400) {
          errorMessage =
              responseData['message'] ??
              "You are not enrolled for any course! Please enroll to continue.";
        } else {
          errorMessage =
              responseData['message'] ?? "Unexpected error occurred!";
        }
      } else if (response.statusCode == 404) {
        errorMessage = "Account does not exist!";
      } else if (response.statusCode == 401) {
        errorMessage = "Wrong password!";
      } else {
        errorMessage = "Failed to connect to the server. Please try again.";
      }
    } on DioException catch (e) {
      print('DioException: ${e.toString()}');
      print('DioException.response: ${e.response}');
      if (e.response != null &&
          e.response?.data is Map &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      } else {
        errorMessage =
            "Connection Error: Please check your internet connection and try again.";
      }
    } catch (e) {
      errorMessage = "An unexpected error occurred!";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSession({
    required String? id,
    required String? firstName,
    required String? lastName,
    required String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', id ?? '');
    await prefs.setString('first_name', firstName ?? '');
    await prefs.setString('last_name', lastName ?? '');
    await prefs.setString('phone', phone ?? '');

    await FlutterSecureStorage().write(key: 'loggeduserId', value: id ?? '');
  }
}
