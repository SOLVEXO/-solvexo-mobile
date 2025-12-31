import 'package:get/get.dart';

import '../controllers/profile_address_controller.dart';

class ProfileAddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileAddressController>(
      () => ProfileAddressController(),
    );
  }
}
