import 'package:book_store_app/app/modules/seller_notifications/controllers/seller_notifications_controller.dart';
import 'package:get/get.dart';

class SellerNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerNotificationsController>(() => SellerNotificationsController());
  }
}
