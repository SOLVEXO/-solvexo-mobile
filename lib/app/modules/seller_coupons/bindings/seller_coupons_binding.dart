import 'package:book_store_app/app/modules/seller_coupons/controllers/seller_coupons_controller.dart';
import 'package:get/get.dart';

class SellerCouponsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerCouponsController>(() => SellerCouponsController());
  }
}
