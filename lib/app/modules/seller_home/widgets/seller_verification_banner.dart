import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Store-status banner on the dashboard.
///
/// Business verification (KYC) is retired (docs §11): new stores are
/// `active` at once. Only legacy stores can still be `pending` (waiting for
/// an admin in Store approvals) or `rejected`/`suspended`; nothing for the
/// seller to submit, so the banner explains and offers Support.
class SellerVerificationBanner extends StatelessWidget {
  const SellerVerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SellerHomeController>();
    return Obx(() {
      final status = controller.storeStatus.value;
      if (status.isEmpty || status == 'active') return const SizedBox.shrink();
      final scheme = Theme.of(context).colorScheme;
      final reason = controller.storeRejectionReason.value;
      final (String title, String body) = switch (status) {
        'pending' => (
            'Waiting for Edudeen approval',
            'Your store is not visible to buyers yet. No action is needed from you.',
          ),
        'suspended' => (
            'Store suspended',
            'Buyers cannot see your store. Contact Edudeen support to resolve this.',
          ),
        _ => (
            'Store not approved',
            reason.isNotEmpty
                ? reason
                : 'Contact Edudeen support to find out what to change.',
          ),
      };
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            BaseSpacing.md, BaseSpacing.xs, BaseSpacing.md, BaseSpacing.xs),
        child: Card(
          color: status == 'pending'
              ? scheme.tertiaryContainer
              : scheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(BaseSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
                if (status != 'pending')
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Get.toNamed(Routes.supportChat),
                      child: const Text('Contact support'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
