import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {
  static Future<void> launchTelegram(String username) async {
    final appUrl = 'tg://resolve?domain=$username';
    final webUrl = 'https://t.me/$username';

    if (await canLaunchUrl(Uri.parse(appUrl))) {
      await launchUrl(Uri.parse(appUrl));
    } else if (await canLaunchUrl(Uri.parse(webUrl))) {
      await launchUrl(Uri.parse(webUrl));
    } else {
      throw 'Could not launch Telegram.';
    }
  }
}
