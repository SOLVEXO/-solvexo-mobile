import 'package:book_store_app/app/data/models/marketing/campaign_model.dart';
import 'package:book_store_app/app/modules/seller/widgets/screen_states.dart';
import 'package:book_store_app/app/modules/seller_platform_sales/controllers/seller_platform_sales_controller.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_list_actions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Platform Sales (English, seller panel). Opened from Settings and from
/// the `platform_campaign_live` notification.
class SellerPlatformSalesView extends GetView<SellerPlatformSalesController> {
  const SellerPlatformSalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform sales')),
      body: Obx(() {
        if (controller.isLoading.value) return const ListSkeleton(rows: 3, rowHeight: 120);
        if (controller.failed.value) {
          return ErrorRetry(message: 'Could not load the platform sales.', onRetry: controller.load);
        }
        if (controller.campaigns.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(children: const [
              SizedBox(height: 120),
              EmptyMessage(
                icon: Icons.local_offer_outlined,
                title: 'No platform sales right now',
                body: 'When Edudeen runs a sale you can choose which products take part. '
                    'We will send you a notification when one starts.',
              ),
            ]),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.campaigns.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => i == 0
                ? const _Intro()
                : _CampaignCard(campaign: controller.campaigns[i - 1], controller: controller),
          ),
        );
      }),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Each product can be in a platform sale or in Premium, not both. '
      'Sale prices are set by Edudeen.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.controller});
  final CampaignModel campaign;
  final SellerPlatformSalesController controller;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final upcoming = campaign.startDate != null && campaign.startDate!.isAfter(DateTime.now());
    final df = DateFormat('d MMM y');
    final dates = [
      if (campaign.startDate != null) df.format(campaign.startDate!.toLocal()),
      if (campaign.endDate != null) df.format(campaign.endDate!.toLocal()),
    ].join(' – ');
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(campaign.name, style: t.textTheme.titleMedium)),
            Chip(
              label: Text(upcoming ? 'Coming soon' : 'Live'),
              visualDensity: VisualDensity.compact,
              backgroundColor: upcoming ? t.colorScheme.surfaceContainerHighest : t.colorScheme.primaryContainer,
            ),
          ]),
          if (campaign.hasDiscount) Text(campaign.discountLabel, style: t.textTheme.titleSmall?.copyWith(color: t.colorScheme.primary)),
          if (dates.isNotEmpty) Text(dates, style: t.textTheme.bodySmall),
          if ((campaign.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(campaign.description!),
          ],
          if (campaign.isPlatformSponsored) ...[
            const SizedBox(height: 6),
            Text('Funded by Edudeen', style: t.textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          FilledButton.tonal(
            key: Key('chooseProducts_${campaign.id}'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () => _openPicker(context),
            child: const Text('Choose products'),
          ),
        ]),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    controller.loadProducts();
    await Get.bottomSheet(
      _ProductPicker(campaign: campaign, controller: controller),
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}

class _ProductPicker extends StatefulWidget {
  const _ProductPicker({required this.campaign, required this.controller});
  final CampaignModel campaign;
  final SellerPlatformSalesController controller;

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  Set<String>? _chosen;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Obx(() {
          if (c.productsLoading.value) return const ListSkeleton(rows: 6, rowHeight: 48);
          if (c.productsFailed.value) return ErrorRetry(message: 'Could not load your products.', onRetry: c.loadProducts);
          if (c.products.isEmpty) {
            return const EmptyMessage(
              icon: Icons.inventory_2_outlined,
              title: 'No live products',
              body: 'Only live products can join a sale.',
            );
          }
          final chosen = _chosen ??= c.productIdsIn(widget.campaign);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Products in "${widget.campaign.name}"', style: Theme.of(context).textTheme.titleMedium),
            ),
            if (c.moreProducts.value)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Showing your first 100 live products.'),
              ),
            Expanded(
              child: ListView(children: [
                for (final p in c.products)
                  CheckboxListTile(
                    key: Key('pick_${p.id}'),
                    value: chosen.contains(p.id),
                    title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: p.inPremium ? Text('In Premium (${p.premiumPercent}% off for members)') : null,
                    onChanged: (v) => setState(() => v == true ? chosen.add(p.id) : chosen.remove(p.id)),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                key: const Key('saveSaleProducts'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: c.saving.value
                    ? null
                    : () async {
                        final skipped = await c.save(widget.campaign, chosen);
                        if (!mounted) return;
                        _chosen = null;
                        Get.back();
                        if (skipped.isNotEmpty) await showSkipped(skipped);
                      },
                child: c.saving.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ),
          ]);
        }),
      ),
    );
  }
}
