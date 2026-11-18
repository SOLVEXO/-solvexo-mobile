import 'package:book_store_app/app/modules/seller_store_settings/controllers/seller_store_settings_controller.dart';
import 'package:book_store_app/app/modules/seller_store_settings/controllers/seller_shipping_controller.dart';
import 'package:get/get.dart';

class SellerStoreSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerStoreSettingsController>(() => SellerStoreSettingsController());
  }
}

class SellerShippingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerShippingController>(() => SellerShippingController());
  }
}
