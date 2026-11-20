import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/data/models/refund_request_model.dart';
import 'package:book_store_app/app/data/models/return_reasons.dart';
import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:book_store_app/app/modules/refund_request/controllers/refund_request_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Returns & refunds (B5): your requests with status + timeline (and the
/// seller's reject reason), then the form. Buyer screen: .tr, RTL-safe.
class RefundRequestView extends StatelessWidget {
  RefundRequestView({super.key});
  final controller = Get.put(RefundRequestController());

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      appBar: AppBar(title: Text('Returns & refunds'.tr)),
      body: Obx(() {
        if (c.isLoadingStatuses.value) return const BuyerSkeleton(rows: 3, rowHeight: 100);
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('#${c.order.orderNumber}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (c.statusFailed.value) BuyerError(message: 'Could not load your requests.'.tr, onRetry: c.loadExistingRequests),
          for (final r in c.existingRequests) _RequestCard(request: r),
          for (final i in c.itemReturns) _ItemReturnCard(item: i),
          const SizedBox(height: 8),
          if (c.eligibleStores.isEmpty)
            BuyerEmpty(icon: Icons.assignment_return_outlined, title: 'Nothing in this order can be returned now'.tr,
                body: 'Items can be returned or refunded after they are delivered.'.tr)
          else
            const _Form(),
        ]);
      }),
    );
  }
}

String _statusLabel(String s) => switch (s) {
      'pending' || 'requested' => 'Waiting for the seller'.tr,
      'approved' => 'Approved'.tr,
      'rejected' => 'Rejected'.tr,
      'item_received' => 'Item received back'.tr,
      'replacement_sent' => 'Replacement sent'.tr,
      _ => s,
    };

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});
  final RefundRequestModel request;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final t = Theme.of(context);
    final df = DateFormat('d MMM y, h:mm a');
    return Card(
      key: Key('refund_${r.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Refund request'.tr, style: t.textTheme.titleSmall)),
            Chip(label: Text(_statusLabel(r.status)), visualDensity: VisualDensity.compact),
          ]),
          Text(returnReasonLabel(r.reasonCode, r.reason)),
          if ((r.note ?? '').isNotEmpty) Text(r.note!, style: t.textTheme.bodySmall),
          if (r.isRejected && (r.resolutionNotes ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('${'Seller said'.tr}: ${r.resolutionNotes}', key: const Key('sellerRejectReason'), style: TextStyle(color: t.colorScheme.error)),
            ),
          if (r.history.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final h in r.history)
              Row(children: [
                const Icon(Icons.circle, size: 8),
                const SizedBox(width: 8),
                Expanded(
                  child: Text([
                    _statusLabel('${h['status']}'),
                    if (DateTime.tryParse('${h['at']}') != null) df.format(DateTime.parse('${h['at']}').toLocal()),
                    if ((h['note'] ?? '').toString().isNotEmpty) '${h['note']}',
                  ].join(' · '), style: t.textTheme.bodySmall),
                ),
              ]),
          ],
        ]),
      ),
    );
  }
}

class _ItemReturnCard extends StatelessWidget {
  const _ItemReturnCard({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        minTileHeight: 56,
        title: Text(item.name),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${'Return'.tr}: ${_statusLabel(item.returnStatus)}'),
          if (item.returnStatus == 'rejected' && (item.returnRejectReason ?? '').isNotEmpty)
            Text('${'Seller said'.tr}: ${item.returnRejectReason}', style: TextStyle(color: t.colorScheme.error)),
        ]),
      ),
    );
  }
}

class _Form extends GetView<RefundRequestController> {
  const _Form();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RefundRequestController>();
    final t = Theme.of(context);
    return Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Report a problem'.tr, style: t.textTheme.titleMedium),
          if (c.eligibleStores.length > 1) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: c.selectedStore.value?.sellerOrderId,
              decoration: InputDecoration(labelText: 'Seller'.tr, border: const OutlineInputBorder()),
              items: [for (final s in c.eligibleStores) DropdownMenuItem(value: s.sellerOrderId, child: Text(s.sellerName ?? s.storeId))],
              onChanged: (v) => c.selectStore(c.eligibleStores.firstWhere((s) => s.sellerOrderId == v)),
            ),
          ],
          const SizedBox(height: 8),
          for (final i in c.returnableItems)
            CheckboxListTile(
              key: Key('returnItem_${i.itemId}'),
              contentPadding: EdgeInsets.zero,
              value: c.selectedItemIds.contains(i.itemId),
              onChanged: (_) => c.toggleItem(i.itemId),
              title: Text(i.name),
              subtitle: Text(i.type == 'digital' ? 'Digital'.tr : 'Physical'.tr),
            ),
          if (c.errors['items'] != null) Text(c.errors['items']!, style: TextStyle(color: t.colorScheme.error)),
          if (c.canSendBack) ...[
            const SizedBox(height: 8),
            SegmentedButton<String>(
              key: const Key('returnKind'),
              segments: [
                ButtonSegment(value: 'return', label: Text('Return the item'.tr)),
                ButtonSegment(value: 'refund', label: Text('Refund only'.tr)),
              ],
              selected: {c.kind.value},
              onSelectionChanged: (v) => c.kind.value = v.first,
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('returnReason'),
            initialValue: c.reasonCode.value,
            isExpanded: true,
            decoration: InputDecoration(labelText: '${'Reason'.tr} *', errorText: c.errors['reason'], border: const OutlineInputBorder()),
            items: [for (final r in c.reasons) DropdownMenuItem(value: r.$1, child: Text(r.$2.tr))],
            onChanged: (v) {
              c.reasonCode.value = v;
              c.errors.remove('reason');
            },
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('returnNote'),
            controller: c.noteController,
            minLines: 3,
            maxLines: 6,
            maxLength: ReturnRules.noteMax,
            onChanged: (_) => c.errors.remove('note'),
            decoration: InputDecoration(
              labelText: '${'Describe the problem'.tr} *',
              helperText: '${ReturnRules.noteMin}-${ReturnRules.noteMax} ${'characters'.tr}',
              errorText: c.errors['note'],
              border: const OutlineInputBorder(),
            ),
          ),
          if (!c.selectionIsDigital) ...[
            Text('${'Photos'.tr} (${c.photos.length}/${ReturnRules.maxPhotos})', style: t.textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in c.photos)
                Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: p, width: 72, height: 72, fit: BoxFit.cover)),
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: InkWell(onTap: () => c.photos.remove(p), child: const CircleAvatar(radius: 12, child: Icon(Icons.close, size: 14))),
                  ),
                ]),
              if (c.photos.length < ReturnRules.maxPhotos)
                InkWell(
                  key: const Key('addReturnPhoto'),
                  onTap: c.uploading.value ? null : () => AppImagePicker.show(onPicked: c.addPhoto),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(border: Border.all(color: t.colorScheme.outline), borderRadius: BorderRadius.circular(8)),
                    child: c.uploading.value ? const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_a_photo_outlined),
                  ),
                ),
            ]),
          ],
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('returnSubmit'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: c.isLoading.value || c.uploading.value ? null : c.submit,
            child: c.isLoading.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(c.kind.value == 'return' && c.canSendBack ? 'Send return request'.tr : 'Send refund request'.tr),
          ),
        ]));
  }
}
