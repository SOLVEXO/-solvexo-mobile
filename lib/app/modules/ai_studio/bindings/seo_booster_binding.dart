import 'package:book_store_app/app/modules/ai_studio/controllers/seo_booster_controller.dart';
import 'package:get/get.dart';

class SeoBoosterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeoBoosterController>(() => SeoBoosterController());
  }
}
