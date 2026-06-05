import 'package:book_store_app/app/modules/edit_seller_product/controllers/edit_seller_product_controller.dart';
import 'package:get/get.dart';

class EditSellerProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditSellerProductController>(
      () => EditSellerProductController(),
    );
  }
}
