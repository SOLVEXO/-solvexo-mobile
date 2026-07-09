import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsTabBar extends StatelessWidget {
  final SellerAnalyticsController controller;
  const AnalyticsTabBar({super.key, required this.controller});

  static const _tabs = [
    (AnalyticsTab.overview, 'Overview'),
    (AnalyticsTab.products, 'Products'),
    (AnalyticsTab.customers, 'Customers'),
    (AnalyticsTab.inventory, 'Inventory'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.xs),
        itemBuilder: (_, i) {
          final t = _tabs[i];
          return Obx(() {
            final selected = controller.tab.value == t.$1;
            return GestureDetector(
              onTap: () => controller.changeTab(t.$1),
              child: AnimatedContainer(
                duration: BaseMotion.normal,
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md - 2, vertical: BaseSpacing.xxs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryColor : AppColors.lightGrey10,
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                ),
                child: CustomText(
                  text: t.$2,
                  color: selected ? AppColors.white : AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
