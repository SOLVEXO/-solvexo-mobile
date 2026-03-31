import 'package:get/get.dart';

import '../controllers/help_center_controller.dart';

class FaqBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaqController>(() => FaqController());
  }
}
