import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:get/get.dart';

class SellerProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerProductsController>(() => SellerProductsController());
  }
}
