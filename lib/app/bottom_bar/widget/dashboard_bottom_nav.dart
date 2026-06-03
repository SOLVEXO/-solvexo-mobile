import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardBottomNav extends StatelessWidget {
  final bool showShadow;
  DashboardBottomNav({super.key, this.showShadow = true});

  final controller = Get.put(BottomNavController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int activeTab = controller.selectedIndex.value;
      // final homeController = Get.put(HomeController());
      final profileController = Get.put(ProfileController());
      final user = profileController.user.value;
      final userProfile = user?.profileImage ?? "";
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(showShadow ? 0.1 : 0),
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
              onTap: () {
                controller.changeTab(0);
                // homeController.refreshHome();
              },
            ),
            _buildNavItem(
              index: 1,
              icon: AppIcons.searchIcon,
              isActive: activeTab == 1,
              onTap: () => controller.changeTab(1),
              iconSize: 35,
            ),
            _buildNavItem(
              index: 2,
              icon: AppIcons.billsIcon,
              isActive: activeTab == 2,
              onTap: () => controller.changeTab(2),
              iconSize: 25,
            ),
            _buildNavItem(
              index: 3,
              icon: AppIcons.cartIcon,
              isCartIcon: true,
              isActive: activeTab == 3,
              onTap: () => controller.changeTab(3),
            ),
            _buildNavItem(
              index: 4,
              profile: true,
              url: userProfile.isEmpty ? null : userProfile,
              icon: activeTab == 4 ? AppIcons.moreFill : AppIcons.more,
              isActive: activeTab == 4,
              onTap: () => controller.changeTab(4),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    String? url,
    required bool isActive,
    required VoidCallback onTap,
    double iconSize = 22,
    bool isCartIcon = false,
    bool profile = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryColor.withOpacity(0.1),
        highlightColor: AppColors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CommonImageView(
                  height: iconSize,
                  width: iconSize,
                  svgPath: profile ? null : icon,
                  url: profile ? url : null,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(profile ? 50 : 0),
                  color: profile
                      ? null
                      : (isActive
                            ? AppColors.primaryColor
                            : AppColors.lightGrey),
                ),

                if (isCartIcon)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Obx(() {
                      final count = controller.cartController.cartItems.length;

                      if (count == 0) return const SizedBox();

                      return Container(
                        // padding: const EdgeInsets.symmetric(
                        //   horizontal: 2,
                        //   vertical: 2,
                        // ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: CustomText(
                          text: count > 9 ? "9+" : count.toString(),
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
              ],
            ),

            const SizedBox(height: 5),

            AnimatedContainer(
              height: 4,
              width: 20,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
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
