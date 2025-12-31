import 'package:book_store_app/app/modules/auth/otp/controller/notification_controller.dart';
import 'package:book_store_app/app/modules/auth/otp/controller/otp_controller.dart';
import 'package:get/get.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
