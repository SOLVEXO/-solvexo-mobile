import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderItems extends StatelessWidget {
  const OrderItems({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "Your Order",
          fontSize: AppFontSize.medium,
          fontWeight: FontWeight.w800,
        ),
        ...controller.orders.map((item) {
          return ListTile(
            leading: Image.asset(item.image, width: 50),
            title: CustomText(
              text: item.productName,
              fontSize: AppFontSize.regular,
              fontWeight: FontWeight.w600,
            ),
            subtitle: CustomText(
              text:
                  "${item.totalItems} item x \$${item.totalAmount.toStringAsFixed(2)}",
              fontSize: AppFontSize.small,
              color: AppColors.gray600,
            ),
          );
        }),
      ],
    );
  }
}
