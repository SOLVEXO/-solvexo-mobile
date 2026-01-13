import 'package:book_store_app/app/modules/login/controller/auth_tabs_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthTabsController>(() => AuthTabsController());
  }
}
