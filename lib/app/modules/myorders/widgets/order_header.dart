import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
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
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            const SizedBox(height: 2),
            CustomText(
              text: order.formattedDate,
              fontSize: AppFontSize.tiny,
              color: AppColors.gray600,
            ),
            const SizedBox(height: 2),
            CustomText(
              text: '${order.totalItemCount} item${order.totalItemCount == 1 ? '' : 's'}',
              fontSize: AppFontSize.tiny,
              color: AppColors.gray600,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomText(
            text: order.statusDisplay,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w600,
            color: order.statusColor,
          ),
        ),
      ],
    );
  }
}
