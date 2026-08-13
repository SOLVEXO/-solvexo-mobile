import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/orders_shimmer.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/return_item_card.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/returns_empty_state.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/returns_filter_bar.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/returns_stats_row.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerReturnsView extends StatelessWidget {
  SellerReturnsView({super.key});

  final SellerReturnsController controller = Get.put(SellerReturnsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: 'Returns & Refunds'),
      body: Column(
        children: [
          ReturnsStatsRow(controller: controller),
          ReturnsFilterBar(controller: controller),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: CustomRefreshWrapper(
              onRefresh: controller.refreshData,
              child: Obx(() {
                if (controller.isLoading.value) return const OrdersShimmer();
                final items = controller.filteredRequests;
                if (items.isEmpty) return const ReturnsEmptyState();
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppDimen.allPadding),
                    itemCount: items.length + (controller.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      if (i >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return ReturnItemCard(
                        item: items[i],
                        controller: controller,
                      );
                    },
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
