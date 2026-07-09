import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/modules/myorders/widgets/custom_action_buttons.dart';
import 'package:book_store_app/app/modules/myorders/widgets/delivery_status_bar.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_info.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_items.dart';
import 'package:book_store_app/app/modules/myorders/widgets/product_detail_summary.dart';
import 'package:book_store_app/app/modules/myorders/widgets/status_stepper.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderTrackingView extends StatelessWidget {
  final int index;
  OrderTrackingView({super.key, required this.index});

  // Was unconditional `Get.put(MyOrdersController())` — this screen is
  // pushed (not a tab) every time an order is tapped from `MyOrdersView`,
  // so it was replacing that tab's live, shared `MyOrdersController`
  // (with its filtered list / selected tab state) on every single tap.
  MyOrdersController get controller {
    if (!Get.isRegistered<MyOrdersController>()) Get.put(MyOrdersController());
    return Get.find<MyOrdersController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: controller.filteredOrders[index].orderNumber),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        padding: EdgeInsets.all(BaseSpacing.md),
        child: Column(
          children: [
            StatusStepper(),
            SizedBox(height: BaseSpacing.xs + 2),
            DeliveryStatusBar(),
            SizedBox(height: BaseSpacing.xs + 2),
            OrderInfo(index: index),
            SizedBox(height: BaseSpacing.md),
            OrderItems(index: index),
            SizedBox(height: BaseSpacing.md),
            ProductDetailSummary(index: index),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl, vertical: BaseSpacing.xl),
        child: CustomActionButtons(index: index),
      ),
    );
  }
}
