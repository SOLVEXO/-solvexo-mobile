import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnsFilterBar extends StatelessWidget {
  final SellerReturnsController controller;

  const ReturnsFilterBar({super.key, required this.controller});

  static const _filters = [
    ReturnFilter.all,
    ReturnFilter.requested,
    ReturnFilter.approved,
    ReturnFilter.rejected,
  ];

  static const _labels = {
    ReturnFilter.all: 'All',
    ReturnFilter.requested: 'Requested',
    ReturnFilter.approved: 'Approved',
    ReturnFilter.rejected: 'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimen.allPadding,
            vertical: 10,
          ),
          child: Row(
            children: _filters
                .map((filter) => _FilterChip(
                      label: _labels[filter]!,
                      isActive: controller.selectedFilter.value == filter,
                      onTap: () => controller.setFilter(filter),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimen.draggableBorderRadius),
          border: Border.all(
            color: isActive ? AppColors.primaryColor : AppColors.lightGrey2,
          ),
        ),
        child: CustomText(
          text: label,
          fontSize: AppFontSize.verySmall,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppColors.white : AppColors.black2,
          fontFamily: AppTextStyles.monoFontFamily,
        ),
      ),
    );
  }
}
