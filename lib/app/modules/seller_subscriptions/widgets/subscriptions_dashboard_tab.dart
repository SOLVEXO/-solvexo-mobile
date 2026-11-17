import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/subscriptions/subscription_dashboard_model.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/controllers/seller_subscriptions_controller.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/widgets/subscriptions_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SubscriptionsDashboardTab extends StatelessWidget {
  final SellerSubscriptionsController controller;
  const SubscriptionsDashboardTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDashboard.value) return const SubscriptionsShimmer();

      final d = controller.dashboard.value;

      return CustomRefreshWrapper(
        onRefresh: controller.loadDashboard,
        child: ListView(
          padding: EdgeInsets.all(BaseSpacing.md),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: BaseSpacing.sm,
              mainAxisSpacing: BaseSpacing.sm,
              childAspectRatio: 1.7,
              children: [
                _StatCard(icon: Icons.trending_up_rounded, label: 'MRR', value: '\$${d.mrr.toStringAsFixed(0)}', color: AppColors.primaryColor),
                _StatCard(icon: Icons.calendar_month_rounded, label: 'ARR', value: '\$${d.arr.toStringAsFixed(0)}', color: AppColors.accentColor),
                _StatCard(icon: Icons.groups_rounded, label: 'Active Subscribers', value: '${d.activeSubscribersCount}', color: AppColors.seaGreen),
                _StatCard(icon: Icons.percent_rounded, label: 'Churn Rate', value: '${d.churnRate.toStringAsFixed(1)}%', color: d.churnRate > 5 ? AppColors.red : AppColors.darkGreen),
              ],
            ),
            SizedBox(height: BaseSpacing.md),
            _RevenueCard(d: d),
            if (d.planBreakdown.isNotEmpty) ...[
              SizedBox(height: BaseSpacing.md),
              _SectionCard(
                title: 'Revenue by Plan',
                child: Column(
                  children: d.planBreakdown
                      .map((p) => Padding(
                            padding: EdgeInsets.only(bottom: BaseSpacing.xs + 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomText(text: p.planName, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                                ),
                                CustomText(text: '${p.subscriberCount} subs', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                                SizedBox(width: BaseSpacing.sm),
                                CustomText(text: '\$${p.mrrContributionUSD.toStringAsFixed(0)}/mo', color: AppColors.primaryColor, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
            if (d.recentInvoices.isNotEmpty) ...[
              SizedBox(height: BaseSpacing.md),
              _SectionCard(
                title: 'Recent Invoices',
                child: Column(
                  children: d.recentInvoices
                      .map((i) => Padding(
                            padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs + 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(text: i.invoiceNumber, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                                      if (i.paidAt != null)
                                        CustomText(text: DateFormat('MMM d, yyyy').format(i.paidAt!.toLocal()), color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                                    ],
                                  ),
                                ),
                                CustomText(text: '\$${i.amountUSD.toStringAsFixed(2)}', color: AppColors.greenSuccess, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
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

class _RevenueCard extends StatelessWidget {
  final SubscriptionDashboardModel d;
  const _RevenueCard({required this.d});

  @override
  Widget build(BuildContext context) {
    final isUp = d.revenueGrowthPercent >= 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(gradient: AppColors.appbarGradient, borderRadius: BorderRadius.circular(BaseRadius.lg)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Revenue This Month', color: AppColors.white.withOpacity(0.85), fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                SizedBox(height: BaseSpacing.xxs),
                CustomText(text: '\$${d.revenueThisMonth.toStringAsFixed(0)}', color: AppColors.white, fontSize: AppFontSize.regular, fontWeight: FontWeight.w800),
              ],
            ),
          ),
          Row(
            children: [
              Icon(isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: AppColors.white, size: 16),
              CustomText(text: '${d.revenueGrowthPercent.abs().toStringAsFixed(1)}%', color: AppColors.white, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg), boxShadow: BaseShadows.forLevel(BaseElevation.level1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.sm)),
            alignment: Alignment.center,
            child: Icon(icon, size: 17, color: color),
          ),
          SizedBox(height: BaseSpacing.xs),
          CustomText(text: value, color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.w800),
          CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
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
