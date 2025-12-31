import 'package:get/get.dart';

import '../controllers/order_tracker_controller.dart';

class ProfileOrdertrackerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderTrackerController>(() => OrderTrackerController());
  }
}
