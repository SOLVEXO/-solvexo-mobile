import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
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
        Text('Your Order', style: BaseTypography.titleMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w800)),
        ListView.builder(
          itemCount: item.allItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final orderDetail = item.allItems[index];

            return Padding(
              padding: EdgeInsets.only(bottom: BaseSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonImageView(url: orderDetail.image, height: 50, width: 50),
                  SizedBox(width: BaseSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderDetail.name,
                          style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text("Qty: ${orderDetail.quantity}", style: BaseTypography.bodyMedium(color: AppColors.gray600)),
                      ],
                    ),
                  ),
                  Text(
                    "\$${orderDetail.price.toStringAsFixed(2)}",
                    style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.bold),
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
