import 'package:book_store_app/app/modules/seller_inventory/controllers/seller_inventory_controller.dart';
import 'package:get/get.dart';

class SellerInventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerInventoryController>(() => SellerInventoryController());
  }
}
