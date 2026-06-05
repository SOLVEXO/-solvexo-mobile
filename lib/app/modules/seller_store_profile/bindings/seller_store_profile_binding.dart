import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:get/get.dart';

class SellerStoreProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerStoreProfileController>(
        () => SellerStoreProfileController());
  }
}
