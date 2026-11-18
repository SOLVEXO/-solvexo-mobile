import 'package:book_store_app/app/modules/seller/widgets/screen_states.dart';
import 'package:book_store_app/app/modules/seller_store_settings/controllers/seller_shipping_controller.dart';
import 'package:book_store_app/app/modules/seller_store_settings/controllers/seller_store_settings_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shipping: Edudeen's zones (read-only) and the store's delivery days.
class SellerShippingView extends GetView<SellerShippingController> {
  const SellerShippingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping')),
      body: Obx(() {
        if (controller.isLoading.value) return const ListSkeleton(rows: 4);
        if (controller.failed.value) return ErrorRetry(message: 'Could not load shipping.', onRetry: controller.load);
        final s = controller.settings.value;
        final t = Theme.of(context);
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Your delivery times', style: t.textTheme.titleMedium),
            const SizedBox(height: 4),
            if (s == null || (s.deliveryDays.isEmpty && s.dispatchDays == null))
              const Text('Not set yet.')
            else ...[
              if (s.dispatchDays != null) Text('Dispatch within ${s.dispatchDays} day${s.dispatchDays == 1 ? '' : 's'}'),
              for (final r in SellerStoreSettingsController.routeLabels.entries)
                if (s.deliveryDays[r.key] != null)
                  Text('${r.value}: ${s.deliveryDays[r.key]!.min}–${s.deliveryDays[r.key]!.max} days'),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () => Get.toNamed(Routes.sellerStoreSettings),
                child: const Text('Edit in Store settings'),
              ),
            ),
            const Divider(height: 32),
            Text('Shipping zones', style: t.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Set by Edudeen. Physical orders can be delivered to these areas.', style: t.textTheme.bodySmall),
            const SizedBox(height: 8),
            if (controller.zones.isEmpty)
              const EmptyMessage(
                icon: Icons.local_shipping_outlined,
                title: 'No shipping zones yet',
                body: 'Edudeen has not set delivery zones. Your own delivery settings apply.',
              )
            else
              for (final z in controller.zones)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(z.place.isEmpty ? '—' : z.place),
                  subtitle: Text([
                    if (z.price != null) Money.format(z.price, s?.currency),
                    if ((z.estimate ?? '').isNotEmpty) z.estimate!,
                    if (z.status.isNotEmpty && z.status != 'active') z.status,
                  ].join(' · ')),
                ),
          ]),
        );
      }),
    );
  }
}
