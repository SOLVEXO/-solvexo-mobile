import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_addon_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_entitlements_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_invoice_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_plan_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/modules/seller_platform_plans/controllers/seller_platform_plans_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

String _fmtDate(DateTime? d) => d == null ? '—' : DateFormat('MMM d, yyyy').format(d);

// ── Current plan card ────────────────────────────────────────────────────────

class MyPlanCard extends StatelessWidget {
  final PlatformSubscriptionModel sub;
  final SellerPlatformPlansController controller;
  const MyPlanCard({super.key, required this.sub, required this.controller});

  Color get _statusColor => switch (sub.status) {
        'active' => AppColors.greenSuccess,
        'trialing' => AppColors.amberDark,
        'past_due' => AppColors.red,
        _ => AppColors.gray600,
      };

  String get _statusLabel => switch (sub.status) {
        'active' => 'Active',
        'trialing' => 'Trial',
        'past_due' => 'Payment past due',
        _ => 'Canceled',
      };

  @override
  Widget build(BuildContext context) {
    final plan = sub.plan;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: 'Your Plan',
                  color: AppColors.white.withOpacity(0.85),
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(BaseRadius.pill)),
                child: CustomText(
                  text: _statusLabel,
                  color: AppColors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTextStyles.monoFontFamily,
                ),
              ),
            ],
          ),
          SizedBox(height: BaseSpacing.xxs),
          CustomText(
            text: plan?.name ?? 'Free',
            color: AppColors.white,
            fontSize: AppFontSize.large,
            fontWeight: FontWeight.bold,
          ),
          if (sub.amountUSD > 0)
            CustomText(
              text:
                  '\$${sub.amountUSD.toStringAsFixed(0)}/${sub.billingInterval == 'yearly' ? 'yr' : 'mo'}${sub.nextBillingDate != null ? ' · renews ${_fmtDate(sub.nextBillingDate)}' : ''}',
              color: AppColors.white.withOpacity(0.9),
              fontSize: AppFontSize.verySmall,
              fontFamily: AppTextStyles.monoFontFamily,
            ),
          if (sub.isTrialing && sub.trialEndsAt != null)
            CustomText(
              text: 'Trial ends ${_fmtDate(sub.trialEndsAt)}',
              color: AppColors.white.withOpacity(0.9),
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
            ),
          if (sub.creditBalanceUSD > 0)
            CustomText(
              text: 'Credit balance: \$${sub.creditBalanceUSD.toStringAsFixed(2)}',
              color: AppColors.white.withOpacity(0.85),
              fontSize: AppFontSize.tiny,
              fontFamily: AppTextStyles.monoFontFamily,
            ),
          if (!sub.isFreePlan) ...[
            SizedBox(height: BaseSpacing.sm + 2),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(BaseSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(BaseRadius.md),
              ),
              child: Obx(() {
                final busy = controller.isUpdating.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlineButton(
                      label: 'Manage Billing',
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      compact: true,
                      onPressed: busy ? null : controller.openBillingPortal,
                    ),
                    SizedBox(height: BaseSpacing.xs),
                    if (sub.cancelAtPeriodEnd) ...[
                      CustomText(
                        text:
                            'Your plan moves to the free tier on ${_fmtDate(sub.currentPeriodEnd)} — you keep full access until then.',
                        color: AppColors.gray600,
                        fontSize: AppFontSize.tiny,
                      ),
                      SizedBox(height: BaseSpacing.xs),
                      PrimaryButton(
                        label: 'Reactivate Plan',
                        compact: true,
                        isLoading: busy,
                        onPressed: busy ? null : controller.reactivatePlan,
                      ),
                    ] else
                      Align(
                        alignment: Alignment.centerRight,
                        child: DangerButton(
                          label: 'Cancel Plan',
                          expand: false,
                          compact: true,
                          onPressed: busy ? null : () => _showCancelDialog(context),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    CustomConfirmDialog.show(
      context,
      title: 'Cancel Plan?',
      confirmLabel: 'Cancel Plan',
      confirmColor: AppColors.red,
      contentBuilder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text:
                'Your store moves to the free plan at the end of the current billing period — you keep full access until then.',
            fontSize: AppFontSize.tiny,
            color: AppColors.grey,
          ),
          SizedBox(height: BaseSpacing.xs),
          CustomTextField(
            controller: reasonCtrl,
            hintText: 'Reason (optional)',
            isborder: true,
            maxLength: 500,
          ),
        ],
      ),
      onConfirm: () {
        final reason = reasonCtrl.text.trim();
        controller.cancelPlan(reason.isEmpty ? null : reason);
      },
    );
  }
}

// ── Usage / entitlements card ────────────────────────────────────────────────

class UsageCard extends StatelessWidget {
  final PlatformEntitlementsModel data;
  const UsageCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Usage',
            color: AppColors.black2,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: BaseSpacing.sm),
          _UsageBar(label: 'Products', usage: data.products),
          SizedBox(height: BaseSpacing.sm),
          _UsageBar(label: 'Staff accounts', usage: data.staffAccounts),
          SizedBox(height: BaseSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'POS locations',
                  value: data.maxPosLocations == -1 ? 'Unlimited' : 'Up to ${data.maxPosLocations}',
                ),
              ),
              SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: _MiniStat(
                  label: 'AI credits',
                  value: '${data.aiCreditsBalance} left',
                ),
              ),
              SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: _MiniStat(
                  label: 'Transaction fee',
                  value: '${(data.transactionFeeRate * 100).toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final String label;
  final EntitlementUsage usage;
  const _UsageBar({required this.label, required this.usage});

  @override
  Widget build(BuildContext context) {
    final nearLimit = !usage.isUnlimited && usage.ratio >= 0.8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomText(
                text: label,
                color: AppColors.gray600,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
              ),
            ),
            CustomText(
              text: usage.label,
              color: nearLimit ? AppColors.amberDark : AppColors.black2,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        SizedBox(height: BaseSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(BaseRadius.pill),
          child: Container(
            height: 6,
            width: double.infinity,
            color: AppColors.lightGrey10,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: usage.isUnlimited ? 0.06 : usage.ratio,
              child: Container(color: nearLimit ? AppColors.amberDark : AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: BaseSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.lightGrey10,
        borderRadius: BorderRadius.circular(BaseRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            color: AppColors.gray600,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          CustomText(
            text: value,
            color: AppColors.black2,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w700,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Billing interval toggle ──────────────────────────────────────────────────

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
            _segment('Monthly', !isYearly, () {
              if (isYearly) controller.toggleBillingInterval();
            }),
            _segment('Yearly', isYearly, () {
              if (!isYearly) controller.toggleBillingInterval();
            }),
          ],
        ),
      );
    });
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BaseMotion.normal,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.transparent,
          borderRadius: BorderRadius.circular(BaseRadius.pill),
        ),
        child: CustomText(
          text: label,
          color: selected ? AppColors.white : AppColors.gray600,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Plan card ────────────────────────────────────────────────────────────────

class PlanCard extends StatelessWidget {
  final PlatformPlanModel plan;
  final bool isCurrent;
  final bool isYearly;
  final SellerPlatformPlansController controller;
  const PlanCard({
    super.key,
    required this.plan,
    required this.isCurrent,
    required this.isYearly,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final price = plan.priceFor(isYearly ? 'yearly' : 'monthly');
    return Container(
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
              Expanded(
                child: CustomText(
                  text: plan.name,
                  color: AppColors.black2,
                  fontSize: AppFontSize.extraSmall,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (plan.badge != null && plan.badge!.isNotEmpty && !isCurrent)
                _Chip(text: plan.badge!, color: AppColors.amberDark),
              if (isCurrent) _Chip(text: 'Current Plan', color: AppColors.primaryColor),
            ],
          ),
          CustomText(
            text: plan.isCustomPricing
                ? 'Custom pricing'
                : plan.isFree
                    ? 'Free'
                    : '\$${price.toStringAsFixed(0)}/${isYearly ? 'yr' : 'mo'}',
            color: AppColors.primaryColor,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
            fontFamily: AppTextStyles.monoFontFamily,
          ),
          if (plan.trialDays > 0 && !isCurrent)
            CustomText(
              text: '${plan.trialDays}-day free trial',
              color: AppColors.greenSuccess,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
            ),
          if (plan.description != null && plan.description!.isNotEmpty) ...[
            SizedBox(height: BaseSpacing.xxs),
            CustomText(
              text: plan.description!,
              color: AppColors.gray600,
              fontSize: AppFontSize.tiny,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: BaseSpacing.xs),
          ...plan.featureBullets.map(
            (f) => Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 13, color: AppColors.greenSuccess),
                  SizedBox(width: BaseSpacing.xxs),
                  Expanded(
                    child: CustomText(text: f, color: AppColors.gray600, fontSize: AppFontSize.tiny),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: BaseSpacing.xs),
          if (!isCurrent && !plan.isCustomPricing)
            Obx(() {
              // Tapping goes straight to `selectPlan`, which dry-runs
              // `preview-change-plan` and opens `PlanChangePreviewSheet` with
              // the real amount-due/credit math — no need for a separate
              // estimate dialog here first.
              final busy = controller.isUpdating.value || controller.isPreviewing.value;
              return GestureDetector(
                onTap: busy ? null : () => controller.selectPlan(plan),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs + 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: busy ? AppColors.lightGrey10 : AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(BaseRadius.md),
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                        )
                      : CustomText(
                          text: 'Switch to ${plan.name}',
                          color: AppColors.white,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
      child: CustomText(
        text: text,
        color: color,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        fontFamily: AppTextStyles.monoFontFamily,
      ),
    );
  }
}

// ── Add-ons card ─────────────────────────────────────────────────────────────

class AddonsCard extends StatelessWidget {
  final SellerPlatformPlansController controller;
  const AddonsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Obx(() {
        final active = controller.activeAddons;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: 'Add-ons',
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showCatalogSheet(context),
                  child: CustomText(
                    text: '+ Add',
                    color: AppColors.primaryColor,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (active.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
                child: CustomText(
                  text: 'No active add-ons — boost your plan with extras.',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                ),
              )
            else
              ...active.map((a) => _AddonRow(addon: a, controller: controller)),
          ],
        );
      }),
    );
  }

  void _showCatalogSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg,
          MediaQuery.of(context).padding.bottom + BaseSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: EdgeInsets.only(bottom: BaseSpacing.md),
                decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            CustomText(
              text: 'Add-ons',
              color: AppColors.black2,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: BaseSpacing.sm),
            ...kAddonCatalog.map(
              (entry) => InkWell(
                onTap: () {
                  Get.back();
                  CustomConfirmDialog.show(
                    context,
                    title: 'Buy ${entry.name}?',
                    message:
                        '\$${entry.unitPriceUSD.toStringAsFixed(0)}${entry.recurring ? '/month, cancel anytime' : ' one-time'}.',
                    confirmLabel: 'Buy',
                    onConfirm: () => controller.purchaseAddon(entry.type),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs + 1),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: entry.name,
                              color: AppColors.black2,
                              fontSize: AppFontSize.verySmall,
                              fontWeight: FontWeight.w700,
                            ),
                            CustomText(
                              text: entry.description,
                              color: AppColors.gray600,
                              fontSize: AppFontSize.tiny,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: BaseSpacing.xs),
                      CustomText(
                        text: '\$${entry.unitPriceUSD.toStringAsFixed(0)}${entry.recurring ? '/mo' : ''}',
                        color: AppColors.primaryColor,
                        fontSize: AppFontSize.verySmall,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTextStyles.monoFontFamily,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class _AddonRow extends StatelessWidget {
  final PlatformAddonModel addon;
  final SellerPlatformPlansController controller;
  const _AddonRow({required this.addon, required this.controller});

  @override
  Widget build(BuildContext context) {
    final entry = addonCatalogEntry(addon.addonType);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: entry?.name ?? addon.addonType,
                  color: AppColors.black2,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text:
                      '\$${addon.priceUSD.toStringAsFixed(0)}${addon.recurring ? '/mo' : ' one-time'}${addon.quantity > 1 ? ' · ×${addon.quantity}' : ''}${addon.nextBillingDate != null ? ' · renews ${_fmtDate(addon.nextBillingDate)}' : ''}',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontFamily: AppTextStyles.monoFontFamily,
                ),
              ],
            ),
          ),
          if (addon.recurring)
            GestureDetector(
              onTap: () => CustomConfirmDialog.show(
                context,
                title: 'Cancel ${entry?.name ?? 'add-on'}?',
                message: 'It stays active until the end of the current billing period.',
                confirmLabel: 'Cancel Add-on',
                confirmColor: AppColors.red,
                onConfirm: () => controller.cancelAddon(addon),
              ),
              child: CustomText(
                text: 'Cancel',
                color: AppColors.red,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Billing history card ─────────────────────────────────────────────────────

/// The store's recent platform-plan invoices
/// (`GET /api/platform-plans/:storeId/invoices`).
class BillingHistoryCard extends StatelessWidget {
  final SellerPlatformPlansController controller;
  const BillingHistoryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.invoices.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: 'Billing History',
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (controller.invoicesTotal.value > controller.invoices.length)
                  CustomText(
                    text: 'Last ${controller.invoices.length} of ${controller.invoicesTotal.value}',
                    color: AppColors.gray600,
                    fontSize: AppFontSize.tiny,
                  ),
              ],
            ),
            SizedBox(height: BaseSpacing.xs),
            ...controller.invoices.map((invoice) => _InvoiceRow(invoice: invoice)),
          ],
        ),
      );
    });
  }
}

class _InvoiceRow extends StatelessWidget {
  final PlatformInvoiceModel invoice;
  const _InvoiceRow({required this.invoice});

  Color get _statusColor => switch (invoice.status) {
        'paid' => AppColors.greenSuccess,
        'pending' => AppColors.amberDark,
        'failed' => AppColors.red,
        _ => AppColors.gray600, // refunded / partially_refunded
      };

  String get _statusLabel => switch (invoice.status) {
        'paid' => 'Paid',
        'pending' => 'Pending',
        'failed' => 'Failed',
        'refunded' => 'Refunded',
        'partially_refunded' => 'Partial refund',
        _ => invoice.status,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: invoice.invoiceNumber,
                  color: AppColors.black2,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  text: _fmtDate(invoice.paidAt ?? invoice.createdAt),
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: '\$${invoice.amountUSD.toStringAsFixed(2)}',
                color: AppColors.black2,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w700,
                fontFamily: AppTextStyles.monoFontFamily,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                ),
                child: CustomText(
                  text: _statusLabel,
                  color: _statusColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTextStyles.monoFontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
