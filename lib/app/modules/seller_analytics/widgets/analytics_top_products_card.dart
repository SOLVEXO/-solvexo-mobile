import 'package:book_store_app/app/data/models/analytics/top_product_analytics_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';

class AnalyticsTopProductsCard extends StatelessWidget {
  final List<TopProductAnalyticsModel> products;
  const AnalyticsTopProductsCard({super.key, required this.products});

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
          Text('Top Products by Revenue', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: BaseSpacing.sm),
          if (products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
              child: Text('No product sales in this period', style: BaseTypography.labelSmall(color: AppColors.gray600)),
            )
          else
            ...products.asMap().entries.map((e) => _ProductRow(rank: e.key + 1, product: e.value)),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final int rank;
  final TopProductAnalyticsModel product;
  const _ProductRow({required this.rank, required this.product});

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
            child: Text('$rank', style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w800)),
          ),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: BaseTypography.bodySmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${product.orderCount} orders', style: BaseTypography.labelSmall(color: AppColors.gray600)),
              ],
            ),
          ),
          Text('\$${product.revenue.toStringAsFixed(0)}', style: BaseTypography.bodySmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
