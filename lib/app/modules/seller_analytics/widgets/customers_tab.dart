import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/analytics/customer_analytics_model.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomersTab extends StatelessWidget {
  final SellerAnalyticsController controller;
  const CustomersTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCustomers.value) return const AnalyticsShimmer();

      final data = controller.customers.value;

      return CustomRefreshWrapper(
        onRefresh: controller.loadCustomers,
        child: ListView(
          padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.sm, BaseSpacing.md, BaseSpacing.md),
          children: [
            _NewVsReturningCard(data: data),
            SizedBox(height: BaseSpacing.md),
            _SectionCard(
              title: 'Average Lifetime Value',
              child: CustomText(text: '\$${data.averageLifetimeValue.toStringAsFixed(2)}', color: AppColors.primaryColor, fontSize: 26, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: BaseSpacing.md),
            _SectionCard(
              title: 'Top Customers by Lifetime Value',
              child: data.topCustomersByLtv.isEmpty
                  ? CustomText(text: 'No customers yet', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600)
                  : Column(children: data.topCustomersByLtv.map((c) => _CustomerRow(customer: c)).toList()),
            ),
            if (data.geographicBreakdown.isNotEmpty) ...[
              SizedBox(height: BaseSpacing.md),
              _SectionCard(
                title: 'Orders by Region',
                child: Column(
                  children: data.geographicBreakdown
                      .map((g) => Padding(
                            padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs + 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: g.state, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                                CustomText(text: '${g.orders} orders · \$${g.revenue.toStringAsFixed(0)}', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
            SizedBox(height: BaseSpacing.xxl),
          ],
        ),
      );
    });
  }
}

class _NewVsReturningCard extends StatelessWidget {
  final CustomerAnalyticsModel data;
  const _NewVsReturningCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final hasActivity = data.newVsReturning.any((p) => p.newCustomers > 0 || p.returningCustomers > 0);
    final maxY = data.newVsReturning
        .map((p) => p.newCustomers + p.returningCustomers)
        .fold<int>(0, (a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg), boxShadow: BaseShadows.forLevel(BaseElevation.level1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(text: 'New vs Returning', color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w700),
              const Spacer(),
              _Dot(color: AppColors.primaryColor, label: 'New'),
              SizedBox(width: BaseSpacing.sm),
              _Dot(color: AppColors.lightGrey, label: 'Returning'),
            ],
          ),
          SizedBox(height: BaseSpacing.md),
          if (!hasActivity)
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.xl),
              child: Center(child: CustomText(text: 'No customer activity in this period', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600)),
            )
          else
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: maxY == 0 ? 10 : maxY * 1.2,
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.lightGrey2, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: data.newVsReturning.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barsSpace: 2,
                      barRods: [
                        BarChartRodData(toY: e.value.newCustomers.toDouble(), color: AppColors.primaryColor, width: 8, borderRadius: BorderRadius.circular(3)),
                        BarChartRodData(toY: e.value.returningCustomers.toDouble(), color: AppColors.lightGrey, width: 8, borderRadius: BorderRadius.circular(3)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: BaseSpacing.xxs),
        CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg), boxShadow: BaseShadows.forLevel(BaseElevation.level1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w700),
          SizedBox(height: BaseSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  final TopCustomerModel customer;
  const _CustomerRow({required this.customer});

  @override
  Widget build(BuildContext context) {
    final initials = customer.name.trim().isNotEmpty ? customer.name.trim()[0].toUpperCase() : '?';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: CustomText(text: initials, color: AppColors.primaryColor, fontSize: AppFontSize.tiny, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: customer.name, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                CustomText(text: '${customer.totalOrders} orders', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
              ],
            ),
          ),
          CustomText(text: '\$${customer.lifetimeValue.toStringAsFixed(0)}', color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w800),
        ],
      ),
    );
  }
}
