import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/data/models/subscriptions/subscriber_model.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/controllers/seller_subscriptions_controller.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/widgets/subscriptions_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SubscribersTab extends StatelessWidget {
  final SellerSubscriptionsController controller;
  const SubscribersTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSubscribers.value) return const SubscriptionsShimmer();

      if (controller.subscribers.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(BaseSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline_rounded, size: 48, color: AppColors.lightGrey),
                SizedBox(height: BaseSpacing.sm),
                Text('No subscribers yet', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: BaseSpacing.xxs),
                Text('Buyers who subscribe to your plans will show up here.', style: BaseTypography.labelSmall(color: AppColors.gray600), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }

      return CustomRefreshWrapper(
        onRefresh: controller.loadSubscribers,
        child: ListView.separated(
          padding: EdgeInsets.all(BaseSpacing.md),
          itemCount: controller.subscribers.length,
          separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
          itemBuilder: (_, i) => _SubscriberCard(subscriber: controller.subscribers[i], controller: controller),
        ),
      );
    });
  }
}

class _SubscriberCard extends StatelessWidget {
  final SubscriberModel subscriber;
  final SellerSubscriptionsController controller;
  const _SubscriberCard({required this.subscriber, required this.controller});

  Color get _statusColor => switch (subscriber.status) {
        'active' => AppColors.greenSuccess,
        'paused' => AppColors.orange,
        'past_due' => AppColors.red,
        _ => AppColors.gray600,
      };

  @override
  Widget build(BuildContext context) {
    final initials = subscriber.customerName.trim().isNotEmpty ? subscriber.customerName.trim()[0].toUpperCase() : '?';
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg), boxShadow: BaseShadows.forLevel(BaseElevation.level1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(initials, style: BaseTypography.bodySmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subscriber.customerName, style: BaseTypography.bodySmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
                    Text(subscriber.planName, style: BaseTypography.labelSmall(color: AppColors.gray600)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
                child: Text(subscriber.status, style: BaseTypography.labelSmall(color: _statusColor).copyWith(fontWeight: FontWeight.w700, fontSize: 10.5)),
              ),
            ],
          ),
          SizedBox(height: BaseSpacing.sm),
          Row(
            children: [
              Text('\$${subscriber.amountUSD.toStringAsFixed(2)}/${subscriber.billingInterval == 'monthly' ? 'mo' : 'yr'}',
                  style: BaseTypography.bodySmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w700)),
              if (subscriber.nextBillingDate != null) ...[
                SizedBox(width: BaseSpacing.sm),
                Text('Next bill: ${DateFormat('MMM d, yyyy').format(subscriber.nextBillingDate!.toLocal())}', style: BaseTypography.labelSmall(color: AppColors.gray600)),
              ],
            ],
          ),
          if (subscriber.status != 'canceled') ...[
            SizedBox(height: BaseSpacing.sm),
            Row(
              children: [
                if (subscriber.status == 'active') ...[
                  Expanded(child: _ActionButton(label: 'Pause', onTap: () => controller.pauseSubscriber(subscriber))),
                  SizedBox(width: BaseSpacing.xs),
                ],
                if (subscriber.status == 'paused') ...[
                  Expanded(child: _ActionButton(label: 'Resume', onTap: () => controller.resumeSubscriber(subscriber))),
                  SizedBox(width: BaseSpacing.xs),
                ],
                Expanded(child: _ActionButton(label: 'Cancel', danger: true, onTap: () => _confirmCancel(context))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    CustomConfirmDialog.show(
      context,
      title: 'Cancel this subscription?',
      message: '${subscriber.customerName} will lose access to "${subscriber.planName}" benefits immediately.',
      confirmLabel: 'Cancel Subscription',
      confirmColor: AppColors.red,
      onConfirm: () => controller.cancelSubscriber(subscriber),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _ActionButton({required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.red : AppColors.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 38),
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: color), borderRadius: BorderRadius.circular(BaseRadius.md)),
        child: Text(label, style: BaseTypography.labelSmall(color: color).copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
