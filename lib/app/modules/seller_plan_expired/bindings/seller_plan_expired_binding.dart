import 'package:book_store_app/app/modules/seller_plan_expired/controllers/seller_plan_expired_controller.dart';
import 'package:get/get.dart';

class SellerPlanExpiredBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerPlanExpiredController>(() => SellerPlanExpiredController());
  }
}
