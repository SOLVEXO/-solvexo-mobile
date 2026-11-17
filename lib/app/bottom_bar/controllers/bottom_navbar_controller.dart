import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/cart/views/cart_view.dart';
import 'package:book_store_app/app/modules/home/views/home_view.dart';
import 'package:book_store_app/app/modules/library/views/library_view.dart';
import 'package:book_store_app/app/modules/profile/views/profile_view.dart';
import 'package:book_store_app/app/modules/search/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Buyer tabs (docs §10): Home | Browse | Cart | Library | Account.
/// Orders moved into Account; Library holds purchased files and courses.
class BottomNavController extends GetxController {
  static const int home = 0;
  static const int browse = 1;
  static const int cart = 2;
  static const int library = 3;
  static const int account = 4;

  RxInt selectedIndex = 0.obs;
  final CartController cartController = Get.put(CartController());

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  List<Widget> screens = [
    HomeView(),
    SearchView(),
    CartView(),
    const LibraryView(),
    ProfileView(),
  ];
}
