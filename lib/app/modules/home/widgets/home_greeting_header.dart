import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/messaging/controllers/messaging_badge_controller.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Home's flat greeting header — replaces the gradient `MainAppBar` on this
/// screen only (that component still backs other buyer screens, so it's
/// left untouched). Cart has its own bottom-nav tab already, so it isn't
/// duplicated here; messaging has no other entry point, so its icon stays.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key});

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final messagingBadge = Get.put(MessagingBadgeController());

    return Padding(
      padding: EdgeInsets.fromLTRB(
        BaseSpacing.md,
        BaseSpacing.sm,
        BaseSpacing.md,
        BaseSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Obx(() {
              final user = profileController.user.value;
              final name = (user?.name.trim().isNotEmpty ?? false)
                  ? user!.name.trim()
                  : 'Guest';
              final address = user?.address?.trim();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: _timeGreeting,
                    color: AppColors.gray600,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                    text: name,
                    color: AppColors.black2,
                    fontSize: AppFontSize.regular,
                    fontWeight: FontWeight.bold,
                  ),
                  if (address != null && address.isNotEmpty) ...[
                    SizedBox(height: BaseSpacing.xxs / 2),
                    Row(
                      children: [
                        SvgIcon(
                          assetName: AppIcons.locationIcon,
                          size: 14,
                          color: AppColors.gray600,
                        ),
                        SizedBox(width: BaseSpacing.xxs / 2),
                        Expanded(
                          child: CustomText(
                            text: address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            color: AppColors.gray600,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
          ),
          SizedBox(width: BaseSpacing.sm),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.messagesView),
            child: Obx(
              () => _IconBadge(
                icon: AppIcons.messageIcon,
                count: messagingBadge.unreadCount.value,
              ),
            ),
          ),
          SizedBox(width: BaseSpacing.xs),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.notifications),
            child: const _IconBadge(icon: AppIcons.notificationIcon),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final String icon;
  final int count;
  const _IconBadge({required this.icon, this.count = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(BaseRadius.md),
          ),
          alignment: Alignment.center,
          child: SvgIcon(assetName: icon, size: 22, color: AppColors.black2),
        ),
        if (count > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white, width: 1.2),
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: count > 9 ? '9+' : count.toString(),
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}
