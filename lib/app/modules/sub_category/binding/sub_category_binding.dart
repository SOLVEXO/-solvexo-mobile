import 'package:book_store_app/app/modules/sub_category/controller/sub_category_controller.dart';
import 'package:get/get.dart';

class SubCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubCategoryController>(() => SubCategoryController());
  }
}
