import 'package:get/get.dart';

import '../controllers/mappicker_controller.dart';

class MappickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapPickerController>(() => MapPickerController());
  }
}
