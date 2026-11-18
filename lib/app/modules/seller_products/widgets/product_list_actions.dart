import 'package:book_store_app/app/modules/seller/utils/store_currency.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Products list (docs Part B 6.3; checklist #11). English only.

/// Status tabs with the server's counts.
class ProductsTabsBar extends StatelessWidget {
  const ProductsTabsBar({super.key, required this.controller});
  final SellerProductsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [
            for (final t in ProductsTab.values)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  key: Key('ptab_${t.name}'),
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

/// Bulk bar while products are selected (long-press a card).
class ProductsSelectionBar extends StatelessWidget {
  const ProductsSelectionBar({super.key, required this.controller});
  final SellerProductsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.selecting) return const SizedBox.shrink();
      final ids = controller.selectedIds.toList();
      final busy = ids.any(controller.busyIds.contains);
      return Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(children: [
              IconButton(
                tooltip: 'Clear selection',
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: controller.clearSelection,
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(child: Text('${ids.length} selected')),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: busy ? null : () => _run(context, ids, true),
                child: const Text('Activate'),
              ),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: busy ? null : () => _run(context, ids, false),
                child: const Text('Deactivate'),
              ),
            ]),
          ),
        ),
      );
    });
  }

  Future<void> _run(BuildContext context, List<String> ids, bool active) async {
    final skipped = await controller.setActive(ids, active: active);
    if (skipped.isNotEmpty) await showSkipped(skipped);
  }
}

/// The server's per-product reasons for anything it did not change.
Future<void> showSkipped(List<String> skipped) => Get.dialog(AlertDialog(
      title: Text('${skipped.length} not changed'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [for (final s in skipped) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(s))],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      ],
    ));

/// Inline price / stock edit (validated before the call).
class InlineEditSheet extends StatefulWidget {
  const InlineEditSheet({
    super.key,
    required this.title,
    required this.initial,
    required this.isPrice,
    required this.validate,
    required this.save,
  });

  final String title;
  final String initial;
  final bool isPrice;
  final String? Function(String) validate;
  final Future<bool> Function(String) save;

  static Future<void> price(SellerProductsController c, SellerProduct p) => Get.bottomSheet(
        InlineEditSheet(
          title: 'Price',
          initial: p.price % 1 == 0 ? p.price.toInt().toString() : p.price.toString(),
          isPrice: true,
          validate: SellerProductsController.validatePrice,
          save: (v) => c.setPrice(p, v),
        ),
        isScrollControlled: true,
        backgroundColor: Get.theme.colorScheme.surface,
      );

  static Future<void> stock(SellerProductsController c, SellerProduct p) => Get.bottomSheet(
        InlineEditSheet(
          title: 'Stock',
          initial: p.stock?.toString() ?? '',
          isPrice: false,
          validate: SellerProductsController.validateStock,
          save: (v) => c.setStock(p, v),
        ),
        isScrollControlled: true,
        backgroundColor: Get.theme.colorScheme.surface,
      );

  @override
  State<InlineEditSheet> createState() => _InlineEditSheetState();
}

class _InlineEditSheetState extends State<InlineEditSheet> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final err = widget.validate(_c.text);
    setState(() => _error = err);
    if (err != null) return;
    setState(() => _busy = true);
    final ok = await widget.save(_c.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = StoreCurrency.symbol;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Edit ${widget.title.toLowerCase()}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          key: const Key('inlineEditField'),
          controller: _c,
          autofocus: true,
          keyboardType: TextInputType.numberWithOptions(decimal: widget.isPrice),
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: widget.title,
            prefixText: widget.isPrice && symbol.isNotEmpty ? '$symbol ' : null,
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ]),
    );
  }
}

/// Raw-status label for the card (null = use the stock-based badge).
(String, Color)? rawStatusLabel(SellerProduct p, ColorScheme c) {
  if (p.pausedByPlan) return ('Paused – plan ended', c.error);
  return switch (p.rawStatus) {
    'pending_review' => ('In review', const Color(0xFF7A4B00)),
    'rejected' => ('Needs changes', c.error),
    'inactive' => ('Inactive', c.outline),
    _ => null,
  };
}
