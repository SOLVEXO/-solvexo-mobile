import 'package:book_store_app/app/data/models/analytics/payment_method_breakdown_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';

class AnalyticsPaymentMethodsCard extends StatelessWidget {
  final List<PaymentMethodBreakdownModel> methods;
  const AnalyticsPaymentMethodsCard({super.key, required this.methods});

  @override
  Widget build(BuildContext context) {
    final total = methods.fold<double>(0, (sum, m) => sum + m.revenue);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Methods', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: BaseSpacing.sm),
          if (methods.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
              child: Text('No orders in this period', style: BaseTypography.labelSmall(color: AppColors.gray600)),
            )
          else
            ...methods.map((m) => Padding(
                  padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(m.label, style: BaseTypography.bodySmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600)),
                          Text('\$${m.revenue.toStringAsFixed(0)} · ${m.orderCount} orders', style: BaseTypography.labelSmall(color: AppColors.gray600)),
                        ],
                      ),
                      SizedBox(height: BaseSpacing.xxs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(BaseRadius.pill),
                        child: LinearProgressIndicator(
                          value: total > 0 ? m.revenue / total : 0,
                          minHeight: 6,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
