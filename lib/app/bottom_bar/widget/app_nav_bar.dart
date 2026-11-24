import 'dart:ffi';

import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Material 3 navigation bar for the buyer tabs. Labels always visible, cart
/// count badge, 68 px tall (well above the 44 px touch minimum), safe-area
/// aware, mirrors in RTL. Styling comes from `navigationBarTheme`.
class AppNavBar extends StatelessWidget {
  AppNavBar({super.key});

  /// Extra space screens add at the end of scrolling content. The bar is not
  /// drawn over content (MainView does not extend the body), so this is only
  /// breathing room.
  static const double contentBottomInset = 16;

  final BottomNavController controller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    return Obx(() {
      final count = controller.cartController.cartItems.length;
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: border)),
        ),
        child: NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: [
            NavigationDestination(
              icon: customIcon(AppIcons.home),
              selectedIcon: customIcon(AppIcons.home, isselected: true),
              label: 'Home'.tr,
            ),
            NavigationDestination(
              icon: customIcon(AppIcons.searchIcon),
              selectedIcon: customIcon(AppIcons.searchIcon, isselected: true),
              label: 'Browse'.tr,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text(count > 99 ? '99+' : '$count'),
                child: customIcon(AppIcons.cartIcon),
              ),
              selectedIcon: Badge(
                isLabelVisible: count > 0,
                label: Text(count > 99 ? '99+' : '$count'),
                child: customIcon(AppIcons.cartIcon, isselected: true),
              ),
              label: 'Cart'.tr,
            ),
            NavigationDestination(
              icon: customIcon(AppIcons.ordersIcon),
              selectedIcon: customIcon(AppIcons.ordersIcon, isselected: true),
              label: 'Library'.tr,
            ),
            NavigationDestination(
              icon: customIcon(AppIcons.more),
              selectedIcon: customIcon(AppIcons.more, isselected: true),
              label: 'Account'.tr,
            ),
          ],
        ),
      );
    });
  }

  SvgIcon customIcon(String icon, {bool isselected = false}) => SvgIcon(
    assetName: icon,
    color: isselected ? AppColors.white : AppColors.gray600,
  );
}
