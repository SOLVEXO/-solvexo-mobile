import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/app/modules/seller/controllers/seller_bottom_nav_controller.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/modules/seller_settings/controllers/seller_settings_controller.dart';
import 'package:get/get.dart';

class SellerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SellerBottomNavController>(SellerBottomNavController());
    Get.lazyPut<SellerHomeController>(() => SellerHomeController());
    Get.lazyPut<SellerOrdersController>(() => SellerOrdersController());
    Get.lazyPut<SellerProductsController>(() => SellerProductsController());
    Get.lazyPut<SellerAnalyticsController>(() => SellerAnalyticsController());
    Get.lazyPut<SellerSettingsController>(() => SellerSettingsController());
  }
}
