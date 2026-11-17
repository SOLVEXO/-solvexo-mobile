import 'package:book_store_app/app/modules/seller_shipping/controllers/seller_shipping_controller.dart';
import 'package:get/get.dart';

class SellerShippingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerShippingController>(() => SellerShippingController());
  }
}
