import 'package:book_store_app/app/data/repositories/seller_inventory_repository.dart';
import 'package:book_store_app/app/modules/seller/widgets/screen_states.dart';
import 'package:book_store_app/app/modules/seller_inventory/controllers/seller_inventory_controller.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_list_actions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Inventory (physical products). English, seller panel.
class SellerInventoryView extends GetView<SellerInventoryController> {
  const SellerInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
          canPop: !controller.dirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await _confirm('Discard changes?', 'Your stock changes are not saved.', 'Discard');
            if (leave) {
              controller.discard();
              Get.back();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Inventory')),
            body: _body(context),
            bottomNavigationBar: _bottomBar(context),
          ),
        ));
  }

  Widget _body(BuildContext context) {
    if (controller.isLoading.value) return const ListSkeleton();
    if (controller.failed.value) return ErrorRetry(message: 'Could not load your inventory.', onRetry: controller.load);
    final s = controller.stats.value;
    return RefreshIndicator(
      onRefresh: controller.load,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 300) controller.loadMore();
          return false;
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                _Stat('In stock', s.inStock),
                _Stat('Low', s.lowStock, warn: s.lowStock > 0),
                _Stat('Out', s.outOfStock, warn: s.outOfStock > 0),
                _Stat('Unlimited', s.unlimited),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                key: const Key('inventorySearch'),
                onChanged: controller.onSearch,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search products',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            if (controller.products.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: EmptyMessage(
                  icon: Icons.inventory_2_outlined,
                  title: 'No physical products',
                  body: 'Stock is tracked for physical products. Digital products have no stock.',
                ),
              )
            else
              for (final p in controller.products) _Row(product: p, controller: controller),
            if (controller.isLoadingMore.value)
              const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  Widget? _bottomBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (controller.selectedIds.isNotEmpty) {
      return Material(
        color: scheme.secondaryContainer,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(children: [
              IconButton(
                tooltip: 'Clear selection',
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: controller.selectedIds.clear,
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(child: Text('${controller.selectedIds.length} selected')),
              for (final m in BulkStockMode.values)
                TextButton(
                  key: Key('bulk_${m.name}'),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: controller.saving.value ? null : () => _bulk(m),
                  child: Text(switch (m) { BulkStockMode.set => 'Set', BulkStockMode.add => 'Add', BulkStockMode.subtract => 'Subtract' }),
                ),
            ]),
          ),
        ),
      );
    }
    if (!controller.dirty) return null;
    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(child: Text('${controller.pending.length} unsaved change${controller.pending.length == 1 ? '' : 's'}')),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
              onPressed: controller.saving.value ? null : controller.discard,
              child: const Text('Discard'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const Key('saveStock'),
              style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
              onPressed: controller.saving.value ? null : _save,
              child: controller.saving.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final zero = controller.pendingZero;
    if (zero.isNotEmpty) {
      final ok = await _confirm('Set stock to 0?',
          '${zero.map((p) => p.name).join(', ')} will show as out of stock.', 'Set to 0');
      if (!ok) return;
    }
    final skipped = await controller.save();
    if (skipped.isNotEmpty) await showSkipped(skipped);
  }

  Future<void> _bulk(BulkStockMode m) async {
    final value = await Get.bottomSheet<int>(
      _NumberSheet(
        title: switch (m) {
          BulkStockMode.set => 'Set stock to',
          BulkStockMode.add => 'Add to stock',
          BulkStockMode.subtract => 'Subtract from stock',
        },
        label: 'Quantity',
        helper: '0 to 100,000',
        validate: SellerInventoryController.validateBulkValue,
      ),
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
    );
    if (value == null) return;
    if (m == BulkStockMode.set && value == 0) {
      final ok = await _confirm('Set stock to 0?', 'The selected products will show as out of stock.', 'Set to 0');
      if (!ok) return;
    }
    final skipped = await controller.bulk(m, value);
    if (skipped.isNotEmpty) await showSkipped(skipped);
  }
}

Future<bool> _confirm(String title, String body, String action) async =>
    await Get.dialog<bool>(AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () => Get.back(result: true),
          child: Text(action),
        ),
      ],
    )) ??
    false;

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.warn = false});
  final String label;
  final int value;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: warn ? scheme.errorContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label  $value',
          style: TextStyle(fontWeight: FontWeight.w600, color: warn ? scheme.onErrorContainer : scheme.onSurface)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.product, required this.controller});
  final SellerProduct product;
  final SellerInventoryController controller;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final t = Theme.of(context);
    final editable = SellerInventoryController.editable(p);
    return Obx(() {
      final selected = controller.selectedIds.contains(p.id);
      final changed = controller.pending.containsKey(p.id);
      final stock = controller.shownStock(p);
      final low = p.stock != null && stock <= p.lowStockThreshold;
      return ListTile(
        key: Key('inv_${p.id}'),
        minVerticalPadding: 10,
        selected: selected,
        onLongPress: () => controller.toggleSelect(p.id),
        onTap: controller.selectedIds.isNotEmpty ? () => controller.toggleSelect(p.id) : null,
        leading: selected ? Icon(Icons.check_circle_rounded, color: t.colorScheme.primary) : null,
        title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            if (p.stock == null) 'Unlimited' else if (stock == 0) 'Out of stock' else if (low) 'Low stock',
            'Low-stock limit ${p.lowStockThreshold}${p.hasCustomThreshold ? '' : ' (default)'}',
            if (!editable && p.variantCount > 1) '${p.variantCount} variants – edit in the product',
          ].join(' · '),
          style: TextStyle(color: stock == 0 || low ? t.colorScheme.error : null),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (editable) ...[
            IconButton(
              key: Key('minus_${p.id}'),
              tooltip: 'Less',
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
              onPressed: stock > 0 ? () => controller.bump(p, -1) : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            InkWell(
              onTap: () => _typeStock(p),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Center(
                  child: Text('$stock',
                      key: Key('stock_${p.id}'),
                      style: TextStyle(fontWeight: FontWeight.w700, color: changed ? t.colorScheme.primary : null)),
                ),
              ),
            ),
            IconButton(
              key: Key('plus_${p.id}'),
              tooltip: 'More',
              style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
              onPressed: () => controller.bump(p, 1),
              icon: const Icon(Icons.add_rounded),
            ),
          ] else
            Text(p.stockLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
          PopupMenuButton<String>(
            key: Key('invMenu_${p.id}'),
            tooltip: 'More',
            style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
            onSelected: (v) => v == 'limit' ? _limit(p) : _history(p),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'limit', child: Text('Low-stock limit')),
              PopupMenuItem(value: 'history', child: Text('Stock history')),
            ],
          ),
        ]),
      );
    });
  }

  Future<void> _typeStock(SellerProduct p) async {
    final v = await Get.bottomSheet<int>(
      _NumberSheet(
        title: 'Stock',
        label: 'Stock',
        initial: '${controller.shownStock(p)}',
        validate: SellerProductsController.validateStock,
      ),
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
    );
    if (v != null) controller.setPending(p, v);
  }

  Future<void> _limit(SellerProduct p) async {
    final v = await Get.bottomSheet<int>(
      _NumberSheet(
        title: 'Low-stock limit',
        label: 'Warn me at',
        helper: '0 to 1000. Default is 10.',
        initial: '${p.lowStockThreshold}',
        validate: SellerInventoryController.validateThreshold,
        resetLabel: p.hasCustomThreshold ? 'Use default' : null,
      ),
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
    );
    if (v == null) return;
    await controller.setThreshold(p, v < 0 ? null : v);
  }

  Future<void> _history(SellerProduct p) => Get.bottomSheet(
        _HistorySheet(product: p, load: () => controller.history(p)),
        isScrollControlled: true,
        backgroundColor: Get.theme.colorScheme.surface,
      );
}

/// Validated whole-number entry. Returns the number, or -1 for [resetLabel].
class _NumberSheet extends StatefulWidget {
  const _NumberSheet({required this.title, required this.label, required this.validate, this.helper, this.initial = '', this.resetLabel});
  final String title, label, initial;
  final String? helper, resetLabel;
  final String? Function(String) validate;

  @override
  State<_NumberSheet> createState() => _NumberSheetState();
}

class _NumberSheetState extends State<_NumberSheet> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final err = widget.validate(_c.text);
    setState(() => _error = err);
    if (err == null) Get.back(result: int.parse(_c.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          key: const Key('numberField'),
          controller: _c,
          autofocus: true,
          keyboardType: TextInputType.number,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: widget.helper,
            errorText: _error,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          if (widget.resetLabel != null)
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
              onPressed: () => Get.back(result: -1),
              child: Text(widget.resetLabel!),
            ),
          const Spacer(),
          FilledButton(
            key: const Key('numberOk'),
            style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: _submit,
            child: const Text('OK'),
          ),
        ]),
      ]),
    );
  }
}

class _HistorySheet extends StatefulWidget {
  const _HistorySheet({required this.product, required this.load});
  final SellerProduct product;
  final Future<List<StockHistoryEntry>> Function() load;

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  late Future<List<StockHistoryEntry>> _f = widget.load();

  static String sourceLabel(String s) => switch (s) {
        'manual' => 'Edited',
        'bulk' => 'Bulk change',
        'order' => 'Order',
        'return' => 'Return',
        'cancel' || 'cancellation' => 'Cancelled order',
        '' => 'Change',
        _ => s[0].toUpperCase() + s.substring(1).replaceAll('_', ' '),
      };

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('d MMM y, h:mm a');
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Stock history', style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('${widget.product.name} · last 20 changes', maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: FutureBuilder<List<StockHistoryEntry>>(
              future: _f,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) return const ListSkeleton(rows: 4, rowHeight: 44);
                if (snap.hasError) {
                  return ErrorRetry(message: 'Could not load the history.', onRetry: () => setState(() => _f = widget.load()));
                }
                final items = snap.data ?? const [];
                if (items.isEmpty) return const EmptyMessage(icon: Icons.history_rounded, title: 'No stock changes yet');
                return ListView(children: [
                  for (final e in items)
                    ListTile(
                      title: Text('${e.from ?? '–'} → ${e.to ?? '–'}'),
                      subtitle: Text([sourceLabel(e.source), if (e.at != null) df.format(e.at!.toLocal())].join(' · ')),
                    ),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
