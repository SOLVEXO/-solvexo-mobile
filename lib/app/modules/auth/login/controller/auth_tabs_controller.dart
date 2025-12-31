import 'package:get/get.dart';

class AuthTabsController extends GetxController {
  RxInt tabIndex = 0.obs;

  void switchTab(int index) {
    tabIndex.value = index;
  }
}
