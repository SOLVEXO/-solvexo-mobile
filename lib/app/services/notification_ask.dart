import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// When to show the notification explanation (R7).
class NotificationAsk {
  NotificationAsk._();

  static const askedAtKey = 'notif_rationale_asked_at';
  static const again = Duration(days: 7);

  static Future<bool> shouldAsk({DateTime? now}) async {
    final p = await SharedPreferences.getInstance();
    final at = p.getInt(askedAtKey);
    if (at == null) return true;
    return (now ?? DateTime.now()).difference(DateTime.fromMillisecondsSinceEpoch(at)) >= again;
  }

  static Future<void> markAsked() async =>
      (await SharedPreferences.getInstance()).setInt(askedAtKey, DateTime.now().millisecondsSinceEpoch);

  static const _transient = {'/', Routes.splashScreen, Routes.authTabView, Routes.onboarding};

  /// Waits (max ~20 s) until a real screen has settled - login and splash
  /// replace the whole stack, which would close a dialog shown too early.
  static Future<void> waitForStableScreen() async {
    String? last;
    for (var i = 0; i < 25; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final r = Get.currentRoute;
      final busy = (Get.isDialogOpen ?? false) || (Get.isBottomSheetOpen ?? false);
      if (!busy && !_transient.contains(r) && r == last) return;
      last = r;
    }
  }
}
