import 'package:get/get.dart';

import '../controllers/my_orders_controller.dart';

class ProfileMyordersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyOrdersController>(() => MyOrdersController());
  }
}
