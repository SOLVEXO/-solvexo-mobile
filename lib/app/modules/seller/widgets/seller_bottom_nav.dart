import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller/controllers/seller_bottom_nav_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Seller tabs on the same Material 3 navigation bar as the buyer shell
/// (styling from `navigationBarTheme`). Panel is English-only (docs §6).
class SellerBottomNav extends StatelessWidget {
  const SellerBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerBottomNavController());
    final border = Theme.of(context).colorScheme.outlineVariant;
    return Obx(
      () => DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: border)),
        ),
        child: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: [
            NavigationDestination(
              icon: customIcon(AppIcons.dashboardIcon),
              selectedIcon: customIcon(
                AppIcons.dashboardIcon,
                isselected: true,
              ),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: customIcon(AppIcons.ordersIcon),
              selectedIcon: customIcon(AppIcons.ordersIcon, isselected: true),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: customIcon(AppIcons.reportIcon),
              selectedIcon: customIcon(
                AppIcons.dashboardIcon,
                isselected: true,
              ),
              label: 'Products',
            ),
            NavigationDestination(
              icon: customIcon(AppIcons.anylaticsIcon),
              selectedIcon: customIcon(
                AppIcons.anylaticsIcon,
                isselected: true,
              ),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: customIcon(AppIcons.more),
              selectedIcon: customIcon(AppIcons.moreFill, isselected: true),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  SvgIcon customIcon(String icon, {bool isselected = false}) => SvgIcon(
    assetName: icon,
    color: isselected ? AppColors.white : AppColors.gray600,
  );
}
