import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:get/get.dart';

class SellerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerHomeController>(() => SellerHomeController());
  }
}
