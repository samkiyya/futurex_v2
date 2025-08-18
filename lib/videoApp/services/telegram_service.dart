import 'package:url_launcher/url_launcher.dart';

class TelegramService {
  static const String _telegramUsername = 'futurexhelp';

  static Future<void> launchTelegram() async {
    const appUrl = 'tg://resolve?domain=$_telegramUsername';
    const webUrl = 'https://t.me/$_telegramUsername';

    try {
      if (await canLaunch(appUrl)) {
        await launch(appUrl);
      } else if (await canLaunch(webUrl)) {
        await launch(webUrl);
      }
    } catch (e) {
      // debugPrint('Could not launch Telegram: $e');
    }
  }
}
