import 'package:book_store_app/app/modules/ai_studio/controllers/worksheet_builder_controller.dart';
import 'package:get/get.dart';

class WorksheetBuilderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorksheetBuilderController>(() => WorksheetBuilderController());
  }
}
