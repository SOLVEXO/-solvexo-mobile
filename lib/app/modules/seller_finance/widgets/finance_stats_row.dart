import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinanceStatsRow extends StatelessWidget {
  final SellerFinanceController controller;
  const FinanceStatsRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final growth = controller.revenueChange;
      final stats = [
        _StatItem(
          icon: Icons.trending_up_rounded,
          iconBg: const Color(0xFFDCFCE7),
          iconColor: AppColors.darkGreen,
          label: 'This Month',
          value: _compact(controller.monthRevenue),
          badge: '${growth >= 0 ? '+' : ''}${growth.toInt()}%',
          badgeColor: AppColors.darkGreen,
          badgeBg: const Color(0xFFDCFCE7),
        ),
        _StatItem(
          icon: Icons.percent_rounded,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          label: 'Platform Fees',
          value: _compact(controller.platformFees),
          badge: 'This month',
          badgeColor: const Color(0xFFD97706),
          badgeBg: const Color(0xFFFEF3C7),
        ),
        _StatItem(
          icon: Icons.account_balance_wallet_rounded,
          iconBg: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          label: 'Total Paid Out',
          value: _compact(controller.totalPaidOut),
          badge: 'All time',
          badgeColor: const Color(0xFF2563EB),
          badgeBg: const Color(0xFFDBEAFE),
        ),
        _StatItem(
          icon: Icons.receipt_long_rounded,
          iconBg: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          label: 'Pending Tax',
          value: _compact(controller.pendingTax),
          badge: 'Est.',
          badgeColor: const Color(0xFFDC2626),
          badgeBg: const Color(0xFFFEE2E2),
        ),
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(item: stats[0])),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(item: stats[1])),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _StatCard(item: stats[2])),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(item: stats[3])),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _compact(double v) {
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}K';
    return '\$${v.toStringAsFixed(0)}';
  }
}

class _StatItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;

  const _StatItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey11),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(item.icon, size: 15, color: item.iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: item.badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(
                  text: item.badge,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: item.badgeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          CustomText(
            text: item.value,
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.w800,
            color: AppColors.black2,
          ),
          const SizedBox(height: 3),
          CustomText(
            text: item.label,
            fontSize: AppFontSize.tiny,
            color: AppColors.lightGrey5,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
