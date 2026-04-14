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
          itemCount: item.orderItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final orderDetail = item.orderItems[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonImageView(
                    url: orderDetail.image,
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 10),

                  /// Expanded allowed inside Row
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: orderDetail.name,
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.w700,
                        ),
                        CustomText(
                          text: "Qty: ${orderDetail.quantity}",
                          color: AppColors.gray600,
                        ),
                      ],
                    ),
                  ),

                  CustomText(
                    text: "\$${orderDetail.price.toStringAsFixed(2)}",
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
