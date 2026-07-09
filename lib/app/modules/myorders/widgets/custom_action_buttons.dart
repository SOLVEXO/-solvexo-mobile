// NOTE (duplication): this widget's branching logic is near-identical to
// `OrderActions` (order_actions.dart) — same three cases (completed+review,
// canRequestReturn, canCancel), just used in different visual contexts
// (sticky bottom bar here vs. inline in the order card there). Worth
// consolidating into one shared `_OrderActionsRow(compact: bool)` in a
// follow-up pass; not merged now to avoid changing either call site's
// behavior without the ability to compile-test both together.
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/modules/myorders/widgets/review_item_picker_sheet.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
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
            child: PrimaryButton(
              onPressed: () => ReviewItemPickerSheet.show(context, order),
              label: "Write Review",
            ),
          ),
          if (order.canRequestReturn) ...[
            SizedBox(width: BaseSpacing.xs + 2),
            Expanded(
              child: DangerButton(
                onPressed: () => Get.toNamed(Routes.refundRequestView, arguments: order),
                label: "Request Refund",
              ),
            ),
          ],
        ],
      );
    }

    if (order.canCancel) {
      return DangerButton(
        onPressed: () => controller.confirmCancel(context, order.orderId),
        label: "Cancel Order",
      );
    }

    return const SizedBox.shrink();
  }
}
