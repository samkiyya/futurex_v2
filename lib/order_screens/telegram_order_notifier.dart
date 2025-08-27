import 'dart:io';
import 'package:dio/dio.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';

/// Lightweight, standalone Telegram sender for order verification only.
/// Do not reuse global Telegram services here as requested.
class TelegramOrderNotifier {
  static const String botToken =
      '8072427104:AAHJQZDx1PD-9OrJXPQUyLJ3P5kltwzwQAg';
  static const List<String> chatIds = [
    '6266730872', // yordi
    '475851198', //marshet
    '779768487', //samuel
  ];

  static final Dio _dio = Dio();

  /// Sends the order summary with the receipt image to Telegram Help.
  /// If [receipt] is null, a text message is sent instead.
  static Future<void> sendOrder({
    required String fullName,
    required String phone,
    required String plan,
    String? priceLabel,
    required List<Category> categories,
    required List<Course> courses,
    File? receipt,
  }) async {
    final caption = _buildCaption(
      fullName: fullName,
      phone: phone,
      plan: plan,
      priceLabel: priceLabel,
      categories: categories,
      courses: courses,
    );

    final base = 'https://api.telegram.org/bot$botToken';

    for (final id in chatIds) {
      try {
        if (receipt != null && await receipt.exists()) {
          final form = FormData.fromMap({
            'chat_id': id,
            'caption': caption,
            'parse_mode': 'HTML',
            'photo': await MultipartFile.fromFile(
              receipt.path,
              filename: 'receipt.jpg',
            ),
          });
          await _dio.post('$base/sendPhoto', data: form);
        } else {
          await _dio.post(
            '$base/sendMessage',
            data: {'chat_id': id, 'text': caption, 'parse_mode': 'HTML'},
          );
        }
      } catch (e) {
        // Log the error and continue to the next chat ID
        print('Failed to send to $id: $e');
      }
    }
  }

  static String _buildCaption({
    required String fullName,
    required String phone,
    required String plan,
    String? priceLabel,
    required List<Category> categories,
    required List<Course> courses,
  }) {
    final b = StringBuffer();
    b.writeln('<b>New Enrollment Receipt</b>');
    b.writeln('Name: <b>$fullName</b>');
    b.writeln('Phone: <b>$phone</b>');
    b.writeln(
      'Plan: <b>$plan</b>${priceLabel != null && priceLabel.isNotEmpty ? ' ($priceLabel)' : ''}',
    );

    if (courses.isNotEmpty) {
      b.writeln('\n<b>Courses (${courses.length}):</b>');
      for (final c in courses.take(10)) {
        b.writeln('• ${_escape(c.title)}');
      }
      final remaining = courses.length - 10;
      if (remaining > 0) b.writeln('+$remaining more');
    } else if (categories.isNotEmpty) {
      if (categories.length == 1) {
        b.writeln(
          '\n<b>Selected Grade:</b> ${_escape(categories.first.catagory)}',
        );
      } else {
        b.writeln('\n<b>Grades (${categories.length}):</b>');
        for (final g in categories.take(10)) {
          b.writeln('• ${_escape(g.catagory)}');
        }
        final remaining = categories.length - 10;
        if (remaining > 0) b.writeln('+$remaining more');
      }
    }

    b.writeln('\nPlease verify and activate.');
    return b.toString();
  }

  static String _escape(String s) {
    // Minimal HTML escape for Telegram parse_mode=HTML
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
