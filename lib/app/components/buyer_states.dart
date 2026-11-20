import 'package:book_store_app/app/components/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Loading / error / empty states for buyer screens (.tr, RTL-safe).

class BuyerSkeleton extends StatelessWidget {
  const BuyerSkeleton({super.key, this.rows = 5, this.rowHeight = 72});
  final int rows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) => ListView.separated(
        key: const Key('buyerSkeleton'),
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Skeleton(height: rowHeight, width: double.infinity, cornerRadius: 12),
      );
}

class BuyerError extends StatelessWidget {
  const BuyerError({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              key: const Key('buyerRetry'),
              style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
              onPressed: onRetry,
              child: Text('Retry'.tr),
            ),
          ]),
        ),
      );
}

class BuyerEmpty extends StatelessWidget {
  const BuyerEmpty({super.key, required this.icon, required this.title, this.body, this.action});
  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 44, color: t.colorScheme.outline),
          const SizedBox(height: 12),
          Text(title, style: t.textTheme.titleMedium, textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!, textAlign: TextAlign.center, style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ]),
      ),
    );
  }
}
