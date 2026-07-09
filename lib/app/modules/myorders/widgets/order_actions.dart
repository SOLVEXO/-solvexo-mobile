// NOTE (duplication): see custom_action_buttons.dart — same branching logic,
// different visual container. Flagged for consolidation there.
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/widgets/review_item_picker_sheet.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
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
            child: OutlineButton(
              onPressed: () => ReviewItemPickerSheet.show(context, order),
              label: 'Review',
              compact: true,
            ),
          ),
          if (order.canRequestReturn) ...[
            SizedBox(width: BaseSpacing.xs + 2),
            Expanded(
              child: DangerButton(
                onPressed: () => Get.toNamed(Routes.refundRequestView, arguments: order),
                label: 'Request Refund',
                compact: true,
              ),
            ),
          ],
        ],
      );
    }

    if (order.canCancel) {
      return DangerButton(
        onPressed: () => controller.confirmCancel(context, order.orderId),
        label: 'Cancel Order',
        compact: true,
      );
    }

    return const SizedBox.shrink();
  }
}
