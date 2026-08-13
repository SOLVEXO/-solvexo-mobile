import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/core/base/base_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

// Seller-only landing screen — reached exclusively via the "Sell on Solvexo"
// entry point (never shown at first launch; buyers land straight in guest
// Home per the splash routing).
class WelcomeController extends BaseController {
  Future<void> startSelling() async {
    await AppPreferences.saveIntentRole('seller');
    Get.toNamed(Routes.authTabView);
  }
}
