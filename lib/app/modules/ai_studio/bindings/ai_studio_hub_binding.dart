import 'package:book_store_app/app/modules/ai_studio/controllers/ai_studio_hub_controller.dart';
import 'package:get/get.dart';

class AiStudioHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiStudioHubController>(() => AiStudioHubController());
  }
}
