import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const _tap = Size(48, 48);

class ReturnsSkeleton extends StatelessWidget {
  const ReturnsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.surfaceContainerHighest;
    Widget box(double h) => Container(
          height: h,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)),
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [box(72), box(48), box(140), box(140), box(140)],
    );
  }
}

class ReturnsMessage extends StatelessWidget {
  const ReturnsMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 56, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ]),
    );
  }
}

/// Server stats: open, overdue, 30-day return rate, refunded (30 days).
class ReturnsStats extends StatelessWidget {
  const ReturnsStats({super.key, required this.stats});
  final SellerReturnStats stats;

  @override
  Widget build(BuildContext context) {
    final rate = stats.returnRatePct;
    final cells = [
      ('Open', '${stats.open}'),
      ('Overdue', '${stats.overdue}'),
      ('Return rate (30d)', rate == null ? 'Not enough data' : '$rate%'),
      ('Refunded (30d)', '${stats.refunded30d}'),
    ];
    final theme = Theme.of(context);
    return Row(children: [
      for (final c in cells)
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Column(children: [
                FittedBox(child: Text(c.$2, style: theme.textTheme.titleMedium)),
                const SizedBox(height: 2),
                Text(c.$1,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: theme.textTheme.labelSmall),
              ]),
            ),
          ),
        ),
    ]);
  }
}

class ReturnsFilters extends StatelessWidget {
  const ReturnsFilters({super.key, required this.controller});
  final SellerReturnsController controller;

  static const _labels = {
    ReturnFilter.open: 'Open',
    ReturnFilter.approved: 'Approved',
    ReturnFilter.rejected: 'Rejected',
    ReturnFilter.all: 'All',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final f in ReturnFilter.values)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  label: Text('${_labels[f]} (${controller.countFor(f)})'),
                  selected: controller.selectedFilter.value == f,
                  onSelected: (_) => controller.setFilter(f),
                ),
              ),
          ]),
        ));
  }
}

class RespondByPill extends StatelessWidget {
  const RespondByPill({super.key, required this.respondBy});
  final DateTime respondBy;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final level = respondByLevel(respondBy, now);
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (level) {
      RespondByLevel.overdue => (scheme.errorContainer, scheme.onErrorContainer),
      RespondByLevel.soon => (const Color(0xFFFFE8B3), const Color(0xFF7A4B00)),
      RespondByLevel.normal => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(respondByLabel(respondBy, now),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
    );
  }
}

class ReturnCard extends StatelessWidget {
  const ReturnCard({super.key, required this.item, required this.controller});
  final SellerReturnItem item;
  final SellerReturnsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Chip(
                label: Text(item.kind == ReturnKind.refundRequest ? 'Refund request' : 'Return'),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.orderNumber.isEmpty ? '' : '#${item.orderNumber}',
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.isOpen && item.respondBy != null) RespondByPill(respondBy: item.respondBy!),
              if (!item.isOpen) Text(_statusLabel(item.status), style: theme.textTheme.labelLarge),
            ]),
            if (item.productName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(item.productName, style: theme.textTheme.titleSmall),
            ],
            if (item.buyer.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Buyer: ${item.buyer}', style: muted),
            ],
            if (item.reason.isNotEmpty || item.reasonLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Reason: ${item.reasonLabel.isNotEmpty ? item.reasonLabel : _reasonLabel(item.reason)}',
                  style: theme.textTheme.bodyMedium),
            ],
            if (item.note != null) ...[
              const SizedBox(height: 4),
              Text(item.note!, style: theme.textTheme.bodyMedium),
            ],
            if (item.photos.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(imageUrl: item.photos[i], width: 64, memCacheWidth: 192, height: 64, fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
            if (item.requestedAt != null) ...[
              const SizedBox(height: 6),
              Text('Requested ${DateFormat('d MMM, h:mm a').format(item.requestedAt!)}', style: muted),
            ],
            if (item.followUpStep != null) ...[
              const SizedBox(height: 4),
              Text('Follow-up: ${_stepLabel(item.followUpStep!)}', style: muted),
            ],
            Obx(() {
              final busy = controller.isProcessing(item);
              if (busy) {
                return const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                );
              }
              if (item.isOpen) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(minimumSize: _tap),
                        onPressed: () => RejectReturnSheet.show(context, item, controller),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(minimumSize: _tap),
                        onPressed: () => _confirmApprove(context),
                        child: const Text('Approve'),
                      ),
                    ),
                  ]),
                );
              }
              // Approved / rejected: details (items, downloads, your reason)
              // and the follow-up steps the server allows.
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    key: Key('details_${item.requestId}'),
                    style: TextButton.styleFrom(minimumSize: _tap),
                    onPressed: () => ReturnDetailSheet.show(item, controller),
                    child: Text(item.isApproved ? 'Details and next step' : 'Details'),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmApprove(BuildContext context) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: const Text('Approve this return?'),
      content: Text(item.kind == ReturnKind.refundRequest
          ? 'Edudeen refunds the buyer; the amount is taken from your earnings.'
          : 'The buyer will be told to send the item back.'),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: _tap),
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: _tap),
          onPressed: () => Get.back(result: true),
          child: const Text('Approve'),
        ),
      ],
    ));
    if (ok == true) await controller.approve(item);
  }

  static String _statusLabel(String s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1).replaceAll('_', ' ')}';

  static String _stepLabel(String s) => switch (s) {
        'item_received' => 'Item received',
        'replacement_sent' => 'Replacement sent',
        _ => s.replaceAll('_', ' '),
      };

  /// The one reason list (docs Part B 2.7); old codes are shown as sent.
  static String _reasonLabel(String r) => switch (r) {
        'damaged' => 'Damaged',
        'missing_pages' => 'Missing pages',
        'printing_error' => 'Printing error',
        'wrong_item' => 'Wrong item',
        'wrong_edition_or_class' => 'Wrong edition or class',
        'not_as_described' => 'Not as described',
        'digital_not_working' => 'Digital file not working',
        'other' => 'Other',
        _ => r,
      };
}

class RejectReturnSheet extends StatefulWidget {
  const RejectReturnSheet({super.key, required this.item, required this.controller});
  final SellerReturnItem item;
  final SellerReturnsController controller;

  static Future<void> show(BuildContext context, SellerReturnItem item, SellerReturnsController c) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => RejectReturnSheet(item: item, controller: c),
      );

  @override
  State<RejectReturnSheet> createState() => _RejectReturnSheetState();
}

class _RejectReturnSheetState extends State<RejectReturnSheet> {
  final _text = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final err = SellerReturnsController.validateRejectReason(_text.text);
    setState(() => _error = err);
    if (err != null) return;
    final ok = await widget.controller.reject(widget.item, _text.text);
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Reject this return', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('The buyer will see your reason.', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            key: const Key('rejectReason'),
            controller: _text,
            minLines: 3,
            maxLines: 5,
            maxLength: 500,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              labelText: 'Reason (at least ${SellerReturnsController.minRejectChars} characters)',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: theme.colorScheme.error,
                ),
                onPressed: widget.controller.isProcessing(widget.item) ? null : _submit,
                child: const Text('Reject return'),
              )),
        ],
      ),
    );
  }
}

/// One return / refund in full, from the detail route. Follow-up buttons
/// appear only when the server's `actions` allow them.
class ReturnDetailSheet extends StatefulWidget {
  const ReturnDetailSheet({super.key, required this.item, required this.controller});
  final SellerReturnItem item;
  final SellerReturnsController controller;

  static Future<void> show(SellerReturnItem item, SellerReturnsController controller) => Get.bottomSheet(
        ReturnDetailSheet(item: item, controller: controller),
        isScrollControlled: true,
        backgroundColor: Get.theme.colorScheme.surface,
      );

  @override
  State<ReturnDetailSheet> createState() => _ReturnDetailSheetState();
}

class _ReturnDetailSheetState extends State<ReturnDetailSheet> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadDetail(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final item = widget.item;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final d = c.detailFor(item);
          if (d == null && c.detailLoadFailed(item)) {
            return ReturnsMessage(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load the details',
              body: 'Check your connection and try again.',
              action: FilledButton.tonal(
                style: FilledButton.styleFrom(minimumSize: _tap),
                onPressed: () => c.loadDetail(item),
                child: const Text('Retry'),
              ),
            );
          }
          if (d == null) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
          final busy = c.isProcessing(item);
          return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.orderNumber.isEmpty ? 'Return' : '#${item.orderNumber}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final i in d.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text([
                  '${i.name} × ${i.quantity}',
                  i.type == 'digital' ? 'Digital' : 'Physical',
                  if (i.downloadCount != null) 'Downloaded: ${i.downloadCount! > 0 ? 'Yes (${i.downloadCount})' : 'No'}',
                ].join(' · ')),
              ),
            if (d.rejectReason != null) ...[
              const SizedBox(height: 6),
              Text('Your reason: ${d.rejectReason}'),
            ],
            if (d.followUp != null) ...[
              const SizedBox(height: 6),
              Text('Follow-up: ${d.followUp == 'item_received' ? 'Item received' : 'Replacement sent'}'
                  '${d.followUpNote == null ? '' : ' – ${d.followUpNote}'}'),
            ],
            const SizedBox(height: 12),
            if (busy) const LinearProgressIndicator(),
            if (!busy && d.canMarkReceived)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('markReceived'),
                  style: OutlinedButton.styleFrom(minimumSize: _tap),
                  onPressed: () async {
                    if (await c.followUp(item, 'item_received')) Get.back();
                  },
                  child: const Text('Mark item received'),
                ),
              ),
            if (!busy && d.canMarkReplacementSent)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const Key('markReplacement'),
                  style: OutlinedButton.styleFrom(minimumSize: _tap),
                  onPressed: () async {
                    if (await c.followUp(item, 'replacement_sent')) Get.back();
                  },
                  child: const Text('Mark replacement sent'),
                ),
              ),
          ]);
        }),
      ),
    );
  }
}
