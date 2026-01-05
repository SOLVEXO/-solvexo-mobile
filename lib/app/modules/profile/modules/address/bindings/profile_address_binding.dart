import 'package:get/get.dart';

import '../controllers/address_controller.dart';

class ProfileAddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressController>(() => AddressController());
  }
}
