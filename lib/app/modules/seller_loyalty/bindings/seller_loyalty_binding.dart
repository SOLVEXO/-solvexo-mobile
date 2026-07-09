import 'package:book_store_app/app/modules/seller_loyalty/controllers/seller_loyalty_controller.dart';
import 'package:get/get.dart';

class SellerLoyaltyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerLoyaltyController>(() => SellerLoyaltyController());
  }
}
