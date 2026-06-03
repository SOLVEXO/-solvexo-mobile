import 'package:book_store_app/app/modules/seller_settings/controllers/seller_settings_controller.dart';
import 'package:get/get.dart';

class SellerSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerSettingsController>(() => SellerSettingsController());
  }
}
