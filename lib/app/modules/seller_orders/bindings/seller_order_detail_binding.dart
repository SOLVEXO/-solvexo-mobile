import 'package:book_store_app/app/modules/seller_orders/controllers/seller_order_detail_controller.dart';
import 'package:get/get.dart';

class SellerOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SellerOrderDetailController());
  }
}
