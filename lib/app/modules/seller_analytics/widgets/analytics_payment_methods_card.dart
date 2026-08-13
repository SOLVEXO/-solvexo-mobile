import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/analytics/payment_method_breakdown_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class AnalyticsPaymentMethodsCard extends StatelessWidget {
  final List<PaymentMethodBreakdownModel> methods;
  final String? currency;
  const AnalyticsPaymentMethodsCard({super.key, required this.methods, this.currency});

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
          CustomText(
            text: 'Payment Methods',
            color: AppColors.black2,
            fontSize: AppFontSize.extraSmall,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: BaseSpacing.sm),
          if (methods.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
              child: CustomText(
                text: 'No orders in this period',
                color: AppColors.gray600,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
              ),
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
                          CustomText(
                            text: m.label,
                            color: AppColors.black2,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
                          CustomText(
                            text: '${CurrencyFormatter.amount(m.revenue, currency, decimals: 0)} · ${m.orderCount} orders',
                            color: AppColors.gray600,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
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
