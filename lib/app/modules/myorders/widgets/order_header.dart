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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText(
                  text: "Order ID: ",
                  fontSize: AppFontSize.small,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: order.id,
                  fontSize: AppFontSize.extraSmall,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            CustomText(text: "${order.createdAt}", color: AppColors.gray600),
          ],
        ),
        Chip(
          label: CustomText(
            text: order.orderStatus,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: order.orderStatus == "delivered"
              ? AppColors.green2
              : Colors.orange,
        ),
      ],
    );
  }
}
