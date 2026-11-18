import 'package:book_store_app/app/data/repositories/refund_request_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Orders extends SellerOrdersRepository {
  _Orders(this.rows);
  final List<SellerReturnItem> rows;
  final calls = <String>[];

  @override
  Future<({List<SellerReturnItem> items, SellerReturnStats stats, int totalPages})> getReturnsAll(
    String storeId, {
    int page = 1,
    int limit = 20,
  }) async =>
      (items: rows, stats: SellerReturnStats.empty, totalPages: 1);

  @override
  Future<bool> returnAction({
    required String orderId,
    required String storeId,
    required List<String> itemIds,
    required String action,
    String? rejectReason,
  }) async {
    calls.add('return-action $orderId $storeId $itemIds $action ${rejectReason ?? ''}');
    return true;
  }

  @override
  Future<bool> returnFollowUp({
    required String orderId,
    required String storeId,
    required String itemId,
    required String step,
  }) async {
    calls.add('follow-up $orderId $itemId $step');
    return true;
  }
}

class _Refunds extends RefundRequestRepository {
  final calls = <String>[];
  @override
  Future<bool> approve(String id) async {
    calls.add('approve $id');
    return true;
  }

  @override
  Future<bool> reject(String id, String notes) async {
    calls.add('reject $id $notes');
    return true;
  }

  @override
  Future<bool> followUp(String id, String step, {String? note}) async {
    calls.add('follow-up $id $step');
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({'store_id': 's1'}));

  test('live stats body (test store, 2026-11-17)', () {
    final s = SellerReturnStats.fromJson({
      'open': 0,
      'overdue': 0,
      'returnRate30d': {'pct': null, 'returns': 0, 'orders': 0},
      'refunded30d': 0,
    });
    expect(s.open, 0);
    expect(s.returnRatePct, isNull, reason: 'shown as "Not enough data"');
  });

  // Rows exactly as the backend builds them (5adba44,
  // orders.service.ts getSellerReturnsAll -> ReturnsListRow).
  const returnRow = {
    'source': 'return', 'requestId': 'o1:i1', 'itemIds': ['i1'], 'orderId': 'o1', 'orderNumber': 'ORD-1',
    'storeId': 's1', 'item': 'English vocabulary Book', 'buyer': 'Test Buyer', 'type': 'Return',
    'reason': 'damaged', 'status': 'open', 'requestedAt': '2026-11-17T08:00:00.000Z',
    'respondBy': '2026-11-19T08:00:00.000Z', 'isOverdue': false, 'amount': 200, 'followUp': null,
    'reasonLabel': 'Damaged',
  };
  const refundRow = {
    'source': 'refund', 'requestId': 'r1', 'itemIds': ['i2'], 'orderId': 'o2', 'orderNumber': 'ORD-2',
    'storeId': 's1', 'item': 'Maths worksheets', 'buyer': 'Test Buyer', 'type': 'Refund only',
    'reason': 'File does not open', 'status': 'open', 'requestedAt': '2026-11-17T09:00:00.000Z',
    'respondBy': '2026-11-19T09:00:00.000Z', 'isOverdue': false, 'amount': 650,
    'note': 'The PDF says it is damaged', 'evidenceImages': ['https://example.com/e1.jpg'], 'followUp': null,
    'reasonLabel': 'Digital file not working',
  };

  test('rows: real keys (source, requestId, item, evidenceImages)', () {
    final ret = SellerReturnItem.fromJson(returnRow);
    expect((ret.kind, ret.source, ret.requestId), (ReturnKind.itemReturn, 'return', 'o1:i1'));
    expect(ret.itemIds, ['i1']);
    expect(ret.productName, 'English vocabulary Book');
    expect(ret.reasonLabel, 'Damaged');
    expect(ret.isOpen, isTrue);
    expect(ret.respondBy, DateTime.parse('2026-11-19T08:00:00.000Z').toLocal());

    final refund = SellerReturnItem.fromJson(refundRow);
    expect((refund.kind, refund.source, refund.requestId), (ReturnKind.refundRequest, 'refund', 'r1'));
    expect(refund.photos, ['https://example.com/e1.jpg']);
    expect(refund.note, 'The PDF says it is damaged');
    expect(refund.orderId, 'o2', reason: 'never used as the refund id');
  });

  test('detail: items, downloads and server actions', () {
    final d = SellerReturnDetail.fromJson({
      'source': 'refund', 'requestId': 'r1', 'status': 'approved', 'followUp': null, 'currency': 'PKR',
      'items': [
        {'id': 'i2', 'name': 'Maths worksheets', 'type': 'digital', 'quantity': 1, 'totalPrice': 650, 'refundedAmount': 650, 'downloadCount': 0},
      ],
      'rejectReason': null,
      'actions': {'canReview': false, 'canMarkReceived': false, 'canMarkReplacementSent': true},
    });
    expect(d.items.single.type, 'digital');
    expect(d.items.single.downloadCount, 0);
    expect((d.canMarkReceived, d.canMarkReplacementSent), (false, true));
  });

  test('respond-by pill levels', () {
    final now = DateTime(2026, 11, 17, 12);
    expect(respondByLevel(now.add(const Duration(hours: 30)), now), RespondByLevel.normal);
    expect(respondByLevel(now.add(const Duration(hours: 5)), now), RespondByLevel.soon);
    expect(respondByLevel(now.subtract(const Duration(hours: 2)), now), RespondByLevel.overdue);
    expect(respondByLabel(now.subtract(const Duration(hours: 2)), now), 'Overdue by 2h');
  });

  test('reject needs at least 10 characters (API rule)', () {
    expect(SellerReturnsController.validateRejectReason('short'), isNotNull);
    expect(SellerReturnsController.validateRejectReason('Item was not damaged'), isNull);
  });

  test('actions use requestId per source', () async {
    final ret = SellerReturnItem.fromJson(returnRow);
    final refund = SellerReturnItem.fromJson(refundRow);
    final approvedReturn = SellerReturnItem.fromJson({...returnRow, 'requestId': 'o3:i3', 'orderId': 'o3', 'itemIds': ['i3'], 'status': 'approved'});
    final approvedRefund = SellerReturnItem.fromJson({...refundRow, 'requestId': 'r9', 'status': 'approved'});
    final orders = _Orders([ret, refund, approvedReturn, approvedRefund]);
    final refunds = _Refunds();
    final c = SellerReturnsController(orders: orders, refunds: refunds);
    await c.refreshData();

    await c.approve(ret);
    await c.approve(refund);
    await c.reject(refund, 'Buyer downloaded the file already');
    expect(await c.reject(ret, 'no'), isFalse, reason: 'too short: nothing sent');
    await c.followUp(approvedReturn, 'item_received');
    await c.followUp(approvedRefund, 'replacement_sent');

    expect(orders.calls, [
      'return-action o1 s1 [i1] approve ',
      'follow-up o3 i3 item_received',
    ]);
    expect(refunds.calls, ['approve r1', 'reject r1 Buyer downloaded the file already', 'follow-up r9 replacement_sent']);
  });
}
