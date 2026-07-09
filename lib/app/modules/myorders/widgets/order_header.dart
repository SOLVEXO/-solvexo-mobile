import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
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
            Text(
              order.orderNumber,
              style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: BaseSpacing.xxs / 2),
            Text(order.formattedDate, style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontWeight: FontWeight.w400)),
            SizedBox(height: BaseSpacing.xxs / 2),
            Text(
              '${order.totalItemCount} item${order.totalItemCount == 1 ? '' : 's'}',
              style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xxs),
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(BaseRadius.pill),
          ),
          child: Text(
            order.statusDisplay,
            style: BaseTypography.labelSmall(color: order.statusColor).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
