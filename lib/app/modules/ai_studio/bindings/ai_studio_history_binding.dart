import 'package:book_store_app/app/modules/ai_studio/controllers/ai_studio_history_controller.dart';
import 'package:get/get.dart';

class AiStudioHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiStudioHistoryController>(() => AiStudioHistoryController());
  }
}
