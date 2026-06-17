import 'package:book_store_app/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:get/get.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}
