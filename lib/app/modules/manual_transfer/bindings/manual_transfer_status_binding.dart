import 'package:book_store_app/app/modules/manual_transfer/controllers/manual_transfer_status_controller.dart';
import 'package:get/get.dart';

class ManualTransferStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManualTransferStatusController>(() => ManualTransferStatusController());
  }
}
