import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/bottom_bar/widget/dashboard_bottom_nav.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainView extends StatelessWidget {
  final controller = Get.put(BottomNavController());

  MainView({super.key});
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: DashboardBottomNav(),
    );
  }
}
