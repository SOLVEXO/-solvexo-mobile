import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/seller/widgets/seller_app_bar.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_period_filter.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_revenue_card.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_shimmer.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_stats_grid.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_top_products.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerAnalyticsView extends StatelessWidget {
  SellerAnalyticsView({super.key});

  final SellerAnalyticsController controller = Get.put(
    SellerAnalyticsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SellerAppBar(title: 'Analytics'),
          AnalyticsPeriodFilter(controller: controller),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value || controller.data.value == null) {
                return const AnalyticsShimmer();
              }

              final data = controller.data.value!;

              return CustomRefreshWrapper(
                onRefresh: controller.refreshData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimen.allPadding,
                  ),
                  children: [
                    AnalyticsRevenueCard(data: data),
                    const SizedBox(height: 16),
                    AnalyticsStatsGrid(stats: data.stats),
                    const SizedBox(height: 16),
                    AnalyticsTopProducts(products: data.topProducts),
                    const SizedBox(height: AppDimen.allPadding),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
