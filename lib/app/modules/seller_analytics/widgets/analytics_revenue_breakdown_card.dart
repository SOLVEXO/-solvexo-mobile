import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/analytics/payment_method_breakdown_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// One-time order revenue vs recurring subscription revenue, for sellers
/// who also run Subscription plans. Hidden entirely when there's no
/// recurring revenue at all, so it doesn't clutter a store without plans.
class AnalyticsRevenueBreakdownCard extends StatelessWidget {
  final RevenueBreakdownModel data;
  final String? currency;
  const AnalyticsRevenueBreakdownCard({super.key, required this.data, this.currency});

  @override
  Widget build(BuildContext context) {
    if (data.recurringSubscriptionRevenue <= 0) return const SizedBox.shrink();

    final total = data.totalRevenue <= 0 ? 1 : data.totalRevenue;
    final oneTimePct = (data.oneTimeOrderRevenue / total * 100).clamp(0, 100);
    final recurringPct = (data.recurringSubscriptionRevenue / total * 100).clamp(0, 100);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(gradient: AppColors.appbarGradient, borderRadius: BorderRadius.circular(BaseRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Total Business Revenue',
            color: AppColors.white.withOpacity(0.85),
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: BaseSpacing.xxs),
          CustomText(
            text: CurrencyFormatter.amount(data.totalRevenue, currency, decimals: 0),
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
          SizedBox(height: BaseSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(BaseRadius.pill),
            child: Row(
              children: [
                Expanded(flex: oneTimePct.round().clamp(1, 100), child: Container(height: 8, color: AppColors.white)),
                Expanded(flex: recurringPct.round().clamp(1, 100), child: Container(height: 8, color: AppColors.white.withOpacity(0.45))),
              ],
            ),
          ),
          SizedBox(height: BaseSpacing.sm),
          Row(
            children: [
              _Legend(color: AppColors.white, label: 'Orders', value: CurrencyFormatter.amount(data.oneTimeOrderRevenue, currency, decimals: 0)),
              SizedBox(width: BaseSpacing.md),
              _Legend(color: AppColors.white.withOpacity(0.45), label: 'Subscriptions', value: CurrencyFormatter.amount(data.recurringSubscriptionRevenue, currency, decimals: 0)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _Legend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: BaseSpacing.xxs),
        CustomText(
          text: '$label $value',
          color: AppColors.white,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
