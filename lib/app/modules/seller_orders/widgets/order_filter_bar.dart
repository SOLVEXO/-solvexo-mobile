import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Orders tabs with the server's counts (docs Part B 6.5).
class OrdersTabsBar extends StatelessWidget {
  const OrdersTabsBar({super.key, required this.controller});
  final SellerOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            for (final t in OrdersTab.values)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  key: Key('tab_${t.api}'),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  label: Text('${t.label} (${controller.countForTab(t)})'),
                  selected: controller.selectedTab.value == t,
                  onSelected: (_) => controller.setTab(t),
                ),
              ),
          ]),
        ));
  }
}

/// Ship-by badge: grey, amber under 12 h, red when overdue.
class ShipByBadge extends StatelessWidget {
  const ShipByBadge({super.key, required this.due});
  final DateTime due;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (shipByLevel(due, now)) {
      ShipByLevel.overdue => (scheme.errorContainer, scheme.onErrorContainer),
      ShipByLevel.soon => (const Color(0xFFFFE8B3), const Color(0xFF7A4B00)),
      ShipByLevel.normal => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(shipByLabel(due, now),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
    );
  }
}

/// Free claims card: free digital items buyers availed (not revenue).
class FreeClaimsCard extends StatelessWidget {
  const FreeClaimsCard({super.key, required this.controller});
  final SellerOrdersController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      Widget body;
      if (controller.freeClaimsLoading.value && controller.freeClaims.isEmpty) {
        body = const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator());
      } else if (controller.freeClaimsFailed.value) {
        body = Row(children: [
          Expanded(
            child: Text('Could not load free claims.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: controller.loadFreeClaims,
            child: const Text('Retry'),
          ),
        ]);
      } else if (controller.freeClaims.isEmpty) {
        body = Text('No free items claimed yet.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant));
      } else {
        body = Column(children: [
          for (final c in controller.freeClaims.take(5))
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: 48,
              title: Text(c.productName.isEmpty ? 'Free item' : c.productName),
              subtitle: Text([
                if (c.buyerName.isNotEmpty) c.buyerName,
                if (c.orderNumber.isNotEmpty) '#${c.orderNumber}',
                if (c.date != null) DateFormat('d MMM').format(c.date!),
              ].join(' · ')),
              trailing: const Chip(label: Text('Availed')),
            ),
        ]);
      }
      return Card(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: const Key('freeClaims'),
            minTileHeight: 48,
            title: Text('Free claims (${controller.freeClaimsTotal.value})',
                style: theme.textTheme.titleSmall),
            subtitle: const Text('Free items buyers availed. Not counted as revenue.'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [body],
          ),
        ),
      );
    });
  }
}
