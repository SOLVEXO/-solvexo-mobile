import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_tier_model.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_platform_plans/controllers/seller_platform_plans_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Current tier, renewal date, credit balance, and the cancel action —
/// mirrors the seller's OWN plan status, distinct from `SubscribersTab`
/// (which lists the seller's buyers).
class MyPlanCard extends StatelessWidget {
  final PlatformSubscriptionModel plan;
  final SellerPlatformPlansController controller;
  const MyPlanCard({super.key, required this.plan, required this.controller});

  Color get _statusColor => switch (plan.status) {
        'active' => AppColors.greenSuccess,
        'past_due' => AppColors.amberDark,
        _ => AppColors.gray600,
      };

  String get _statusLabel {
    if (plan.hasPendingDowngrade) return 'Cancels on ${_fmt(plan.canceledAt)}';
    return switch (plan.status) {
      'active' => 'Active',
      'past_due' => 'Payment past due',
      _ => 'Canceled',
    };
  }

  String _fmt(DateTime? d) => d == null ? '—' : DateFormat('MMM d, yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    final tierName = plan.tierConfig?.name ?? plan.tier;
    return Container(
      padding: EdgeInsets.all(BaseSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryColor, AppColors.primaryColorLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(text: 'Your Plan', color: AppColors.white.withOpacity(0.85), fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(BaseRadius.pill)),
                child: CustomText(text: _statusLabel, color: AppColors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: BaseSpacing.xs),
          CustomText(text: tierName, color: AppColors.white, fontSize: AppFontSize.regular, fontWeight: FontWeight.bold),
          if (plan.amountUSD > 0) ...[
            SizedBox(height: 2),
            CustomText(
              text: '\$${plan.amountUSD.toStringAsFixed(0)}/${plan.billingInterval == 'yearly' ? 'yr' : 'mo'}${plan.nextBillingDate != null ? ' · renews ${_fmt(plan.nextBillingDate)}' : ''}',
              color: AppColors.white.withOpacity(0.9),
              fontSize: AppFontSize.tiny,
            ),
          ],
          if (plan.creditBalanceUSD > 0) ...[
            SizedBox(height: 2),
            CustomText(text: 'Credit balance: \$${plan.creditBalanceUSD.toStringAsFixed(2)}', color: AppColors.white.withOpacity(0.85), fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
          ],
          if (!plan.isStarter && !plan.hasPendingDowngrade) ...[
            SizedBox(height: BaseSpacing.sm),
            GestureDetector(
              onTap: () => _confirmCancel(context),
              child: CustomText(text: 'Cancel plan', color: AppColors.white, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700, textDecoration: TextDecoration.underline),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    CustomConfirmDialog.show(
      context,
      title: 'Cancel your plan?',
      message: 'You\'ll keep ${plan.tierConfig?.name ?? plan.tier} access until ${_fmt(plan.currentPeriodEnd)}, then move to Starter (free).',
      confirmLabel: 'Cancel Plan',
      confirmColor: AppColors.red,
      onConfirm: () => controller.cancelToStarter(atPeriodEnd: true),
    );
  }
}

/// The $29/mo POS add-on row — eligibility-gated on Basic+ tier, separate
/// purchase from the platform tier itself.
class PosAddonCard extends StatelessWidget {
  final PlatformSubscriptionModel plan;
  final SellerPlatformPlansController controller;
  const PosAddonCard({super.key, required this.plan, required this.controller});

  @override
  Widget build(BuildContext context) {
    final active = plan.posAddon.active;
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.md)),
            child: Icon(Icons.point_of_sale_rounded, color: AppColors.primaryColor, size: 20),
          ),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'POS Add-on', color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w700),
                CustomText(
                  text: active ? 'Active · \$${plan.posAddonMonthlyPriceUSD.toStringAsFixed(0)}/mo' : (plan.posAddonEligible ? '\$${plan.posAddonMonthlyPriceUSD.toStringAsFixed(0)}/mo · run in-store checkout' : 'Requires Basic tier or above'),
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          _actionButton(active),
        ],
      ),
    );
  }

  Widget _actionButton(bool active) {
    return Obx(() {
      if (controller.isUpdating.value) {
        return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor));
      }
      if (active) {
        return TextButton(
          onPressed: controller.cancelPosAddon,
          child: CustomText(text: 'Cancel', color: AppColors.red, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
        );
      }
      return TextButton(
        onPressed: plan.posAddonEligible ? controller.subscribeToPosAddon : null,
        child: CustomText(
          text: plan.posAddonEligible ? 'Activate' : 'Locked',
          color: plan.posAddonEligible ? AppColors.primaryColor : AppColors.lightGrey,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w700,
        ),
      );
    });
  }
}

class BillingIntervalToggle extends StatelessWidget {
  final SellerPlatformPlansController controller;
  const BillingIntervalToggle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isYearly = controller.billingInterval.value == 'yearly';
      return Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.lightGrey10, borderRadius: BorderRadius.circular(BaseRadius.pill)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment('Monthly', !isYearly, () => controller.billingInterval.value == 'monthly' ? null : controller.toggleBillingInterval()),
            _segment('Yearly · save 2mo', isYearly, () => controller.billingInterval.value == 'yearly' ? null : controller.toggleBillingInterval()),
          ],
        ),
      );
    });
  }

  Widget _segment(String label, bool selected, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BaseMotion.normal,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
        decoration: BoxDecoration(color: selected ? AppColors.primaryColor : AppColors.transparent, borderRadius: BorderRadius.circular(BaseRadius.pill)),
        child: CustomText(text: label, color: selected ? AppColors.white : AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class TierCard extends StatelessWidget {
  final PlatformTierModel tier;
  final bool isCurrent;
  final bool isYearly;
  final SellerPlatformPlansController controller;
  const TierCard({super.key, required this.tier, required this.isCurrent, required this.isYearly, required this.controller});

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? (tier.yearlyPriceUSD ?? tier.monthlyPriceUSD * 12) : tier.monthlyPriceUSD;
    final myPlan = controller.myPlan.value;
    final isDowngrade = myPlan != null && myPlan.tierConfig != null && tier.monthlyPriceUSD < myPlan.tierConfig!.monthlyPriceUSD;

    return PressableScale(
      onTap: isCurrent ? null : () => controller.selectTier(tier),
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
          border: Border.all(color: isCurrent ? AppColors.primaryColor : AppColors.transparent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: CustomText(text: tier.name, color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w700)),
                if (isCurrent)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
                    child: CustomText(text: 'Current Plan', color: AppColors.primaryColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
            CustomText(
              text: tier.isFree ? 'Free' : '\$${price.toStringAsFixed(0)}/${isYearly ? 'yr' : 'mo'}',
              color: AppColors.primaryColor,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: BaseSpacing.xs),
            ...tier.features.map((f) => Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 13, color: AppColors.greenSuccess),
                      SizedBox(width: BaseSpacing.xxs),
                      Expanded(child: CustomText(text: f, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            SizedBox(height: BaseSpacing.xs),
            if (!isCurrent)
              Obx(() => Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs + 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: controller.isUpdating.value ? AppColors.lightGrey10 : (isDowngrade ? AppColors.lightGrey10 : AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(BaseRadius.md),
                    ),
                    child: controller.isUpdating.value
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor))
                        : CustomText(
                            text: isDowngrade ? 'Downgrade' : 'Upgrade',
                            color: isDowngrade ? AppColors.gray600 : AppColors.white,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w700,
                          ),
                  )),
          ],
        ),
      ),
    );
  }
}
