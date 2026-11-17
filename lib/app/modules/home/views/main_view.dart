import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/bottom_bar/widget/app_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Buyer shell. Tabs keep their state (IndexedStack) so switching back to
/// Home or Browse does not refetch or lose the scroll position.
class MainView extends StatelessWidget {
  final controller = Get.put(BottomNavController());

  MainView({super.key});

  final Set<int> _visited = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final index = controller.selectedIndex.value;
        _visited.add(index);
        // Lazy IndexedStack: a tab is built the first time it is opened and
        // then kept alive, so start-up does not fire every tab's requests.
        return IndexedStack(
          index: index,
          children: [
            for (var i = 0; i < controller.screens.length; i++)
              _visited.contains(i) ? controller.screens[i] : const SizedBox.shrink(),
          ],
        );
      }),
      bottomNavigationBar: AppNavBar(),
    );
  }
}
