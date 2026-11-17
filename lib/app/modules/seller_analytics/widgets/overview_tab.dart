import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_kpi_grid.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_orders_chart.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_payment_methods_card.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_revenue_breakdown_card.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_revenue_chart.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_shimmer.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_top_products_card.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_traffic_donut.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverviewTab extends StatelessWidget {
  final SellerAnalyticsController controller;
  const OverviewTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingOverview.value) return const AnalyticsShimmer();

      return CustomRefreshWrapper(
        onRefresh: controller.loadOverview,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            BaseSpacing.md,
            0,
            BaseSpacing.md,
            Get.height / 8,
          ),
          children: [
            AnalyticsKpiGrid(data: controller.overview.value),
            SizedBox(height: BaseSpacing.sm),
            AnalyticsRevenueBreakdownCard(
              data: controller.revenueBreakdown.value,
              currency: controller.currency,
            ),
            if (controller.revenueBreakdown.value.recurringSubscriptionRevenue >
                0)
              SizedBox(height: BaseSpacing.sm),
            AnalyticsRevenueChart(
              series: controller.revenueSeries,
              granularity: controller.chartGranularity.value,
              currency: controller.currency,
            ),
            SizedBox(height: BaseSpacing.sm),
            AnalyticsOrdersChart(
              series: controller.orderSeries,
              granularity: controller.chartGranularity.value,
            ),
            SizedBox(height: BaseSpacing.sm),
            AnalyticsTrafficDonut(sources: controller.trafficSources),
            SizedBox(height: BaseSpacing.sm),
            AnalyticsTopProductsCard(
              products: controller.topProducts,
              currency: controller.currency,
            ),
            SizedBox(height: BaseSpacing.sm),
            AnalyticsPaymentMethodsCard(
              methods: controller.paymentMethods,
              currency: controller.currency,
            ),
            SizedBox(height: BaseSpacing.lg),
          ],
        ),
      );
    });
  }
}
