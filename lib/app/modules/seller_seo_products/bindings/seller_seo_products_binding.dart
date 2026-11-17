import 'package:book_store_app/app/modules/seller_seo_products/controllers/seller_seo_products_controller.dart';
import 'package:get/get.dart';

class SellerSeoProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerSeoProductsController>(() => SellerSeoProductsController());
  }
}
