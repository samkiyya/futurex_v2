import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareMedia {
  void shareApp() {
    final String text =
        'https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2 ';

    Share.share(text, subject: 'download our application from playstore');
  }

  void shareAppTelegram(String text) async {
    final String telegramUrl =
        'https://t.me/share/url?url=${Uri.encodeComponent(text)}';

    if (await canLaunch(telegramUrl)) {
      await launch(telegramUrl);
    } else {
      // If Telegram app is not installed, fallback to the share package
      Share.share(text, subject: 'check out our app from playstore');
    }
  }
}
