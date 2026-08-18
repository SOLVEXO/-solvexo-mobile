import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/widgets/wave_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardBottomNav extends StatelessWidget {
  final bool showShadow;
  DashboardBottomNav({super.key, this.showShadow = true});

  final controller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeTab = controller.selectedIndex.value;
      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController(), permanent: true);
      }
      final profileController = Get.find<ProfileController>();
      final userProfile = profileController.user.value?.profileImage ?? "";
      final cartCount = controller.cartController.cartItems.length;

      return WaveBottomNavBar(
        activeIndex: activeTab,
        centerBadgeCount: cartCount,
        onTap: controller.changeTab,
        centerItem: WaveNavItem(
          index: 3,
          label: 'Cart',
          iconBuilder: (active) =>
              SvgIcon(assetName: AppIcons.cartIcon, color: AppColors.white, size: 26),
        ),
        sideItems: [
          WaveNavItem(
            index: 0,
            label: 'Home',
            iconBuilder: (active) => SvgIcon(
              assetName: AppIcons.home,
              color: active ? AppColors.primaryColor : AppColors.inactiveGrey,
            ),
          ),
          WaveNavItem(
            index: 1,
            label: 'Search',
            iconBuilder: (active) => SvgIcon(
              assetName: AppIcons.searchIcon,
              color: active ? AppColors.primaryColor : AppColors.inactiveGrey,
            ),
          ),
          WaveNavItem(
            index: 2,
            label: 'Orders',
            iconBuilder: (active) => SvgIcon(
              assetName: AppIcons.billsIcon,
              color: active ? AppColors.primaryColor : AppColors.inactiveGrey,
            ),
          ),
          WaveNavItem(
            index: 4,
            label: 'Account',
            iconBuilder: (active) => userProfile.isEmpty
                ? SvgIcon(
                    assetName: active ? AppIcons.moreFill : AppIcons.more,
                    color: active
                        ? AppColors.primaryColor
                        : AppColors.inactiveGrey,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CommonImageView(
                      url: userProfile,
                      height: 22,
                      width: 22,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ],
      );
    });
  }
}
