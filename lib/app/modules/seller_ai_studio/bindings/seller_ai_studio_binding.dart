import 'package:book_store_app/app/modules/seller_ai_studio/controllers/seller_ai_studio_controller.dart';
import 'package:get/get.dart';

class SellerAiStudioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerAiStudioController>(() => SellerAiStudioController());
  }
}
