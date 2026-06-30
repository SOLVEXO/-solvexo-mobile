import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/shimmer/trip_shimmer.dart';
import 'package:book_store_app/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:book_store_app/app/modules/notifications/widgets/notification_filter_chips.dart';
import 'package:book_store_app/app/modules/notifications/widgets/notification_tile.dart';
import 'package:book_store_app/app/modules/notifications/widgets/notifications_empty_state.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsView extends StatelessWidget {
  NotificationsView({super.key});

  final NotificationsController controller = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(
        title: "Notifications",
        actions: [
          Obx(() {
            final count = controller.unreadCount;
            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: AppDimen.allPadding),
              child: CustomText(
                text: '$count unread',
                fontSize: AppFontSize.tiny,
                color: AppColors.primaryColor,
              ),
            );
          }),
        ],
      ),
      body: Column(
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
                  return TripShimmer(itemCount: 5);
                }

                final items = controller.filteredNotifications;
                if (items.isEmpty) return const NotificationsEmptyState();

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 74,
                    color: AppColors.lightGrey2,
                  ),
                  itemBuilder: (_, i) => NotificationTile(
                    notification: items[i],
                    controller: controller,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// // ── Custom gradient app bar ───────────────────────────────────────────────────

// class _NotificationsAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final NotificationsController controller;
//   const _NotificationsAppBar({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(gradient: AppColors.appbarGradient),
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 8,
//         left: 4,
//         right: 16,
//         bottom: 14,
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               color: AppColors.white,
//               size: 20,
//             ),
//             onPressed: Get.back,
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const CustomText(
//                   text: 'Notifications',
//                   fontSize: AppFontSize.large,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.white,
//                 ),
//                 Obx(() {
//                   final count = controller.unreadCount;
//                   if (count == 0) return const SizedBox.shrink();
//                   return CustomText(
//                     text: '$count unread',
//                     fontSize: AppFontSize.tiny,
//                     color: AppColors.white.withOpacity(0.75),
//                   );
//                 }),
//               ],
//             ),
//           ),
//           Obx(() {
//             if (controller.unreadCount == 0) return const SizedBox.shrink();
//             return GestureDetector(
//               onTap: controller.markAllRead,
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppColors.white.withOpacity(0.18),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: AppColors.white.withOpacity(0.3),
//                   ),
//                 ),
//                 child: const CustomText(
//                   text: 'Mark all read',
//                   fontSize: AppFontSize.tiny,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.white,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(80);
// }
