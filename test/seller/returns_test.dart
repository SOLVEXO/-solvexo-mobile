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

  test('rows: item return vs refund request, digital downloaded flag', () {
    final ret = SellerReturnItem.fromJson({
      'kind': 'return',
      'orderId': 'o1',
      'orderNumber': 'ORD-1',
      'itemId': 'i1',
      'productName': 'English vocabulary Book',
      'productType': 'physical',
      'reason': 'damaged',
      'status': 'requested',
      'requestedAt': '2026-11-17T08:00:00.000Z',
    });
    expect(ret.kind, ReturnKind.itemReturn);
    expect(ret.itemIds, ['i1']);
    expect(ret.isOpen, isTrue);
    expect(ret.respondBy, DateTime.parse('2026-11-19T08:00:00.000Z').toLocal());

    final refund = SellerReturnItem.fromJson({
      'kind': 'refund_request',
      '_id': 'r1',
      'orderId': 'o2',
      'itemIds': ['i2'],
      'productType': 'digital',
      'downloaded': false,
      'status': 'pending',
      'respondBy': '2026-11-18T10:00:00.000Z',
    });
    expect(refund.kind, ReturnKind.refundRequest);
    expect(refund.id, 'r1');
    expect(refund.downloaded, isFalse);
    expect(refund.respondBy, DateTime.parse('2026-11-18T10:00:00.000Z').toLocal());
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

  test('actions go to the right endpoint per kind; follow-up order', () async {
    final ret = SellerReturnItem.fromJson({
      'kind': 'return', 'orderId': 'o1', 'itemId': 'i1', 'productType': 'physical', 'status': 'requested',
    });
    final refund = SellerReturnItem.fromJson({
      'kind': 'refund_request', '_id': 'r1', 'orderId': 'o2', 'itemIds': ['i2'], 'status': 'pending',
    });
    final approvedReturn = SellerReturnItem.fromJson({
      'kind': 'return', 'orderId': 'o3', 'itemId': 'i3', 'productType': 'physical', 'status': 'approved',
    });
    final orders = _Orders([ret, refund, approvedReturn]);
    final refunds = _Refunds();
    final c = SellerReturnsController(orders: orders, refunds: refunds);
    await c.refreshData();

    await c.approve(ret);
    await c.reject(refund, 'Buyer downloaded the file already');
    expect(await c.reject(ret, 'no'), isFalse, reason: 'too short: nothing sent');
    await c.followUp(approvedReturn);

    expect(orders.calls, [
      'return-action o1 s1 [i1] approve ',
      'follow-up o3 i3 item_received',
    ]);
    expect(refunds.calls, ['reject r1 Buyer downloaded the file already']);
    expect(approvedReturn.nextFollowUp, 'item_received');
    expect(
      SellerReturnItem.fromJson({
        'kind': 'return', 'orderId': 'o3', 'itemId': 'i3', 'productType': 'physical',
        'status': 'approved', 'followUp': {'step': 'item_received'},
      }).nextFollowUp,
      'replacement_sent',
    );
  });
}
