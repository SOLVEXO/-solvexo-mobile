import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/shimmer/trip_shimmer.dart';
import 'package:book_store_app/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:book_store_app/app/modules/notifications/widgets/notification_filter_chips.dart';
import 'package:book_store_app/app/modules/notifications/widgets/notification_tile.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/base/base_view.dart';
import 'package:book_store_app/core/widgets/base_empty_view.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsView extends BaseView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Color? get backgroundColor => AppColors.background;

  @override
  Future<void> Function()? get onRefresh => controller.refresh;

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return CustomAppBarTwo(
      title: "Notifications",
      actions: [
        Obx(() {
          final count = controller.unreadCount;
          if (count == 0) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(right: AppDimen.allPadding),
            child: GestureDetector(
              onTap: controller.markAllRead,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(
                  text: '$count unread · Mark all read',
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        NotificationFilterChips(controller: controller),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.lightGrey2),
        Expanded(
          child: CustomRefreshWrapper(
            onRefresh: controller.refresh,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const TripShimmer(itemCount: 5);
              }

              final items = controller.filteredNotifications;
              if (items.isEmpty) {
                return const BaseEmptyView(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications',
                  subtitle: 'You\'re all caught up — new updates will show up here.',
                );
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 74, color: AppColors.lightGrey2),
                itemBuilder: (_, i) => NotificationTile(notification: items[i], controller: controller),
              );
            }),
          ),
        ),
      ],
    );
  }
}
