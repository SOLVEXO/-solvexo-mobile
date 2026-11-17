import 'package:book_store_app/app/modules/ai_studio/controllers/ai_generation_detail_controller.dart';
import 'package:get/get.dart';

class AiGenerationDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AiGenerationDetailController>(AiGenerationDetailController());
  }
}
