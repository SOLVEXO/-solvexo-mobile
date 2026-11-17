import 'package:book_store_app/app/modules/seller/utils/plan_lapse.dart';
import 'package:book_store_app/app/modules/seller_plan_expired/controllers/seller_plan_expired_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Seller panel: English only.
class SellerPlanExpiredView extends GetView<SellerPlanExpiredController> {
  const SellerPlanExpiredView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Plan & listings')),
      body: SafeArea(
        child: Obx(() {
          switch (controller.load.value) {
            case PlanExpiredLoad.loading:
              return const _Skeleton();
            case PlanExpiredLoad.error:
              return _Message(
                icon: Icons.cloud_off_rounded,
                title: 'Could not check your plan',
                body: 'Check your connection and try again.',
                actions: [
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: controller.refreshState,
                    child: const Text('Retry'),
                  ),
                ],
              );
            case PlanExpiredLoad.ready:
              if (!controller.lapsed) {
                // Empty state: nothing has lapsed (e.g. a plan was chosen).
                return _Message(
                  icon: Icons.verified_rounded,
                  title: 'Your plan is active',
                  body: controller.planName.value == null
                      ? 'You can add and publish products.'
                      : '${controller.planName.value}: you can add and publish products.',
                  actions: [
                    FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: controller.continueToDashboard,
                      child: const Text('Go to dashboard'),
                    ),
                  ],
                );
              }
              final status = controller.status.value;
              return _Message(
                icon: Icons.pause_circle_outline_rounded,
                iconColor: theme.colorScheme.error,
                title: PlanLapse.title(status),
                body: '${PlanLapse.message(status)}\n\nYou cannot add or publish products while the plan is not active. You can still see and ship your existing orders.',
                actions: [
                  FilledButton(
                    key: const Key('choosePlan'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: controller.choosePlan,
                    child: const Text('Choose a plan'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('switchBuyer'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: controller.switching.value ? null : controller.switchOrCreateBuyer,
                    child: controller.switching.value
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(controller.hasBuyerAccount.value
                            ? 'Switch to my buyer account'
                            : 'Create a buyer account'),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: controller.continueToDashboard,
                    child: const Text('Continue to dashboard (view only)'),
                  ),
                ],
              );
          }
        }),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.actions,
    this.iconColor,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Icon(icon, size: 64, color: iconColor ?? theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 32),
        ...actions,
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget box(double h, {double w = double.infinity}) => Container(
          height: h,
          width: w,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)),
        );
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(width: 64, height: 64, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(height: 16),
          box(24, w: 220),
          box(16),
          box(16, w: 260),
          const SizedBox(height: 24),
          box(48),
          box(48),
        ],
      ),
    );
  }
}
