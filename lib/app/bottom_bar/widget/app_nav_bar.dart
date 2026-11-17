import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
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
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: 'Home'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: 'Browse'.tr,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: count > 0,
                label: Text(count > 99 ? '99+' : '$count'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: count > 0,
                label: Text(count > 99 ? '99+' : '$count'),
                child: const Icon(Icons.shopping_bag_rounded),
              ),
              label: 'Cart'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.local_library_outlined),
              selectedIcon: const Icon(Icons.local_library_rounded),
              label: 'Library'.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: 'Account'.tr,
            ),
          ],
        ),
      );
    });
  }
}
