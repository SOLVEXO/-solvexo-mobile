import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Permanent: `ProfileController` is a cross-screen shared controller
    // (Home, Cart, Product Details, Edit Profile, Change Password, seller
    // app bar/storefront all hold `Get.find` references to it from routes
    // that never bound it themselves) — same convention as `AuthController`/
    // `CurrencyController`. A non-permanent registration let GetX's smart
    // management dispose it (and its `TextEditingController`s) once the
    // Profile route left the stack, crashing any other still-mounted screen
    // still reading the disposed instance.
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
  }
}
