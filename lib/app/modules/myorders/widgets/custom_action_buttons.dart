import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/modules/myorders/widgets/review_item_picker_sheet.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CustomActionButtons extends StatelessWidget {
  final int index;
  const CustomActionButtons({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();
    final order = controller.orders[index];

    if (order.isCompleted) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: () => ReviewItemPickerSheet.show(context, order),
              label: "Write Review",
            ),
          ),
          if (order.canRequestReturn) ...[
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                isOutlined: true,
                textColor: AppColors.red,
                onPressed: () => Get.toNamed(Routes.refundRequestView, arguments: order),
                label: "Request Refund",
              ),
            ),
          ],
        ],
      );
    }

    if (order.canCancel) {
      return AppButton(
        isOutlined: true,
        textColor: AppColors.red,
        onPressed: () => controller.confirmCancel(context, order.orderId),
        label: "Cancel Order",
      );
    }

    return const SizedBox.shrink();
  }
}
