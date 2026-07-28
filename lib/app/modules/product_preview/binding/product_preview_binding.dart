import 'package:book_store_app/app/modules/product_preview/controller/product_preview_controller.dart';
import 'package:get/get.dart';

class ProductPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductPreviewController>(() => ProductPreviewController());
  }
}
