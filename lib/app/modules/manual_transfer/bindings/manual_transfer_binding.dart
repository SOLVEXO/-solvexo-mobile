import 'package:book_store_app/app/modules/manual_transfer/controllers/manual_transfer_controller.dart';
import 'package:get/get.dart';

class ManualTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManualTransferController>(() => ManualTransferController());
  }
}
