import 'package:book_store_app/app/data/repositories/buyer_extras_repository.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Buy now confirm (B8). Every number comes from GET /api/cart/buy-now.
class BuyNowSheet extends StatelessWidget {
  const BuyNowSheet({super.key, required this.line});
  final BuyNowLine line;

  static Future<bool?> open(BuyNowLine l) =>
      Get.bottomSheet<bool>(BuyNowSheet(line: l), backgroundColor: Get.theme.colorScheme.surface);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Buy now'.tr, style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(line.name, style: t.textTheme.bodyLarge),
          if (line.storeName != null) Text(line.storeName!, style: t.textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('${'Qty'.tr} ${line.quantity}')),
            Text(Money.format(line.total, line.currency), key: const Key('buyNowTotal'), style: t.textTheme.titleMedium),
          ]),
          const SizedBox(height: 4),
          Text('Your cart is not changed.'.tr, style: t.textTheme.bodySmall),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('buyNowContinue'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () => Get.back(result: true),
            child: Text('Continue to checkout'.tr),
          ),
        ]),
      ),
    );
  }
}

/// Delivery info row on the product page (B8): GET /api/checkout/delivery-info.
/// Quietly hides itself on error; shows only what the server knows.
class DeliveryInfoRow extends StatefulWidget {
  const DeliveryInfoRow({super.key, required this.productId, this.variantId, this.currency, this.repo});
  final String productId;
  final String? variantId, currency;
  final BuyerExtrasRepository? repo;

  static List<String> lines(DeliveryInfo d) {
    if (d.isDigital) return ['Instant digital delivery'.tr];
    final out = <String>[];
    if (d.freeShipping) {
      out.add('Free delivery'.tr);
    } else if (d.fee != null) {
      out.add('${'Delivery'.tr}: ${Money.format(d.fee, d.currency)}');
    } else {
      out.add('Delivery fee is shown at checkout'.tr);
    }
    final r = d.routeDays;
    if (r != null && r['min'] != null) {
      out.add('${'Arrives in'.tr} ${r['min']}-${r['max']} ${'days'.tr}');
    } else if (d.dispatchDays != null) {
      out.add('${'Ships in'.tr} ${d.dispatchDays} ${'days'.tr}');
    }
    if (d.cod) out.add('Cash on delivery available'.tr);
    return out;
  }

  @override
  State<DeliveryInfoRow> createState() => _DeliveryInfoRowState();
}

class _DeliveryInfoRowState extends State<DeliveryInfoRow> {
  DeliveryInfo? _info;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(DeliveryInfoRow old) {
    super.didUpdateWidget(old);
    if (old.variantId != widget.variantId || old.productId != widget.productId) _load();
  }

  Future<void> _load() async {
    try {
      final d = await (widget.repo ?? BuyerExtrasRepository())
          .deliveryInfo(productId: widget.productId, variantId: widget.variantId, currency: widget.currency);
      if (mounted) setState(() => _info = d);
    } catch (_) {
      if (mounted) setState(() => _info = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _info;
    if (d == null) return const SizedBox.shrink();
    final t = Theme.of(context);
    return Padding(
      key: const Key('deliveryInfoRow'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(d.isDigital ? Icons.bolt_rounded : Icons.local_shipping_outlined, size: 18, color: t.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(DeliveryInfoRow.lines(d).join(' · '), style: t.textTheme.bodySmall)),
      ]),
    );
  }
}
