import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller/widgets/seller_app_bar.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_export_button.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_range_selector.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/analytics_tab_bar.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/customers_tab.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/inventory_tab.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/overview_tab.dart';
import 'package:book_store_app/app/modules/seller_analytics/widgets/products_tab.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerAnalyticsView extends StatelessWidget {
  SellerAnalyticsView({super.key});

  final SellerAnalyticsController controller = Get.put(
    SellerAnalyticsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SellerAppBar(title: 'Analytics'),
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(
              BaseSpacing.md,
              BaseSpacing.sm,
              BaseSpacing.md,
              BaseSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: 'Understand your store performance and growth trends',
                    color: AppColors.gray600,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: BaseSpacing.xs),
                AnalyticsRangeSelector(controller: controller),
                SizedBox(width: BaseSpacing.xs),
                AnalyticsExportButton(controller: controller),
              ],
            ),
          ),
          Container(
            color: AppColors.white,
            padding: EdgeInsets.only(bottom: 5),
            child: AnalyticsTabBar(controller: controller),
          ),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: Obx(() {
              return switch (controller.tab.value) {
                AnalyticsTab.overview => OverviewTab(controller: controller),
                AnalyticsTab.products => ProductsTab(controller: controller),
                AnalyticsTab.customers => CustomersTab(controller: controller),
                AnalyticsTab.inventory => InventoryTab(controller: controller),
              };
            }),
          ),
        ],
      ),
    );
  }
}
