import 'package:book_store_app/app/modules/seller_activity_log/controllers/seller_activity_log_controller.dart';
import 'package:get/get.dart';

class SellerActivityLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerActivityLogController>(() => SellerActivityLogController());
  }
}
