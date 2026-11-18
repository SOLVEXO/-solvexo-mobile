import 'package:book_store_app/app/modules/seller/controllers/seller_bottom_nav_controller.dart';
import 'package:book_store_app/app/modules/seller/utils/seller_store_gate.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Dashboard summary cards (docs Part B 6.2; checklist #10). English only.

void _goTab(int i) {
  if (Get.isRegistered<SellerBottomNavController>()) {
    Get.find<SellerBottomNavController>().changeTab(i);
  }
}

/// "Needs your attention": counts from actionItems. Hidden when all zero.
class DashboardActionsCard extends StatelessWidget {
  const DashboardActionsCard({super.key, required this.controller});
  final SellerHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.summary.value;
      if (s == null) return const SizedBox.shrink();
      final a = s.actions;
      final rows = <(IconData, String, int, VoidCallback)>[
        (Icons.local_shipping_outlined, 'Orders to ship', a.ordersToShip, () => _goTab(1)),
        (Icons.timer_off_outlined, 'Orders overdue (48 h)', a.ordersOverdue, () => _goTab(1)),
        (Icons.assignment_return_outlined, 'Returns to answer', a.returnsPending, () => Get.toNamed(Routes.sellerReturns)),
        (Icons.mark_chat_unread_outlined, 'Unread messages', a.unreadMessages, () => Get.toNamed(Routes.sellerMessages)),
        (Icons.hourglass_top_rounded, 'Products in review', a.pendingReview, () => _goTab(2)),
        (Icons.report_gmailerrorred_rounded, 'Products need changes', a.rejected, () => _goTab(2)),
        (Icons.account_balance_outlined, 'Add a payout method', a.payoutMissing, () => Get.toNamed(Routes.sellerFinance)),
      ].where((r) => r.$3 > 0).toList();
      if (rows.isEmpty) return const SizedBox.shrink();
      final theme = Theme.of(context);
      return Card(
        key: const Key('dashboardActions'),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text('Needs your attention', style: theme.textTheme.titleSmall),
            ),
            for (final r in rows)
              ListTile(
                minTileHeight: 48,
                leading: Icon(r.$1),
                title: Text(r.$2),
                trailing: r.$2 == 'Add a payout method'
                    ? const Icon(Icons.chevron_right_rounded)
                    : Badge(label: Text('${r.$3}'), backgroundColor: theme.colorScheme.primary),
                onTap: r.$4,
              ),
          ]),
        ),
      );
    });
  }
}

/// 30-day KPIs in Pakistan time (server period + timezone). Free claims are
/// counted separately from revenue.
class DashboardKpisCard extends StatelessWidget {
  const DashboardKpisCard({super.key, required this.controller});
  final SellerHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = Theme.of(context);
      if (controller.summaryFailed.value && controller.summary.value == null) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
            child: Row(children: [
              Expanded(
                child: Text('Could not load your store summary.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
              ),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: controller.loadSummary,
                child: const Text('Retry'),
              ),
            ]),
          ),
        );
      }
      final s = controller.summary.value;
      if (s == null) return const SizedBox.shrink();
      final o = s.overview;
      String m(num v) => Money.format(v, o.currency);
      final fmt = DateFormat('d MMM');
      final range = o.from != null && o.to != null
          ? '${fmt.format(o.from!.toLocal())} – ${fmt.format(o.to!.toLocal())}'
          : 'Last 30 days';
      final cells = [
        ('Booked', m(o.bookedValue)),
        ('Collected', m(o.collected)),
        ('Orders', '${o.totalOrders}'),
        ('Avg order', m(o.avgOrderValue)),
        ('Free claims', '${o.freeClaims}'),
        ('Products live', '${s.activeProducts}/${s.totalProducts}'),
      ];
      return Card(
        key: const Key('dashboardKpis'),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Last 30 days', style: theme.textTheme.titleSmall),
            Text('$range · ${o.timezone == 'Asia/Karachi' ? 'Pakistan time' : o.timezone}',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                for (final c in cells)
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    FittedBox(child: Text(c.$2, style: theme.textTheme.titleMedium)),
                    Text(c.$1, style: theme.textTheme.labelSmall),
                  ]),
              ],
            ),
          ]),
        ),
      );
    });
  }
}

/// Setup checklist (SetupChecklistCard on the web). Hidden when all done.
class DashboardChecklistCard extends StatelessWidget {
  const DashboardChecklistCard({super.key, required this.controller});
  final SellerHomeController controller;

  /// Web path -> app screen; null = no app screen yet (shown, not tappable).
  static VoidCallback? actionFor(String path) => switch (path) {
        'settings' => () => Get.toNamed(Routes.sellerStoreProfile),
        'store-builder' => () => Get.toNamed(Routes.sellerStoreBanners),
        'finance' => () => Get.toNamed(Routes.sellerFinance),
        'products/add' => openAddProductOrRequireVerification,
        'products' => () => _goTab(2),
        // Delivery settings live in Store settings (#15).
        'shipping' => () => Get.toNamed(Routes.sellerStoreSettings),
        'inventory' => () => Get.toNamed(Routes.sellerInventory),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.summary.value;
      if (s == null || s.checklistDone || s.steps.isEmpty) return const SizedBox.shrink();
      final theme = Theme.of(context);
      return Card(
        key: const Key('dashboardChecklist'),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(children: [
                Expanded(child: Text('Set up your store', style: theme.textTheme.titleSmall)),
                Text('${s.checklistPercent}%', style: theme.textTheme.labelLarge),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(value: s.checklistPercent / 100),
            ),
            for (final step in s.steps)
              ListTile(
                minTileHeight: 48,
                leading: Icon(
                  step.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: step.done ? theme.colorScheme.primary : theme.colorScheme.outline,
                ),
                title: Text(step.label,
                    style: step.done
                        ? theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                        : null),
                subtitle: step.notNeeded ? const Text('Not needed for your store') : null,
                trailing: step.done || actionFor(step.path) == null
                    ? null
                    : const Icon(Icons.chevron_right_rounded),
                onTap: step.done ? null : actionFor(step.path),
              ),
          ]),
        ),
      );
    });
  }
}
