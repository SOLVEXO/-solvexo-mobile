import 'package:book_store_app/config/app_config.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shown instead of an error when the API answers 403 because the plan does
/// not include a feature (#16). [message] is the server's text.
class PlanLockedCard extends StatelessWidget {
  const PlanLockedCard({super.key, required this.title, required this.message, this.compact = false});
  final String title;
  final String message;
  final bool compact;

  static void openPlans() => Get.toNamed(Routes.sellerPlatformPlan);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final card = Card(
      key: Key('locked_$title'),
      margin: EdgeInsets.zero,
      color: t.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.lock_outline_rounded, color: t.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: t.textTheme.titleSmall)),
          ]),
          const SizedBox(height: 6),
          Text(message, style: t.textTheme.bodySmall),
          if (AppFeatures.digitalPurchases) ...[
            const SizedBox(height: 10),
            FilledButton.tonal(
              style: FilledButton.styleFrom(minimumSize: const Size(140, 44)),
              onPressed: openPlans,
              child: const Text('Upgrade plan'),
            ),
          ],
        ]),
      ),
    );
    if (compact) return card;
    return ListView(padding: const EdgeInsets.all(16), children: [card]);
  }
}

/// Dialog version for actions (e.g. export).
Future<void> showPlanLocked(String message) => Get.dialog(AlertDialog(
      icon: const Icon(Icons.lock_outline_rounded),
      title: const Text('Not on your plan'),
      content: Text(message),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () => Get.back(),
          child: Text(AppFeatures.digitalPurchases ? 'Not now' : 'OK'),
        ),
        if (AppFeatures.digitalPurchases)
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () {
              Get.back();
              PlanLockedCard.openPlans();
            },
            child: const Text('Upgrade plan'),
          ),
      ],
    ));
