import 'package:book_store_app/app/modules/seller_store_banners/controllers/seller_store_banners_controller.dart';
import 'package:get/get.dart';

class SellerStoreBannersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerStoreBannersController>(() => SellerStoreBannersController());
  }
}
