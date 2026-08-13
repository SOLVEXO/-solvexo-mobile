import 'package:book_store_app/app/modules/store_verification/controllers/store_verification_controller.dart';
import 'package:get/get.dart';

class StoreVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreVerificationController>(
      () => StoreVerificationController(),
    );
  }
}
