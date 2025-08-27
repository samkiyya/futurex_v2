// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futurex_app/order_screens/telegram_order_notifier.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final List<Category> selectedCategories;
  final List<Course> selectedCourses;
  final String type;

  const PaymentDetailsScreen({
    super.key,
    required this.selectedCategories,
    this.selectedCourses = const [],
    required this.type,
  });

  @override
  _PaymentDetailsScreenState createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  File? _receiptImage;
  bool _isLoading = false;
  final Dio _dio = Dio();

  String _normalizePlan(String type) {
    final t = type.trim().toLowerCase();
    if (t.contains('premium')) return 'Premium Plan';
    if (t.contains('grade')) return 'Single Grade Plan';
    if (t.contains('single course') || t.contains('course')) {
      return 'Single Course Plan';
    }
    // Infer from selection if type string is inconsistent
    if (widget.selectedCourses.isNotEmpty) return 'Single Course Plan';
    if (widget.selectedCategories.length > 1) return 'Premium Plan';
    if (widget.selectedCategories.length == 1) return 'Single Grade Plan';
    return 'Plan';
  }

  String _planPriceLabel(String normalized) {
    switch (normalized) {
      case 'Premium Plan':
        return '3,999 Birr (Lifetime)';
      case 'Single Grade Plan':
        return '1,999 Birr / year';
      case 'Single Course Plan':
        return 'Starts at 499 Birr / course';
      default:
        return '';
    }
  }

  Future<Map<String, String>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString('first_name') ?? '',
      'lastName': prefs.getString('last_name') ?? '',
      'phone': prefs.getString('phone') ?? '',
    };
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmitReceipt() async {
    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a payment receipt')),
      );
      return;
    }

    final userInfo = await _getUserInfo();
    if (userInfo['firstName']!.isEmpty ||
        userInfo['lastName']!.isEmpty ||
        userInfo['phone']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information not found.')),
      );
      return;
    }

    final fullName = '${userInfo['firstName']} ${userInfo['lastName']}';
    final orderType = widget.selectedCourses.isNotEmpty
        ? 'courses'
        : 'categories';

    setState(() => _isLoading = true);

    final orderData = {
      'full_name': fullName,
      'bank_name': "test",
      'phone': userInfo['phone'],
      'type': orderType,
      'status': 'pending',
      'categories': widget.selectedCategories
          .map((c) => {'id': c.id, 'catagory': c.catagory})
          .toList(),
      'courses': widget.selectedCourses
          .map((c) => {'id': c.id, 'title': c.title})
          .toList(),
      'image': await MultipartFile.fromFile(
        _receiptImage!.path,
        filename: 'receipt.jpg',
      ),
    };

    try {
      final response = await _dio.post(
        '${Networks().adminAPI}/orders',
        data: FormData.fromMap(orderData),
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt submitted successfully!')),
        );
        // Send the same details to Telegram help automatically.
        final plan = _normalizePlan(widget.type);
        final priceLabel = _planPriceLabel(plan);
        try {
          await TelegramOrderNotifier.sendOrder(
            fullName: fullName,
            phone: userInfo['phone'] ?? '',
            plan: plan,
            priceLabel: priceLabel,
            categories: widget.selectedCategories,
            courses: widget.selectedCourses,
            receipt: _receiptImage,
          );
        } catch (e) {
          // Log silently; don't block the user on Telegram failure.
        }
      } else {
        final errorMessage =
            response.data is Map && response.data['message'] != null
            ? response.data['message']
            : 'Unknown error';
        throw Exception('Failed to submit order: $errorMessage');
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data?['message'] ?? errorMessage;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _normalizePlan(widget.type);
    final priceLabel = _planPriceLabel(plan);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Verification'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload your payment receipt to complete enrollment',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryRow('Plan:', plan, isBold: true),
                    if (priceLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _summaryRow('Price:', priceLabel),
                    ],
                    const SizedBox(height: 10),
                    if (plan == 'Single Course Plan') ...[
                      _summaryRow(
                        'Courses:',
                        '${widget.selectedCourses.length}',
                        isBold: true,
                      ),
                      const SizedBox(height: 8),
                      ..._buildCourseList(widget.selectedCourses),
                    ] else if (plan == 'Single Grade Plan') ...[
                      _summaryRow(
                        'Selected Grade:',
                        widget.selectedCategories.isNotEmpty
                            ? widget.selectedCategories.first.catagory
                            : 'N/A',
                      ),
                    ] else if (plan == 'Premium Plan') ...[
                      _summaryRow(
                        'Grades Included:',
                        'All (${widget.selectedCategories.length})',
                      ),
                      const SizedBox(height: 8),
                      ..._buildCategoryPreview(widget.selectedCategories),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Upload Payment Receipt',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: DottedBorderBox(
                  child: _receiptImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Click to upload',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'PNG, JPG, PDF up to 10MB',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _receiptImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmitReceipt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Receipt',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

extension on _PaymentDetailsScreenState {
  List<Widget> _buildCourseList(List<Course> courses) {
    const maxShow = 5;
    final items = <Widget>[];
    for (int i = 0; i < courses.length && i < maxShow; i++) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6.0, right: 8),
                child: Icon(Icons.circle, size: 6, color: Colors.blueAccent),
              ),
              Expanded(
                child: Text(
                  courses[i].title,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final remaining = courses.length - maxShow;
    if (remaining > 0) {
      items.add(
        Text(
          '+$remaining more',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }
    return items;
  }

  List<Widget> _buildCategoryPreview(List<Category> categories) {
    const maxShow = 6;
    final items = <Widget>[];
    for (int i = 0; i < categories.length && i < maxShow; i++) {
      items.add(
        Container(
          margin: const EdgeInsets.only(right: 6, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Text(
            categories[i].catagory,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      );
    }
    final remaining = categories.length - maxShow;
    if (remaining > 0) {
      items.add(
        Text(
          '+$remaining more grades',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }
    return [Wrap(children: items)];
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;

  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
          style: BorderStyle.solid,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Center(child: child),
    );
  }
}
