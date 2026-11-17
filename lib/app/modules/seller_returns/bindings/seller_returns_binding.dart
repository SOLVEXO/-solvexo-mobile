import 'package:get/get.dart';

import '../controllers/seller_returns_controller.dart';

class SellerReturnsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerReturnsController>(() => SellerReturnsController());
  }
}
