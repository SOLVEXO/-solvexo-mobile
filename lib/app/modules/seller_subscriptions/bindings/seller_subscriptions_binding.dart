import 'package:book_store_app/app/modules/seller_subscriptions/controllers/seller_subscriptions_controller.dart';
import 'package:get/get.dart';

class SellerSubscriptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerSubscriptionsController>(() => SellerSubscriptionsController());
  }
}
