import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_stores/controllers/seller_stores_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoresStatsStrip extends StatelessWidget {
  final SellerStoresController controller;

  const StoresStatsStrip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          border: Border.all(color: AppColors.white.withOpacity(0.2)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _StatCell(value: '${controller.stores.length}', label: 'Stores'),
              _VertLine(),
              _StatCell(value: '10', label: 'Products'),
              _VertLine(),
              _StatCell(value: '\$222', label: 'Revenue'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: value,
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: label,
            fontSize: AppFontSize.tiny,
            color: AppColors.white.withOpacity(0.75),
          ),
        ],
      ),
    );
  }
}

class _VertLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: AppColors.white.withOpacity(0.25));
  }
}
