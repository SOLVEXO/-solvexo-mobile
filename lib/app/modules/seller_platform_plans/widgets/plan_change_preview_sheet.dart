import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/repositories/platform_plans_repository.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dry-run pricing summary shown before a seller commits to switching their
/// platform plan/billing interval — the seller only actually triggers
/// `changePlan` (via [onConfirm]) after reviewing the real amount-due/credit
/// math computed by `POST .../preview-change-plan`. Does not itself know
/// about [SellerPlatformPlansController] — the caller supplies [onConfirm].
class PlanChangePreviewSheet extends StatelessWidget {
  final PlatformPlanPreviewResult preview;
  final VoidCallback onConfirm;

  const PlanChangePreviewSheet({super.key, required this.preview, required this.onConfirm});

  static void show({required PlatformPlanPreviewResult preview, required VoidCallback onConfirm}) {
    Get.bottomSheet(
      PlanChangePreviewSheet(preview: preview, onConfirm: onConfirm),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Color get _directionColor => switch (preview.direction) {
        'upgrade' => AppColors.greenSuccess,
        'downgrade' => AppColors.amberDark,
        _ => AppColors.gray600,
      };

  String get _directionLabel => switch (preview.direction) {
        'upgrade' => 'Upgrade',
        'downgrade' => 'Downgrade',
        _ => 'Billing Change',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: 'Confirm Plan Change',
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black2,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                    decoration: BoxDecoration(
                      color: _directionColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(BaseRadius.pill),
                    ),
                    child: CustomText(
                      text: _directionLabel,
                      color: _directionColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.lightGrey2),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Current Plan', preview.currentPlanName),
                  _row('New Plan', preview.newPlanName),
                  _row(
                    'Billing Interval',
                    preview.newBillingInterval == 'yearly' ? 'Yearly' : 'Monthly',
                  ),
                  SizedBox(height: BaseSpacing.xs),
                  const Divider(height: 1, color: AppColors.lightGrey2),
                  SizedBox(height: BaseSpacing.xs),
                  _row(
                    'Remaining Days (current period)',
                    '${preview.remainingDaysInCurrentPeriod}',
                  ),
                  _row(
                    'Unused Credit (current plan)',
                    '\$${preview.unusedCreditFromCurrentPlanUSD.toStringAsFixed(2)}',
                  ),
                  _row(
                    'Existing Credit Balance',
                    '\$${preview.existingCreditBalanceUSD.toStringAsFixed(2)}',
                  ),
                  _row(
                    'Total Credit Applied',
                    '\$${preview.totalCreditAppliedUSD.toStringAsFixed(2)}',
                  ),
                  if (preview.creditAppliedToBalanceUSD > 0)
                    _row(
                      'Credit Added to Balance',
                      '\$${preview.creditAppliedToBalanceUSD.toStringAsFixed(2)}',
                    ),
                  SizedBox(height: BaseSpacing.xs),
                  const Divider(height: 1, color: AppColors.lightGrey2),
                  SizedBox(height: BaseSpacing.xs),
                  _row(
                    'Amount Due Today',
                    '\$${preview.amountDueTodayUSD.toStringAsFixed(2)}',
                    emphasize: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                BaseSpacing.sm,
                20,
                MediaQuery.of(context).padding.bottom + BaseSpacing.md,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Confirm Change',
                    onPressed: () {
                      Get.back();
                      onConfirm();
                    },
                  ),
                  SizedBox(height: BaseSpacing.xxs),
                  Center(child: GhostButton(label: 'Cancel', onPressed: () => Get.back())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomText(
              text: label,
              fontSize: AppFontSize.tiny,
              color: AppColors.gray600,
            ),
          ),
          CustomText(
            text: value,
            fontSize: emphasize ? AppFontSize.small2 : AppFontSize.verySmall,
            fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
            color: emphasize ? AppColors.primaryColor : AppColors.black2,
          ),
        ],
      ),
    );
  }
}
