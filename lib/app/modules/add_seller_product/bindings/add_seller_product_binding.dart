import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:get/get.dart';

class AddSellerProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddSellerProductController>(() => AddSellerProductController());
  }
}
