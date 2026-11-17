import 'package:book_store_app/app/modules/ai_studio/controllers/image_enhancer_controller.dart';
import 'package:get/get.dart';

class ImageEnhancerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageEnhancerController>(() => ImageEnhancerController());
  }
}
