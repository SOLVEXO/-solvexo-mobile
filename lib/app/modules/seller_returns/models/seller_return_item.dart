// One row of GET /api/orders/seller-returns-all/:storeId (docs Part B 6.6):
// item returns + item refund requests in ONE list.
//
// Live response for the test store (2026-11-17):
//   {success, data:{stats:{open, overdue, returnRate30d:{pct, returns,
//    orders}, refunded30d}, pagination:{page, limit, total, totalPages},
//    items:[]}}
// The store had no returns, so the row keys could not be seen; they are read
// defensively (several names per field) and a field that is missing hides
// its block.

String? _s(dynamic v) {
  if (v == null || v is Map || v is List) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

DateTime? _t(dynamic v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();

enum ReturnKind { itemReturn, refundRequest }

class SellerReturnItem {
  const SellerReturnItem({
    required this.id,
    required this.kind,
    required this.orderId,
    required this.orderNumber,
    required this.itemIds,
    required this.productName,
    required this.productType,
    required this.reason,
    required this.note,
    required this.photos,
    required this.status,
    required this.requestedAt,
    required this.respondBy,
    required this.downloaded,
    required this.followUpStep,
    required this.rejectReason,
  });

  /// Refund-request id (refund rows) or the order id (item returns).
  final String id;
  final ReturnKind kind;
  final String orderId;
  final String orderNumber;
  final List<String> itemIds;
  final String productName;
  final String productType; // physical | digital
  final String reason;
  final String? note;
  final List<String> photos;

  /// requested | pending | approved | rejected | refunded | ...
  final String status;
  final DateTime? requestedAt;

  /// Server deadline when sent; otherwise requestedAt + 48 h (display only,
  /// docs Part B 2.7: nothing is auto-approved).
  final DateTime? respondBy;

  /// Digital rows: whether the buyer downloaded the file (null = unknown).
  final bool? downloaded;

  /// Follow-up tracking: null | item_received | replacement_sent.
  final String? followUpStep;
  final String? rejectReason;

  bool get isOpen => status == 'requested' || status == 'pending' || status == 'open';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isDigital => productType == 'digital';

  /// Next follow-up step (item_received -> replacement_sent; no money).
  String? get nextFollowUp {
    if (!isApproved || kind != ReturnKind.itemReturn || isDigital) return null;
    if (followUpStep == null || followUpStep!.isEmpty) return 'item_received';
    if (followUpStep == 'item_received') return 'replacement_sent';
    return null;
  }

  static ReturnKind _kind(Map<String, dynamic> j) {
    final k = (_s(j['kind']) ?? _s(j['source']) ?? _s(j['type']) ?? '').toLowerCase();
    if (k.contains('refund')) return ReturnKind.refundRequest;
    if (k.contains('return')) return ReturnKind.itemReturn;
    // A refund-request document carries itemIds + its own _id and orderId.
    return j['refundRequestId'] != null || (j['itemIds'] is List && j['_id'] != null && j['orderId'] != null)
        ? ReturnKind.refundRequest
        : ReturnKind.itemReturn;
  }

  factory SellerReturnItem.fromJson(Map<String, dynamic> j) {
    final kind = _kind(j);
    final product = j['product'] is Map ? Map<String, dynamic>.from(j['product'] as Map) : const <String, dynamic>{};
    final itemIds = <String>[
      if (j['itemIds'] is List) ...(j['itemIds'] as List).map((e) => '$e'),
      if (j['itemIds'] is! List && _s(j['itemId']) != null) _s(j['itemId'])!,
    ];
    final requestedAt = _t(j['requestedAt'] ?? j['returnRequestedAt'] ?? j['createdAt']);
    final respondBy = _t(j['respondBy'] ?? j['respondByAt'] ?? j['dueAt']) ??
        requestedAt?.add(const Duration(hours: 48));
    final followUp = j['followUp'];
    final photos = j['photos'] ?? j['images'] ?? j['returnPhotos'];
    final dl = j['downloaded'] ?? j['isDownloaded'] ?? j['digitalDownloaded'];
    return SellerReturnItem(
      id: _s(j['refundRequestId']) ?? _s(j['_id']) ?? _s(j['id']) ?? _s(j['orderId']) ?? '',
      kind: kind,
      orderId: _s(j['orderId']) ?? '',
      orderNumber: _s(j['orderNumber']) ?? '',
      itemIds: itemIds,
      productName: _s(j['productName']) ?? _s(j['name']) ?? _s(product['name']) ?? '',
      productType: (_s(j['productType']) ?? _s(j['itemType']) ?? _s(product['type']) ?? '').toLowerCase(),
      reason: _s(j['reason']) ?? _s(j['returnReason']) ?? '',
      note: _s(j['note']) ?? _s(j['details']) ?? _s(j['returnNote']),
      photos: photos is List ? photos.map((e) => e is Map ? '${e['url']}' : '$e').toList() : const [],
      status: (_s(j['status']) ?? _s(j['returnStatus']) ?? '').toLowerCase(),
      requestedAt: requestedAt,
      respondBy: respondBy,
      downloaded: dl is bool ? dl : null,
      followUpStep: followUp is Map ? _s(followUp['step']) : _s(followUp) ?? _s(j['followUpStep']),
      rejectReason: _s(j['rejectReason']) ?? _s(j['returnRejectReason']) ?? _s(j['resolutionNotes']),
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
