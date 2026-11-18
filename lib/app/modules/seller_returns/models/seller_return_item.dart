// One row of GET /api/orders/seller-returns-all/:storeId (docs 6.6): item
// returns + item refund requests in ONE list.
//
// Row shape from the backend (5adba44, src/orders/seller-returns-all.util.ts
// ReturnsListRow, built in orders.service.ts):
//   {source: 'return'|'refund', requestId, itemIds, orderId, orderNumber,
//    storeId, item, buyer, type: 'Return'|'Refund only', reason, reasonLabel,
//    status: 'open'|'approved'|'rejected', requestedAt, respondBy, isOverdue,
//    amount, note?, evidenceImages?, followUp: null|item_received|replacement_sent}
// requestId: refund = the RefundRequest _id; return = "<orderId>:<itemId>".

String? _s(dynamic v) {
  if (v == null || v is Map || v is List) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

DateTime? _t(dynamic v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();

enum ReturnKind { itemReturn, refundRequest }

class SellerReturnItem {
  const SellerReturnItem({
    required this.requestId,
    required this.kind,
    required this.orderId,
    required this.orderNumber,
    required this.itemIds,
    required this.productName,
    required this.buyer,
    required this.reason,
    required this.reasonLabel,
    required this.note,
    required this.photos,
    required this.status,
    required this.requestedAt,
    required this.respondBy,
    required this.isOverdue,
    required this.amount,
    required this.followUpStep,
  });

  /// Refund: the RefundRequest _id. Return: `"<orderId>:<itemId>"`.
  final String requestId;
  final ReturnKind kind;
  final String orderId;
  final String orderNumber;
  final List<String> itemIds;
  final String productName;
  final String buyer;
  final String reason;
  final String reasonLabel;
  final String? note;
  final List<String> photos;

  /// open | approved | rejected
  final String status;
  final DateTime? requestedAt;

  /// Server display deadline (requestedAt + 48 h; nothing is auto-approved).
  final DateTime? respondBy;
  final bool isOverdue;
  final num amount;

  /// Follow-up tracking: null | item_received | replacement_sent.
  final String? followUpStep;

  /// `source` path segment for the detail route.
  String get source => kind == ReturnKind.refundRequest ? 'refund' : 'return';

  bool get isOpen => status == 'open';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory SellerReturnItem.fromJson(Map<String, dynamic> j) {
    final ev = j['evidenceImages'];
    return SellerReturnItem(
      requestId: _s(j['requestId']) ?? '',
      kind: _s(j['source']) == 'refund' ? ReturnKind.refundRequest : ReturnKind.itemReturn,
      orderId: _s(j['orderId']) ?? '',
      orderNumber: _s(j['orderNumber']) ?? '',
      itemIds: j['itemIds'] is List ? (j['itemIds'] as List).map((e) => '$e').toList() : const [],
      productName: _s(j['item']) ?? '',
      buyer: _s(j['buyer']) ?? '',
      reason: _s(j['reason']) ?? '',
      reasonLabel: _s(j['reasonLabel']) ?? _s(j['reason']) ?? '',
      note: _s(j['note']),
      photos: ev is List ? ev.map((e) => e is Map ? '${e['url']}' : '$e').where((u) => u.isNotEmpty).toList() : const [],
      status: (_s(j['status']) ?? '').toLowerCase(),
      requestedAt: _t(j['requestedAt']),
      respondBy: _t(j['respondBy']),
      isOverdue: j['isOverdue'] == true,
      amount: j['amount'] is num ? j['amount'] as num : 0,
      followUpStep: _s(j['followUp']),
    );
  }
}

/// GET /api/orders/seller-returns-all/:storeId/:source/:requestId
/// (src/orders/return-detail.util.ts buildReturnDetail). The follow-up
/// buttons come from the server's `actions`, never decided on the device.
class SellerReturnDetail {
  const SellerReturnDetail({
    required this.items,
    required this.rejectReason,
    required this.followUp,
    required this.followUpNote,
    required this.canReview,
    required this.canMarkReceived,
    required this.canMarkReplacementSent,
    required this.currency,
  });

  final List<({String id, String name, String type, int quantity, int? downloadCount})> items;
  final String? rejectReason;
  final String? followUp;
  final String? followUpNote;
  final bool canReview;
  final bool canMarkReceived;
  final bool canMarkReplacementSent;
  final String currency;

  factory SellerReturnDetail.fromJson(Map<String, dynamic> j) {
    final a = j['actions'] is Map ? j['actions'] as Map : const {};
    return SellerReturnDetail(
      items: [
        for (final i in (j['items'] as List? ?? const []).whereType<Map>())
          (
            id: '${i['id'] ?? ''}',
            name: '${i['name'] ?? ''}',
            type: '${i['type'] ?? 'physical'}',
            quantity: (i['quantity'] as num?)?.toInt() ?? 1,
            downloadCount: (i['downloadCount'] as num?)?.toInt(),
          ),
      ],
      rejectReason: _s(j['rejectReason']),
      followUp: _s(j['followUp']),
      followUpNote: _s(j['followUpNote']),
      canReview: a['canReview'] == true,
      canMarkReceived: a['canMarkReceived'] == true,
      canMarkReplacementSent: a['canMarkReplacementSent'] == true,
      currency: _s(j['currency']) ?? '',
    );
  }
}

/// `data.stats` of seller-returns-all.
class SellerReturnStats {
  const SellerReturnStats({
    required this.open,
    required this.overdue,
    required this.returnRatePct,
    required this.refunded30d,
  });

  final int open;
  final int overdue;

  /// null = "Not enough data" (the API only rates stores with >= 10 orders).
  final num? returnRatePct;
  final num refunded30d;

  static const empty = SellerReturnStats(open: 0, overdue: 0, returnRatePct: null, refunded30d: 0);

  factory SellerReturnStats.fromJson(Map<String, dynamic> j) {
    final rate = j['returnRate30d'];
    return SellerReturnStats(
      open: (j['open'] as num?)?.toInt() ?? 0,
      overdue: (j['overdue'] as num?)?.toInt() ?? 0,
      returnRatePct: rate is Map ? rate['pct'] as num? : null,
      refunded30d: (j['refunded30d'] as num?) ?? 0,
    );
  }
}

/// Respond-by pill (docs 6.6): grey, amber under 12 h, red when overdue.
enum RespondByLevel { normal, soon, overdue }

RespondByLevel respondByLevel(DateTime respondBy, DateTime now) {
  final left = respondBy.difference(now);
  if (left.isNegative) return RespondByLevel.overdue;
  if (left < const Duration(hours: 12)) return RespondByLevel.soon;
  return RespondByLevel.normal;
}

String respondByLabel(DateTime respondBy, DateTime now) {
  final left = respondBy.difference(now);
  if (left.isNegative) {
    final h = -left.inHours;
    return h >= 24 ? 'Overdue by ${h ~/ 24}d' : 'Overdue by ${h < 1 ? 1 : h}h';
  }
  final h = left.inHours;
  return h >= 24 ? 'Respond in ${h ~/ 24}d ${h % 24}h' : 'Respond in ${h < 1 ? 1 : h}h';
}
