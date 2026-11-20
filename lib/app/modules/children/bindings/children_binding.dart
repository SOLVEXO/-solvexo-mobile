import 'package:book_store_app/app/modules/children/controllers/children_controller.dart';
import 'package:get/get.dart';

class ChildrenBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<ChildrenController>(() => ChildrenController());
}
