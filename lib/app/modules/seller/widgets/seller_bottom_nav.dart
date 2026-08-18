import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller/controllers/seller_bottom_nav_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/widgets/wave_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerBottomNav extends StatelessWidget {
  const SellerBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerBottomNavController());
    return Obx(() {
      final activeTab = controller.selectedIndex.value;
      return WaveBottomNavBar(
        activeIndex: activeTab,
        onTap: controller.changeTab,
        centerItem: WaveNavItem(
          index: 0,
          label: 'Dashboard',
          iconBuilder: (active) => SvgIcon(
            assetName: AppIcons.dashboardIcon,
            color: AppColors.white,
            size: 26,
          ),
        ),
        sideItems: [
          _item(index: 1, icon: AppIcons.ordersIcon, label: 'Orders'),
          _item(index: 2, icon: AppIcons.shoppingBag, label: 'Products'),
          _item(index: 3, icon: AppIcons.anylaticsIcon, label: 'Analytics'),
          _item(index: 4, icon: AppIcons.settingIcon, label: 'Settings'),
        ],
      );
    });
  }

  WaveNavItem _item({
    required int index,
    required String icon,
    required String label,
  }) {
    return WaveNavItem(
      index: index,
      label: label,
      iconBuilder: (active) => SvgIcon(
        assetName: icon,
        color: active ? AppColors.primaryColor : AppColors.inactiveGrey,
      ),
    );
  }
}
