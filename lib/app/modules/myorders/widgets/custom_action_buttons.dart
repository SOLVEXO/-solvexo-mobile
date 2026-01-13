import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CustomActionButtons extends StatelessWidget {
  const CustomActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();
    if (controller.canReview) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              isOutlined: true,
              textColor: AppColors.primaryColor,
              onPressed: () {},
              label: "Buy Again",
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppButton(
              onPressed: () {
                Get.toNamed(Routes.reviewsView);
              },
              label: "Write Review",
            ),
          ),
        ],
      );
    }

    if (controller.canRefund) {
      return AppButton(
        onPressed: () {
          Get.toNamed(Routes.refundRequestView);
        },
        label: "Request Refund",
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppButton(
            isOutlined: true,
            textColor: AppColors.primaryColor,
            onPressed: () {},
            label: "Change Address",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppButton(onPressed: () {}, label: "Cancel Order"),
        ),
      ],
    );
  }
}
