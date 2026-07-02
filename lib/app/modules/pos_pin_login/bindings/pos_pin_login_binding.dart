import 'package:book_store_app/app/modules/pos_pin_login/controllers/pos_pin_login_controller.dart';
import 'package:get/get.dart';

class PosPinLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosPinLoginController>(() => PosPinLoginController());
  }
}
