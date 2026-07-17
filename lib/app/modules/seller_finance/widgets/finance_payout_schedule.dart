import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_payout_methods_sheet.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_schedule_sheet.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_tax_report_sheet.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinancePayoutSchedule extends StatelessWidget {
  final SellerFinanceController controller;
  const FinancePayoutSchedule({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.schedule_rounded,
      iconBg: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF2563EB),
      title: 'Payout Schedule',
      trailing: GestureDetector(
        onTap: () => FinanceScheduleSheet.show(context, controller),
        child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.lightGrey5),
      ),
      child: Obx(() => Column(
            children: [
              _InfoRow(label: 'Frequency', value: controller.payoutFrequency),
              _InfoRow(label: 'Method', value: controller.paymentMethod),
              _InfoRow(label: 'Currency', value: controller.payoutCurrency),
              _InfoRow(label: 'Minimum', value: controller.payoutMinimum, isLast: true),
              const SizedBox(height: 14),
              _OutlineActionButton(
                label: 'Manage Payout Methods',
                icon: Icons.account_balance_rounded,
                onTap: () => FinancePayoutMethodsSheet.show(context, controller),
              ),
            ],
          )),
    );
  }
}

class FinanceFeeBreakdown extends StatelessWidget {
  final SellerFinanceController controller;
  const FinanceFeeBreakdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.feeItems;
      return _SectionCard(
        icon: Icons.receipt_outlined,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        title: 'Fee Breakdown',
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final bool isFreeOrIncluded = item.value.toLowerCase() == 'free' ||
                item.value.toLowerCase() == 'included';
            return _InfoRow(
              label: item.key,
              value: item.value,
              valueColor: isFreeOrIncluded ? AppColors.darkGreen : null,
              valueBg: isFreeOrIncluded
                  ? const Color(0xFFDCFCE7)
                  : null,
              isLast: i == items.length - 1,
            );
          }),
        ),
      );
    });
  }
}

class FinanceTaxReports extends StatelessWidget {
  final SellerFinanceController controller;
  const FinanceTaxReports({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.description_outlined,
      iconBg: const Color(0xFFF3E8FF),
      iconColor: const Color(0xFF7C3AED),
      title: 'Tax Reports',
      trailing: GestureDetector(
        onTap: () => FinanceGenerateTaxReportSheet.show(context, controller),
        child: const Icon(Icons.add_rounded, size: 18, color: AppColors.lightGrey5),
      ),
      child: Obx(() {
        if (controller.isLoadingTaxReports.value && controller.taxReports.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)),
          );
        }
        final reports = controller.taxReports;
        if (reports.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CustomText(
              text: 'No tax reports yet — tap + to generate one for a quarter or year.',
              fontSize: AppFontSize.verySmall,
              color: AppColors.lightGrey5,
            ),
          );
        }
        return Column(
          children: List.generate(reports.length, (i) {
            final report = reports[i];
            return Column(
              children: [
                GestureDetector(
                  onTap: () => showTaxReportDetailDialog(context, report),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.description_outlined,
                              size: 15, color: Color(0xFF7C3AED)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: report.periodLabel,
                                fontSize: AppFontSize.verySmall,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black2,
                              ),
                              const SizedBox(height: 2),
                              CustomText(
                                text: report.rangeLabel,
                                fontSize: AppFontSize.tiny,
                                color: AppColors.lightGrey5,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                          ),
                          child: const CustomText(
                            text: 'View',
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < reports.length - 1)
                  const Divider(height: 1, color: AppColors.lightGrey11),
              ],
            );
          }),
        );
      }),
    );
  }
}

// ── Shared section card shell ────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomText(
                  text: title,
                  fontSize: AppFontSize.small,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black2,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.lightGrey11),
          child,
        ],
      ),
    );
  }
}

// ── Shared info row ──────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final Color? valueColor;
  final Color? valueBg;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.valueColor,
    this.valueBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: label,
                fontSize: AppFontSize.verySmall,
                color: AppColors.lightGrey5,
              ),
              valueBg != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: valueBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomText(
                        text: value,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? AppColors.black2,
                      ),
                    )
                  : CustomText(
                      text: value,
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? AppColors.black2,
                    ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.lightGrey11),
      ],
    );
  }
}

// ── Outline action button ────────────────────────────────────────────────────

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryColor),
            const SizedBox(width: 7),
            CustomText(
              text: label,
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
