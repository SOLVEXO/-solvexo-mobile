import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/analytics/top_product_analytics_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class AnalyticsTopProductsCard extends StatelessWidget {
  final List<TopProductAnalyticsModel> products;
  final String? currency;
  const AnalyticsTopProductsCard({super.key, required this.products, this.currency});

  @override
  Widget build(BuildContext context) {
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
            text: 'Top Products by Revenue',
            color: AppColors.black2,
            fontSize: AppFontSize.extraSmall,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: BaseSpacing.sm),
          if (products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
              child: CustomText(
                text: 'No product sales in this period',
                color: AppColors.gray600,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...products.asMap().entries.map((e) => _ProductRow(rank: e.key + 1, product: e.value, currency: currency)),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final int rank;
  final TopProductAnalyticsModel product;
  final String? currency;
  const _ProductRow({required this.rank, required this.product, this.currency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs + 1),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: CustomText(
              text: '$rank',
              color: AppColors.primaryColor,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: product.name,
                  color: AppColors.black2,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  text: '${product.orderCount} orders',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          CustomText(
            text: CurrencyFormatter.amount(product.revenue, currency, decimals: 0),
            color: AppColors.black2,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}
