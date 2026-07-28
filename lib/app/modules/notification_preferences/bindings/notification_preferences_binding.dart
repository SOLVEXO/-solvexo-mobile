import 'package:book_store_app/app/modules/notification_preferences/controllers/notification_preferences_controller.dart';
import 'package:get/get.dart';

class NotificationPreferencesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationPreferencesController>(() => NotificationPreferencesController());
  }
}
