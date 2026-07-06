import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/core/base/base_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

class WelcomeController extends BaseController {
  Future<void> selectRole(String role) async {
    await AppPreferences.saveIntentRole(role);
    Get.offAllNamed(Routes.authTabView);
  }
}
