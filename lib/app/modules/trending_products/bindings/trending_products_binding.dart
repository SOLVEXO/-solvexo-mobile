import 'package:book_store_app/app/modules/trending_products/controllers/trending_products_controller.dart';
import 'package:get/get.dart';

class TrendingProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrendingProductsController>(() => TrendingProductsController());
  }
}
