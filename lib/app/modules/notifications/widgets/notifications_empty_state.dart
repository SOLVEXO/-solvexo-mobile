import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.notificationCircleBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: AppColors.greySwatch400,
              ),
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: "You're all caught up!",
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.w600,
              color: AppColors.black2,
            ),
            const SizedBox(height: 6),
            const CustomText(
              text: 'No notifications in this category.',
              fontSize: AppFontSize.verySmall,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
