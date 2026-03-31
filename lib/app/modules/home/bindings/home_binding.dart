import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
