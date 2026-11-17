import 'package:book_store_app/app/modules/seller_password_security/controllers/seller_password_security_controller.dart';
import 'package:get/get.dart';

class SellerPasswordSecurityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerPasswordSecurityController>(() => SellerPasswordSecurityController());
  }
}
