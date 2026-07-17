import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/subscriptions/buyer_subscription_model.dart';
import 'package:book_store_app/app/modules/my_memberships/controllers/my_memberships_controller.dart';
import 'package:book_store_app/app/modules/my_memberships/widgets/membership_status_chip.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Bottom sheet with a membership's full detail (billing dates, totals,
/// invoice history) and self-service actions (Pause / Resume / Cancel).
/// Reads `controller.selected` so it live-updates after the detail fetch
/// and after each action.
class MembershipDetailsSheet extends StatelessWidget {
  final MyMembershipsController controller;

  const MembershipDetailsSheet({super.key, required this.controller});

  static void show(BuildContext context, MyMembershipsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => MembershipDetailsSheet(controller: controller),
    );
  }

  String _fmtDate(DateTime? d) => d == null ? '—' : DateFormat('MMM d, yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final m = controller.selected.value;
      if (m == null) return const SizedBox.shrink();
      // Read inside the Obx builder so action-in-flight changes rebuild the
      // sheet (descendant builds are outside Obx's tracking scope).
      final isBusy = controller.actioningId.value == m.id;

      // CustomBottomSheet already wraps `widget` in a scrollable Flexible.
      return CustomBottomSheet(
        title: m.store?.name ?? 'Membership',
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: m.plan?.name ?? 'Membership plan',
                        color: AppColors.black2,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    MembershipStatusChip(status: m.status, pendingCancellation: m.pendingCancellation),
                  ],
                ),
                SizedBox(height: BaseSpacing.md),
                _DetailRow(
                  label: 'Price',
                  value: '\$${m.amountUSD.toStringAsFixed(2)} / ${m.billingInterval == 'yearly' ? 'year' : 'month'}',
                ),
                _DetailRow(label: 'Member since', value: _fmtDate(m.startedAt)),
                _DetailRow(label: 'Current period ends', value: _fmtDate(m.currentPeriodEnd)),
                if (!m.isCanceled && !m.pendingCancellation)
                  _DetailRow(label: 'Next billing date', value: _fmtDate(m.nextBillingDate)),
                _DetailRow(label: 'Total paid', value: '\$${m.totalPaidUSD.toStringAsFixed(2)}'),
                if (m.creditBalanceUSD > 0)
                  _DetailRow(label: 'Account credit', value: '\$${m.creditBalanceUSD.toStringAsFixed(2)}'),
                if (m.pendingCancellation)
                  Padding(
                    padding: EdgeInsets.only(top: BaseSpacing.xs),
                    child: CustomText(
                      text: 'This membership is canceled and will end on ${_fmtDate(m.currentPeriodEnd)}.',
                      color: AppColors.amberDark,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (m.plan != null && m.plan!.features.isNotEmpty) ...[
                  SizedBox(height: BaseSpacing.md),
                  CustomText(
                    text: 'Includes',
                    color: AppColors.black2,
                    fontSize: AppFontSize.extraSmall,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: BaseSpacing.xs),
                  ...m.plan!.features.map(
                    (f) => Padding(
                      padding: EdgeInsets.only(bottom: BaseSpacing.xxs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 15, color: AppColors.greenSuccess),
                          SizedBox(width: BaseSpacing.xs),
                          Expanded(
                            child: CustomText(text: f, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (m.invoices.isNotEmpty) ...[
                  SizedBox(height: BaseSpacing.md),
                  CustomText(
                    text: 'Billing history',
                    color: AppColors.black2,
                    fontSize: AppFontSize.extraSmall,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: BaseSpacing.xs),
                  ...m.invoices.map(
                    (invoice) => Padding(
                      padding: EdgeInsets.only(bottom: BaseSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomText(
                              text: '${invoice.invoiceNumber} · ${_fmtDate(invoice.paidAt ?? invoice.createdAt)}',
                              color: AppColors.gray600,
                              fontSize: AppFontSize.tiny,
                              fontWeight: FontWeight.w500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: BaseSpacing.xs),
                          CustomText(
                            text: '\$${invoice.amountUSD.toStringAsFixed(2)}',
                            color: AppColors.black2,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w700,
                          ),
                          SizedBox(width: BaseSpacing.xs),
                          CustomText(
                            text: invoice.status,
                            color: invoice.status == 'paid' ? AppColors.greenSuccess : (invoice.status == 'failed' ? AppColors.red : AppColors.gray600),
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
            SizedBox(height: BaseSpacing.lg),
            _Actions(controller: controller, membership: m, isBusy: isBusy),
          ],
        ),
      );
    });
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w500),
          CustomText(text: value, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final MyMembershipsController controller;
  final BuyerSubscriptionModel membership;
  final bool isBusy;

  const _Actions({required this.controller, required this.membership, required this.isBusy});

  bool get _canPause => membership.isActive && !membership.pendingCancellation;
  bool get _canResume => membership.isPaused;
  bool get _canCancel => !membership.isCanceled && !membership.pendingCancellation;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (_canPause)
        _ActionButton(
          label: 'Pause Membership',
          color: AppColors.primaryColor,
          isBusy: isBusy,
          onTap: () => CustomConfirmDialog.show(
            context,
            title: 'Pause this membership?',
            message: 'Billing stops while paused and your benefits are put on hold. You can resume anytime.',
            confirmLabel: 'Pause',
            onConfirm: () => controller.pause(membership),
          ),
        ),
      if (_canResume)
        _ActionButton(
          label: 'Resume Membership',
          color: AppColors.greenSuccess,
          isBusy: isBusy,
          onTap: () => CustomConfirmDialog.show(
            context,
            title: 'Resume this membership?',
            message: 'Billing restarts and your benefits become available again.',
            confirmLabel: 'Resume',
            onConfirm: () => controller.resume(membership),
          ),
        ),
      if (_canCancel)
        _ActionButton(
          label: 'Cancel Membership',
          color: AppColors.red,
          outlined: true,
          isBusy: isBusy,
          onTap: () => CustomConfirmDialog.show(
            context,
            title: 'Cancel this membership?',
            message: 'You will keep your benefits until the end of the current billing period, then the membership ends. This cannot be undone.',
            confirmLabel: 'Cancel Membership',
            confirmColor: AppColors.red,
            onConfirm: () => controller.cancel(membership),
          ),
        ),
    ];

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) SizedBox(height: BaseSpacing.xs),
          buttons[i],
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final bool isBusy;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isBusy,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? AppColors.white : color,
          border: outlined ? Border.all(color: color) : null,
          borderRadius: BorderRadius.circular(BaseRadius.md),
        ),
        child: isBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: outlined ? color : AppColors.white),
              )
            : CustomText(
                text: label,
                color: outlined ? color : AppColors.white,
                fontSize: AppFontSize.extraSmall,
                fontWeight: FontWeight.w700,
              ),
      ),
    );
  }
}
