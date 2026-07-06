import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Lets the buyer pick which line item to review when an order has more
/// than one — a single-item order skips this and goes straight to
/// [Routes.reviewsView].
class ReviewItemPickerSheet {
  ReviewItemPickerSheet._();

  static void show(BuildContext context, OrderModel order) {
    final items = order.allItems;
    if (items.isEmpty) return;

    if (items.length == 1) {
      Get.toNamed(Routes.reviewsView, arguments: {'orderId': order.orderId, 'item': items.first});
      return;
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(0, 12, 0, MediaQuery.of(context).padding.bottom + 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text: 'Which item would you like to review?',
                  fontSize: AppFontSize.small,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black2,
                ),
              ),
            ),
            ...items.map(
              (item) => ListTile(
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.reviewsView, arguments: {'orderId': order.orderId, 'item': item});
                },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CommonImageView(url: item.image ?? '', width: 44, height: 44, fit: BoxFit.cover),
                ),
                title: CustomText(
                  text: item.name,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}
