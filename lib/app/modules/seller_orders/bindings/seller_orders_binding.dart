import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:get/get.dart';

class SellerOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerOrdersController>(() => SellerOrdersController());
  }
}
