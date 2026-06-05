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
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimen.allPadding,
        AppDimen.allPadding,
        AppDimen.allPadding,
        8,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.appbarGradient,
        borderRadius: BorderRadius.circular(
          AppDimen.serviceCountTileRadius + 4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _RevenueSection(controller: controller),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.white.withOpacity(0.18),
          ),
          _StatsRow(controller: controller),
        ],
      ),
    );
  }
}

// ── Revenue hero section ──────────────────────────────────────────────────────

class _RevenueSection extends StatelessWidget {
  final SellerHomeController controller;
  const _RevenueSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Today's Revenue",
                  fontSize: AppFontSize.verySmall,
                  color: AppColors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                const _LiveBadge(),
              ],
            ),
            const SizedBox(height: 8),
            CustomText(
              text: '\$${controller.todayRevenue.value.toStringAsFixed(2)}',
              fontSize: AppFontSize.veryLarge2,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            const SizedBox(height: 10),
            _TrendBadge(change: controller.revenueChange.value),
          ],
        ),
      ),
    );
  }
}

// ── Live indicator badge ──────────────────────────────────────────────────────

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.greenSuccess,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          CustomText(
            text: 'Live',
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}

// ── Trend badge ───────────────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  final double change;
  const _TrendBadge({required this.change});

  @override
  Widget build(BuildContext context) {
    final isUp = change >= 0;
    final color = isUp ? AppColors.greenSuccess : AppColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimen.draggableBorderRadius),
        border: Border.all(color: AppColors.white.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 5),
          CustomText(
            text:
                '${isUp ? '+' : ''}${change.toStringAsFixed(1)}% vs yesterday',
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final SellerHomeController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _StatCell(
                label: 'Orders',
                value: controller.ordersCount.value.toString(),
              ),
              _Divider(),
              _StatCell(label: 'Visitors', value: controller.visitors.value),
              _Divider(),
              _StatCell(
                label: 'Conv. Rate',
                value: '${controller.conversionRate.value}%',
              ),
              _Divider(),
              _StatCell(
                label: 'Avg Order',
                value: '\$${controller.avgOrderValue.value.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;

  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: value,
            fontSize: AppFontSize.extraSmall,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          const SizedBox(height: 3),
          CustomText(
            text: label,
            fontSize: 10,
            color: AppColors.white.withOpacity(0.65),
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: AppColors.white.withOpacity(0.2));
  }
}
