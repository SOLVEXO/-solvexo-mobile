import 'package:book_store_app/app/modules/seller_two_factor/controllers/seller_two_factor_controller.dart';
import 'package:get/get.dart';

class SellerTwoFactorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerTwoFactorController>(() => SellerTwoFactorController());
  }
}
