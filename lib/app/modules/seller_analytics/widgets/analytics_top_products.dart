import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class AnalyticsTopProducts extends StatelessWidget {
  final List<TopProduct> products;

  const AnalyticsTopProducts({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimen.allPadding,
              AppDimen.allPadding,
              AppDimen.allPadding,
              10,
            ),
            child: const CustomText(
              text: 'Top Products',
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const Divider(height: 1, color: AppColors.lightGrey2),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: products.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.lightGrey2),
            itemBuilder: (_, i) => _TopProductRow(product: products[i]),
          ),
        ],
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final TopProduct product;

  const _TopProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.languageBg,
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            ),
            alignment: Alignment.center,
            child: CustomText(
              text: product.emoji,
              fontSize: AppFontSize.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: product.name,
                  fontSize: AppFontSize.extraSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
                const SizedBox(height: 3),
                CustomText(
                  text: '${product.orders} orders',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
          CustomText(
            text: '\$${_fmt(product.revenue)}',
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
