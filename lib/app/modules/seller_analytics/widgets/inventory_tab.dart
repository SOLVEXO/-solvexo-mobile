import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryTab extends StatelessWidget {
  final SellerAnalyticsController controller;
  const InventoryTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingInventory.value) return const AnalyticsShimmer();

      final data = controller.inventory.value;
      final isEmpty = data.outOfStock.isEmpty && data.fastMoving.isEmpty && data.slowMoving.isEmpty && data.reorderSuggestions.isEmpty;

      return CustomRefreshWrapper(
        onRefresh: controller.loadInventory,
        child: ListView(
          padding: EdgeInsets.all(BaseSpacing.md),
          children: [
            if (data.note.isNotEmpty) _NoteBanner(text: data.note),
            if (data.note.isNotEmpty) SizedBox(height: BaseSpacing.md),
            if (isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 44, color: AppColors.lightGrey),
                      SizedBox(height: BaseSpacing.sm),
                      Text('Nothing to flag right now', style: BaseTypography.bodySmall(color: AppColors.gray600)),
                    ],
                  ),
                ),
              )
            else ...[
              if (data.reorderSuggestions.isNotEmpty) ...[
                _SectionCard(
                  title: 'Reorder Suggestions',
                  icon: Icons.shopping_cart_checkout_rounded,
                  iconColor: AppColors.orange,
                  items: data.reorderSuggestions
                      .map((e) => _Row(name: e.name, trailing: '${e.currentStock} left · ~${e.estimatedWeeksRemaining?.toStringAsFixed(1)}w'))
                      .toList(),
                ),
                SizedBox(height: BaseSpacing.md),
              ],
              if (data.outOfStock.isNotEmpty) ...[
                _SectionCard(
                  title: 'Out of Stock',
                  icon: Icons.remove_shopping_cart_outlined,
                  iconColor: AppColors.red,
                  items: data.outOfStock.map((e) => _Row(name: e.name, trailing: '${e.unitsSoldLast30Days} sold (30d)')).toList(),
                ),
                SizedBox(height: BaseSpacing.md),
              ],
              if (data.fastMoving.isNotEmpty) ...[
                _SectionCard(
                  title: 'Fast Moving',
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.greenSuccess,
                  items: data.fastMoving.map((e) => _Row(name: e.name, trailing: '${e.sellThroughRatePercent?.toStringAsFixed(0)}% sell-through')).toList(),
                ),
                SizedBox(height: BaseSpacing.md),
              ],
              if (data.slowMoving.isNotEmpty)
                _SectionCard(
                  title: 'Slow Moving',
                  icon: Icons.trending_down_rounded,
                  iconColor: AppColors.gray600,
                  items: data.slowMoving.map((e) => _Row(name: e.name, trailing: '${e.sellThroughRatePercent?.toStringAsFixed(0)}% sell-through')).toList(),
                ),
            ],
            SizedBox(height: BaseSpacing.xxl),
          ],
        ),
      );
    });
  }
}

class _NoteBanner extends StatelessWidget {
  final String text;
  const _NoteBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(BaseRadius.md),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryColor),
          SizedBox(width: BaseSpacing.xs),
          Expanded(child: Text(text, style: BaseTypography.labelSmall(color: AppColors.primaryColor))),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_Row> items;
  const _SectionCard({required this.title, required this.icon, required this.iconColor, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg), boxShadow: BaseShadows.forLevel(BaseElevation.level1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              SizedBox(width: BaseSpacing.xs),
              Text(title, style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${items.length}', style: BaseTypography.labelSmall(color: AppColors.gray600)),
            ],
          ),
          SizedBox(height: BaseSpacing.xs),
          ...items.take(10),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String name;
  final String trailing;
  const _Row({required this.name, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs + 1),
      child: Row(
        children: [
          Expanded(child: Text(name, style: BaseTypography.bodySmall(color: AppColors.black2), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(trailing, style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
