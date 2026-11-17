import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/analytics/product_performance_model.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsTab extends StatelessWidget {
  final SellerAnalyticsController controller;
  const ProductsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingProducts.value && controller.products.isEmpty)
        return const AnalyticsShimmer();

      if (controller.products.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(BaseSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppColors.lightGrey,
                ),
                SizedBox(height: BaseSpacing.sm),
                CustomText(
                  text: 'No products yet',
                  color: AppColors.black2,
                  fontSize: AppFontSize.extraSmall,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        );
      }

      return CustomRefreshWrapper(
        onRefresh: controller.loadProducts,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            BaseSpacing.md,
            BaseSpacing.sm,
            BaseSpacing.md,
            Get.height / 8,
          ),
          itemCount:
              controller.products.length +
              (controller.productsPage.value <
                      controller.productsTotalPages.value
                  ? 1
                  : 0),
          separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
          itemBuilder: (_, i) {
            if (i >= controller.products.length) {
              return Center(
                child: TextButton(
                  onPressed: controller.isLoadingProducts.value
                      ? null
                      : () => controller.loadProducts(loadMore: true),
                  child: controller.isLoadingProducts.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : CustomText(
                          text: 'Load More',
                          color: AppColors.primaryColor,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w700,
                        ),
                ),
              );
            }
            return _ProductRow(
              product: controller.products[i],
              currency: controller.currency,
            );
          },
        ),
      );
    });
  }
}

class _ProductRow extends StatelessWidget {
  final ProductPerformanceModel product;
  final String? currency;
  const _ProductRow({required this.product, this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: product.name,
                  color: AppColors.black2,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (product.isLowPerformer)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSpacing.xs,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(BaseRadius.pill),
                  ),
                  child: CustomText(
                    text: 'Low performer',
                    color: AppColors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          SizedBox(height: BaseSpacing.xs),
          Row(
            children: [
              _Stat(
                icon: Icons.shopping_bag_outlined,
                label: '${product.unitsSold} sold',
              ),
              SizedBox(width: BaseSpacing.md),
              _Stat(
                icon: Icons.attach_money_rounded,
                label: CurrencyFormatter.amount(
                  product.revenue,
                  currency,
                  decimals: 0,
                ),
              ),
              SizedBox(width: BaseSpacing.md),
              _Stat(
                icon: Icons.inventory_outlined,
                label: '${product.currentStock} in stock',
              ),
            ],
          ),
          if (product.refundRatePercent > 0) ...[
            SizedBox(height: BaseSpacing.xxs),
            CustomText(
              text:
                  '${product.refundRatePercent.toStringAsFixed(1)}% refund rate',
              color: AppColors.red,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.gray600),
        SizedBox(width: BaseSpacing.xxs / 2),
        CustomText(
          text: label,
          color: AppColors.gray600,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
