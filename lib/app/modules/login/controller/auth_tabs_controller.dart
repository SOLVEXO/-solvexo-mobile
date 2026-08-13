import 'package:get/get.dart';

class AuthTabsController extends GetxController {
  RxInt tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['initialTab'] is int) {
      tabIndex.value = args['initialTab'] as int;
    }
  }

  void switchTab(int index) {
    tabIndex.value = index;
  }
}
