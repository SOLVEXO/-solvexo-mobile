import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardBottomNav extends StatelessWidget {
  final controller = Get.put(BottomNavController());

  DashboardBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int activeTab = controller.selectedIndex.value;

      return BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: (i) => controller.changeTab(i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: activeTab == 0
                ? Column(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        size: 30,
                        assetName: AppIcons.home,
                        color: AppColors.primaryColor,
                      ),
                      borderBottomContainer(true),
                    ],
                  )
                : Column(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        size: 30,
                        assetName: AppIcons.home,
                        color: AppColors.lightGrey,
                      ),
                      borderBottomContainer(false),
                    ],
                  ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: activeTab == 1
                ? Column(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        size: 35,
                        assetName: AppIcons.billsIcon,
                        color: AppColors.primaryColor,
                      ),
                      borderBottomContainer(true),
                    ],
                  )
                : Column(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        size: 35,
                        assetName: AppIcons.billsIcon,
                        color: AppColors.lightGrey,
                      ),
                      borderBottomContainer(false),
                    ],
                  ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: activeTab == 2
                ? Column(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        size: 30,
                        assetName: AppIcons.cartIcon,
                        color: AppColors.primaryColor,
                      ),
                      borderBottomContainer(true),
                    ],
                  )
                : Column(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        size: 30,
                        assetName: AppIcons.cartIcon,
                        color: AppColors.lightGrey,
                      ),
                      borderBottomContainer(false),
                    ],
                  ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: activeTab == 3
                ? Column(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        size: 30,
                        assetName: AppIcons.moreFill,
                        color: AppColors.primaryColor,
                      ),
                      borderBottomContainer(true),
                    ],
                  )
                : Column(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        size: 30,
                        assetName: AppIcons.more,
                        color: AppColors.lightGrey,
                      ),
                      borderBottomContainer(false),
                    ],
                  ),
            label: "",
          ),
        ],
      );
    });
  }

  Widget borderBottomContainer(bool isactive) {
    return AnimatedContainer(
      height: 4,
      width: 30,
      curve: Curves.linear,
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isactive ? AppColors.primaryColor : AppColors.white,
      ),
    );
  }
}
