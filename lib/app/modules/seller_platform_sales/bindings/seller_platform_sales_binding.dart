import 'package:book_store_app/app/modules/seller_platform_sales/controllers/seller_platform_sales_controller.dart';
import 'package:get/get.dart';

class SellerPlatformSalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerPlatformSalesController>(() => SellerPlatformSalesController());
  }
}
