import 'package:book_store_app/app/modules/seller_platform_plans/controllers/seller_platform_plans_controller.dart';
import 'package:get/get.dart';

class SellerPlatformPlansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerPlatformPlansController>(() => SellerPlatformPlansController());
  }
}
