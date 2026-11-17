import 'package:book_store_app/app/modules/seller/controllers/seller_bottom_nav_controller.dart';
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
    return Obx(() => DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
          child: NavigationBar(
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: controller.changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: 'Products',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'Analytics',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'More',
              ),
            ],
          ),
        ));
  }
}
