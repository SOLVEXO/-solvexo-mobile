import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/home/widgets/icon_badge.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/seller/controllers/seller_bottom_nav_controller.dart';
import 'package:book_store_app/app/modules/notifications/controllers/notifications_badge_controller.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messaging_badge_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerAppBar extends StatelessWidget {
  final String title;

  SellerAppBar({super.key, this.title = 'Dashboard'});
  final SellerBottomNavController controller = Get.put(
    SellerBottomNavController(),
  );
  final SellerMessagingBadgeController messagingBadge = Get.put(
    SellerMessagingBadgeController(),
  );
  final NotificationsBadgeController notificationsBadge = Get.put(
    NotificationsBadgeController(),
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimen.borderRadius),
          bottomRight: Radius.circular(AppDimen.borderRadius),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.storeName.value.isNotEmpty) ...[
                    CustomText(
                      text: controller.storeName.value,
                      fontFamily: AppTextStyles.headingFontFamily,
                      fontSize: AppFontSize.small2,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                  CustomText(
                    text: title,
                    fontFamily: AppTextStyles.headingFontFamily,
                    fontSize: AppFontSize.large,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.sellerMessages),
            child: Obx(
              () => IconBadge(
                icon: AppIcons.messageIcon,
                count: messagingBadge.unreadCount.value,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.notifications),
            child: Obx(
              () => IconBadge(
                icon: AppIcons.notificationIcon,
                count: notificationsBadge.unreadCount.value,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() {
            if (!Get.isRegistered<ProfileController>()) {
              Get.put(ProfileController(), permanent: true);
            }
            final profileController = Get.find<ProfileController>();
            final user = profileController.user.value;
            final imageUrl = user?.profileImage ?? '';
            final name = user?.name ?? '';
            final initials = name.trim().isNotEmpty
                ? name
                      .trim()
                      .split(' ')
                      .map((w) => w[0])
                      .take(2)
                      .join()
                      .toUpperCase()
                : 'Me';

            return GestureDetector(
              onTap: () => Get.toNamed(Routes.sellerEditProfile),
              child: imageUrl.isNotEmpty
                  ? ClipOval(
                      child: CommonImageView(
                        url: imageUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        text: initials,
                        fontSize: 13,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }
}
