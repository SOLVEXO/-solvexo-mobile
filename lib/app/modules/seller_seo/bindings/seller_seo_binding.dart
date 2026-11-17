import 'package:book_store_app/app/modules/seller_seo/controllers/seller_seo_controller.dart';
import 'package:get/get.dart';

class SellerSeoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerSeoController>(() => SellerSeoController());
  }
}
