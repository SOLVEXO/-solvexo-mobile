import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/modules/myorders/widgets/custom_action_buttons.dart';
import 'package:book_store_app/app/modules/myorders/widgets/delivery_status_bar.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_info.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_items.dart';
import 'package:book_store_app/app/modules/myorders/widgets/product_detail_summary.dart';
import 'package:book_store_app/app/modules/myorders/widgets/status_stepper.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderTrackingView extends StatelessWidget {
  final int index;
  OrderTrackingView({super.key, required this.index});
  final controller = Get.put(MyOrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: controller.filteredOrders[index].id),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StatusStepper(),
            const SizedBox(height: 10),
            DeliveryStatusBar(),
            const SizedBox(height: 10),
            OrderInfo(index: index),
            const SizedBox(height: 16),
            OrderItems(index: index),
            const SizedBox(height: 16),
            ProductDetailSummary(index: index),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: CustomActionButtons(index: index),
      ),
    );
  }
}
