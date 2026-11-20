import 'package:book_store_app/app/modules/premium/controllers/premium_controller.dart';
import 'package:get/get.dart';

class PremiumBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<PremiumController>(() => PremiumController());
}
