import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:get/get.dart';

import '../controllers/product_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}
