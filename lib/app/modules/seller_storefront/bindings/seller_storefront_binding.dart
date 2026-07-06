import 'package:book_store_app/app/modules/seller_storefront/controllers/seller_storefront_controller.dart';
import 'package:get/get.dart';

class SellerStorefrontBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerStorefrontController>(() => SellerStorefrontController());
  }
}
