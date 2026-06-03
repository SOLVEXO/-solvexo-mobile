import 'package:book_store_app/app/modules/seller_analytics/views/seller_analytics_view.dart';
import 'package:book_store_app/app/modules/seller_home/views/seller_home_view.dart';
import 'package:book_store_app/app/modules/seller_orders/views/seller_orders_view.dart';
import 'package:book_store_app/app/modules/seller_products/views/seller_products_view.dart';
import 'package:book_store_app/app/modules/seller_settings/views/seller_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerBottomNavController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void changeTab(int index) => selectedIndex.value = index;

  final List<Widget> screens = [
    SellerHomeView(),
    SellerOrdersView(),
    SellerProductsView(),
    SellerAnalyticsView(),
    SellerSettingsView(),
  ];
}
