import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderActions extends StatelessWidget {
  final OrderModel order;
  const OrderActions({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();

    if (order.isCompleted) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              isOutlined: true,
              textColor: AppColors.primaryColor,
              onPressed: () {},
              label: 'Buy Again',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppButton(
              isOutlined: true,
              textColor: AppColors.primaryColor,
              onPressed: () => Get.toNamed(Routes.reviewsView),
              label: 'Review',
            ),
          ),
        ],
      );
    }

    if (order.canCancel) {
      return AppButton(
        isOutlined: true,
        textColor: AppColors.red,
        onPressed: () => controller.cancelOrder(order.orderId),
        label: 'Cancel Order',
      );
    }

    return const SizedBox.shrink();
  }
}
