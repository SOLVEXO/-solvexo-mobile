import 'package:book_store_app/app/modules/ai_studio/controllers/price_optimizer_controller.dart';
import 'package:get/get.dart';

class PriceOptimizerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PriceOptimizerController>(() => PriceOptimizerController());
  }
}
