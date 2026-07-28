import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnsStatsRow extends StatelessWidget {
  final SellerReturnsController controller;

  const ReturnsStatsRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
        AppDimen.allPadding,
        AppDimen.allPadding,
        AppDimen.allPadding,
        12,
      ),
      child: Obx(() {
        final stats = controller.stats.value;
        return Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Open Requests',
                value: '${stats.openRequests}',
                color: AppColors.amberDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Return Rate',
                value: stats.returnRate,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Refunded (30d)',
                value: '\$${stats.totalRefunded.toStringAsFixed(2)}',
                color: AppColors.darkGreen,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: value,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.bold,
            color: color,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: label,
            fontSize: AppFontSize.tiny,
            color: AppColors.grey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
