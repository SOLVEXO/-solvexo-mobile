import 'package:book_store_app/app/modules/cart/views/cart_view.dart';
import 'package:book_store_app/app/modules/home/views/home_view.dart';
import 'package:book_store_app/app/modules/myorders/views/my_orders_view.dart';
import 'package:book_store_app/app/modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  // Observable index for navigation
  RxInt selectedIndex = 0.obs;

  // Change tab function
  void changeTab(int index) {
    selectedIndex.value = index;
  }

  List<Widget> screens = [
    HomeView(),
    MyOrdersView(),
    CartView(),
    ProfileView(),
  ];
}
