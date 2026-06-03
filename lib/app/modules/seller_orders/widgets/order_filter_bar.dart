import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderFilterBar extends StatelessWidget {
  final SellerOrdersController controller;

  const OrderFilterBar({super.key, required this.controller});

  static const _filters = [
    OrderStatus.all,
    OrderStatus.pending,
    OrderStatus.processing,
    OrderStatus.fulfilled,
    OrderStatus.refund,
  ];

  static const _labels = {
    OrderStatus.all: 'All',
    OrderStatus.pending: 'Pending',
    OrderStatus.processing: 'Processing',
    OrderStatus.fulfilled: 'Fulfilled',
    OrderStatus.refund: 'Refund',
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
                .map((status) => _FilterChip(
                      label: _labels[status]!,
                      count: controller.countFor(status),
                      isActive: controller.selectedFilter.value == status,
                      onTap: () => controller.setFilter(status),
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
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
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
          text: '$label $count',
          fontSize: AppFontSize.verySmall,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive ? AppColors.white : AppColors.black2,
        ),
      ),
    );
  }
}
