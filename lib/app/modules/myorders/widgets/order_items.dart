import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderItems extends StatelessWidget {
  final int index;
  const OrderItems({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();
    final item = controller.orders[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "Your Order",
          fontSize: AppFontSize.medium,
          fontWeight: FontWeight.w800,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: item.orderItems.length,
          itemBuilder: (context, index) {
            final orderDetails = item.orderItems[index];
            return ListTile(
              leading: CommonImageView(url: orderDetails.image, width: 50),
              title: CustomText(
                text: orderDetails.name,
                fontSize: AppFontSize.regular,
                fontWeight: FontWeight.w600,
              ),
              subtitle: CustomText(
                text: "Qty ${orderDetails.quantity}",
                fontSize: AppFontSize.small,
                color: AppColors.gray600,
              ),
              trailing: CustomText(
                text: "\$${orderDetails.price.toStringAsFixed(2)}",
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.w800,
              ),
            );
          },
        ),
      ],
    );
  }
}
