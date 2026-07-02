import 'package:book_store_app/app/modules/seller_edit_profile/controllers/seller_edit_profile_controller.dart';
import 'package:get/get.dart';

class SellerEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerEditProfileController>(() => SellerEditProfileController());
  }
}
