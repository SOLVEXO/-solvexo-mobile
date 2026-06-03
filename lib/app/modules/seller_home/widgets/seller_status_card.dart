import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerStatusCard extends StatelessWidget {
  SellerStatusCard({super.key});
  final SellerHomeController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: EdgeInsets.all(AppDimen.allPadding),
        padding: EdgeInsets.all(AppDimen.allPadding),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: "Today's Revenue",
              fontSize: AppFontSize.small2,
              color: AppColors.iosGrey,
            ),
            const SizedBox(height: 6),
            CustomText(
              text: '\$${controller.todayRevenue.value.toStringAsFixed(2)}',
              fontSize: AppFontSize.veryLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward,
                  color: AppColors.greenSuccess,
                  size: 14,
                ),
                const SizedBox(width: 4),
                CustomText(
                  text: '+${controller.revenueChange.value}% vs yesterday',
                  fontSize: 13,
                  color: AppColors.greenSuccess,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.darkDivider, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                _statItem('Orders', controller.ordersCount.value.toString()),
                _statItem('Visitors', controller.visitors.value),
                _statItem('Conv.', '${controller.conversionRate.value}%'),
                _statItem(
                  'Avg',
                  '\$${controller.avgOrderValue.value.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: label, fontSize: 11, color: AppColors.iosGrey),
          const SizedBox(height: 4),
          CustomText(
            text: value,
            fontSize: 15,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
