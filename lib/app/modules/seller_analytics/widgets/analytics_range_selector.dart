import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsRangeSelector extends StatelessWidget {
  final SellerAnalyticsController controller;
  const AnalyticsRangeSelector({super.key, required this.controller});

  void _openSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4, margin: EdgeInsets.only(bottom: BaseSpacing.md), decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2))),
            ),
            Text('Select Range', style: BaseTypography.titleMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: BaseSpacing.sm),
            Obx(
              () => Column(
                children: kAnalyticsRangeLabels.entries.map((e) {
                  final selected = controller.range.value == e.key;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.value, style: BaseTypography.bodySmall(color: selected ? AppColors.primaryColor : AppColors.black2).copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                    trailing: selected ? const Icon(Icons.check_rounded, color: AppColors.primaryColor) : null,
                    onTap: () {
                      controller.changeRange(e.key);
                      Get.back();
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Obx(
        () => Container(
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm + 2, vertical: BaseSpacing.xs + 2),
          decoration: BoxDecoration(border: Border.all(color: AppColors.lightGrey2), borderRadius: BorderRadius.circular(BaseRadius.md)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kAnalyticsRangeLabels[controller.range.value] ?? controller.range.value,
                style: BaseTypography.labelSmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(width: BaseSpacing.xxs),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.gray600),
            ],
          ),
        ),
      ),
    );
  }
}
