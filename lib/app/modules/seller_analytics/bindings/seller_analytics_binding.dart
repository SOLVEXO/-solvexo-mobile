import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:get/get.dart';

class SellerAnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerAnalyticsController>(() => SellerAnalyticsController());
  }
}
