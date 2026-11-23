import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Store-compliance pages on the website (R7). The apex domain redirects to
/// www, so the www URLs are used (same URLs go into Play / App Store).
class LegalLinks {
  LegalLinks._();

  static const privacyPolicy = 'https://www.edudeen.com/privacy-policy';
  static const termsOfService = 'https://www.edudeen.com/terms-of-service';
  static const deleteAccount = 'https://www.edudeen.com/delete-account';

  static Future<void> open(String url) async {
    try {
      if (await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView)) return;
    } catch (_) {}
    ToastUtil.showToast('Could not open the page.'.tr);
  }
}
