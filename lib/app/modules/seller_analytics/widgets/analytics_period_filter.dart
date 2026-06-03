import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsPeriodFilter extends StatelessWidget {
  final SellerAnalyticsController controller;

  const AnalyticsPeriodFilter({super.key, required this.controller});

  static const _items = [
    (period: AnalyticsPeriod.today, label: 'Today'),
    (period: AnalyticsPeriod.sevenDays, label: '7 Days'),
    (period: AnalyticsPeriod.thirtyDays, label: '30 Days'),
    (period: AnalyticsPeriod.ninetyDays, label: '90 Days'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        AppDimen.allPadding,
        12,
        AppDimen.allPadding,
        12,
      ),
      child: Obx(
        () => Row(
          children: _items
              .map(
                (item) => Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setPeriod(item.period),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: controller.selectedPeriod.value == item.period
                            ? AppColors.primaryColor
                            : AppColors.transparent,
                        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
                        border: Border.all(
                          color: controller.selectedPeriod.value == item.period
                              ? AppColors.primaryColor
                              : AppColors.lightGrey2,
                        ),
                      ),
                      child: CustomText(
                        text: item.label,
                        fontSize: AppFontSize.verySmall,
                        fontWeight: controller.selectedPeriod.value == item.period
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: controller.selectedPeriod.value == item.period
                            ? AppColors.white
                            : AppColors.black2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
