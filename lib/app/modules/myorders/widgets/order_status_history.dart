import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// One real step of an order's history.
class OrderHistoryEntry {
  const OrderHistoryEntry(this.title, {this.at, this.detail});
  final String title;
  final DateTime? at;
  final String? detail;
}

/// Builds the history only from what the API sent (order createdAt/paidAt,
/// each package's status, shippedAt, tracking, trackingEvents, deliveredAt).
/// Returns an empty list when nothing has happened after the order was
/// placed, so the block can be hidden.
List<OrderHistoryEntry> buildOrderHistory(OrderModel order) {
  final multi = order.stores.length > 1;
  final out = <OrderHistoryEntry>[];
  if (order.paidAt != null && order.isPaid) {
    out.add(OrderHistoryEntry('Payment confirmed'.tr, at: order.paidAt));
  }
  for (final s in order.stores) {
    final who = multi && (s.sellerName ?? '').isNotEmpty ? ' · ${s.sellerName}' : '';
    for (final e in s.trackingEvents) {
      out.add(OrderHistoryEntry('${e.title}$who', at: e.at, detail: e.detail));
    }
    if (s.shippedAt != null) {
      final t = s.tracking;
      final courier = t == null
          ? null
          : [if (t.carrier.isNotEmpty) t.carrier, if (t.trackingNumber.isNotEmpty) t.trackingNumber].join(' · ');
      out.add(OrderHistoryEntry('${'Shipped'.tr}$who', at: s.shippedAt, detail: courier));
    }
    if (s.deliveredAt != null) {
      out.add(OrderHistoryEntry('${'Delivered'.tr}$who', at: s.deliveredAt));
    }
    if (s.status == 'cancelled' && order.orderStatus != 'cancelled') {
      out.add(OrderHistoryEntry('${'Cancelled'.tr}$who'));
    }
  }
  if (order.orderStatus == 'cancelled') out.add(OrderHistoryEntry('Order cancelled'.tr));
  if (out.isEmpty) return const [];
  out.sort((a, b) {
    if (a.at == null && b.at == null) return 0;
    if (a.at == null) return 1;
    if (b.at == null) return -1;
    return a.at!.compareTo(b.at!);
  });
  return [OrderHistoryEntry('Order placed'.tr, at: order.createdAt), ...out];
}

/// Real status history (no invented steps). Hidden when there is none.
class OrderStatusHistory extends StatelessWidget {
  const OrderStatusHistory({super.key, required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final entries = buildOrderHistory(order);
    if (entries.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final fmt = DateFormat('d MMM, h:mm a');
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order history'.tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (var i = 0; i < entries.length; i++)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(children: [
                  Icon(Icons.circle,
                      size: 12,
                      color: i == entries.length - 1
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline),
                  if (i < entries.length - 1)
                    Container(width: 2, height: 34, color: theme.colorScheme.outlineVariant),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(entries[i].title, style: theme.textTheme.bodyMedium),
                      if (entries[i].at != null)
                        Text(fmt.format(entries[i].at!.toLocal()), style: theme.textTheme.bodySmall),
                      if (entries[i].detail != null && entries[i].detail!.isNotEmpty)
                        Text(entries[i].detail!, style: theme.textTheme.bodySmall),
                    ]),
                  ),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

/// One `trackingEvents` entry. The test orders had none, so it is read
/// defensively; an entry without a title is skipped.
class TrackingEvent {
  const TrackingEvent({required this.title, this.at, this.detail});
  final String title;
  final DateTime? at;
  final String? detail;

  static TrackingEvent? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final title = (raw['label'] ?? raw['title'] ?? raw['status'] ?? raw['event'])?.toString();
    if (title == null || title.isEmpty) return null;
    final detail = (raw['note'] ?? raw['description'] ?? raw['location'])?.toString();
    return TrackingEvent(
      title: title[0].toUpperCase() + title.substring(1).replaceAll('_', ' '),
      at: DateTime.tryParse('${raw['at'] ?? raw['date'] ?? raw['timestamp'] ?? raw['createdAt'] ?? ''}'),
      detail: detail,
    );
  }
}

extension OrderStoreHistory on OrderStore {
  List<TrackingEvent> get trackingEvents => rawTrackingEvents
      .map(TrackingEvent.fromJson)
      .whereType<TrackingEvent>()
      .toList();
}
