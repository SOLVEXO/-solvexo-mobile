import 'package:book_store_app/app/modules/seller_promotions/controllers/seller_promotions_controller.dart';
import 'package:get/get.dart';

class SellerPromotionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerPromotionsController>(() => SellerPromotionsController());
  }
}
