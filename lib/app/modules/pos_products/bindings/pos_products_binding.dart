import 'package:book_store_app/app/modules/pos_products/controllers/pos_products_controller.dart';
import 'package:get/get.dart';

class PosProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosProductsController>(() => PosProductsController());
  }
}
