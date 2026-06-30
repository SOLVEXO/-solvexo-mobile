import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/seller/widgets/seller_app_bar.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_card.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_filter_bar.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/orders_empty_state.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/orders_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerOrdersView extends StatelessWidget {
  SellerOrdersView({super.key});

  final SellerOrdersController controller = Get.put(SellerOrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SellerAppBar(title: 'Orders'),
          OrderFilterBar(controller: controller),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: CustomRefreshWrapper(
              onRefresh: controller.refreshData,
              child: Obx(() {
                if (controller.isLoading.value) return const OrdersShimmer();
                final orders = controller.filteredOrders;
                if (orders.isEmpty) return const OrdersEmptyState();
                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimen.allPadding),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => OrderCard(
                    order: orders[i],
                    controller: controller,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
