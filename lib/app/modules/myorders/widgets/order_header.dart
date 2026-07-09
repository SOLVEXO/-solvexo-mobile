import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class OrderHeader extends StatelessWidget {
  final OrderModel order;
  const OrderHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: order.orderNumber,
              color: AppColors.black,
              fontSize: AppFontSize.extraSmall,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: BaseSpacing.xxs / 2),
            CustomText(text: order.formattedDate, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w400),
            SizedBox(height: BaseSpacing.xxs / 2),
            CustomText(
              text: '${order.totalItemCount} item${order.totalItemCount == 1 ? '' : 's'}',
              color: AppColors.gray600,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xxs),
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(BaseRadius.pill),
          ),
          child: CustomText(
            text: order.statusDisplay,
            color: order.statusColor,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
