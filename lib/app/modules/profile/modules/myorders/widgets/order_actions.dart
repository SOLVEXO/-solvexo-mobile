import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/modules/profile/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderActions extends StatelessWidget {
  final OrderModel order;
  const OrderActions({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.status != OrderStatus.delivered) return const SizedBox();

    if (!order.isReviewed) {
      return AppButton(
        isOutlined: true,
        textColor: AppColors.primaryColor,
        onPressed: () {
          Get.toNamed(Routes.reviewsView);
        },
        label: "Review Product",
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppButton(
            isOutlined: true,
            textColor: AppColors.primaryColor,
            onPressed: () {
              // Buy again
            },
            label: "Buy Again",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppButton(
            isOutlined: true,
            textColor: AppColors.primaryColor,
            onPressed: () {
              Get.toNamed(Routes.reviewsView);
            },
            label: "View Review",
          ),
        ),
      ],
    );
  }
}
