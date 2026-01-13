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

      return Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: AppIcons.home,
              isActive: activeTab == 0,
              onTap: () => controller.changeTab(0),
            ),
            _buildNavItem(
              index: 1,
              icon: AppIcons.billsIcon,
              isActive: activeTab == 1,
              onTap: () => controller.changeTab(1),
              iconSize: 35,
            ),
            _buildNavItem(
              index: 2,
              icon: AppIcons.cartIcon,
              isActive: activeTab == 2,
              onTap: () => controller.changeTab(2),
            ),
            _buildNavItem(
              index: 3,
              icon: activeTab == 3 ? AppIcons.moreFill : AppIcons.more,
              isActive: activeTab == 3,
              onTap: () => controller.changeTab(3),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    double iconSize = 30,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              size: iconSize,
              assetName: icon,
              color: isActive ? AppColors.primaryColor : AppColors.lightGrey,
            ),
            SizedBox(height: 5),
            AnimatedContainer(
              height: 4,
              width: 30,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: isActive ? AppColors.primaryColor : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
