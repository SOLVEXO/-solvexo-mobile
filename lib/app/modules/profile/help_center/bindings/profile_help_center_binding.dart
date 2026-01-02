import 'package:get/get.dart';

import '../controllers/help_center_controller.dart';

class ProfileHelpCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpCenterController>(() => HelpCenterController());
  }
}
