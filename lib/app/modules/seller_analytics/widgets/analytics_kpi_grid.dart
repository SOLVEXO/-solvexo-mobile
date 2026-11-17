import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/analytics/analytics_overview_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

/// KPI cards row — revenue, orders, avg order value, repeat buyers — each
/// with a colored up/down/flat change indicator, matching the reference
/// dashboard's "+28.4% YoY" / "+182 vs last period" style.
class AnalyticsKpiGrid extends StatelessWidget {
  final AnalyticsOverviewModel data;
  const AnalyticsKpiGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: BaseSpacing.sm,
      mainAxisSpacing: BaseSpacing.sm,
      childAspectRatio: 1.55,
      children: [
        _KpiCard(
          label: 'Total Revenue',
          value: CurrencyFormatter.compact(data.totalRevenue, data.currency),
          changeText: _percentLabel(data.totalRevenueChangePercent, suffix: 'vs last period'),
          isPositive: (data.totalRevenueChangePercent ?? 0) >= 0,
        ),
        _KpiCard(
          label: 'Total Orders',
          value: '${data.totalOrders}',
          changeText: '${data.totalOrdersChange >= 0 ? '+' : ''}${data.totalOrdersChange} vs last period',
          isPositive: data.totalOrdersChange >= 0,
        ),
        _KpiCard(
          label: 'Avg Order Value',
          value: CurrencyFormatter.amount(data.avgOrderValue, data.currency),
          changeText: _percentLabel(data.avgOrderValueChangePercent, suffix: 'vs last period'),
          isPositive: (data.avgOrderValueChangePercent ?? 0) >= 0,
        ),
        _KpiCard(
          label: 'Repeat Buyers',
          value: '${data.repeatBuyerPercent.toStringAsFixed(0)}%',
          changeText: _trendLabel(data.repeatBuyerTrend),
          isPositive: data.repeatBuyerTrend != 'declining',
          isNeutral: data.repeatBuyerTrend == 'flat',
        ),
      ],
    );
  }

  String _percentLabel(double? percent, {required String suffix}) {
    if (percent == null) return 'No prior data';
    return '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}% $suffix';
  }

  String _trendLabel(String trend) => switch (trend) {
        'improving' => 'Improving',
        'declining' => 'Declining',
        _ => 'Steady',
      };
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String changeText;
  final bool isPositive;
  final bool isNeutral;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.changeText,
    required this.isPositive,
    this.isNeutral = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isNeutral ? AppColors.gray600 : (isPositive ? AppColors.greenSuccess : AppColors.red);
    final icon = isNeutral ? Icons.remove_rounded : (isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);

    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: label.toUpperCase(),
            color: AppColors.gray600,
            fontWeight: FontWeight.w600,
            fontSize: 10,
            letterSpacing: 0.4,
          ),
          SizedBox(height: BaseSpacing.xxs),
          CustomText(
            text: value,
            color: AppColors.black2,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
          SizedBox(height: BaseSpacing.xxs),
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              SizedBox(width: BaseSpacing.xxs / 2),
              Expanded(
                child: CustomText(
                  text: changeText,
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.5,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
