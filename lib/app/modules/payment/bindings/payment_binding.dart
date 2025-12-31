import 'package:book_store_app/app/modules/payment/controllers/payment_verification_controller.dart';
import 'package:get/get.dart';

import '../controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentController>(() => PaymentController());
    Get.lazyPut<PaymentVerificationController>(
      () => PaymentVerificationController(),
    );
  }
}
