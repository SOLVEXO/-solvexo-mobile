import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Client extends BaseClient {
  Map<String, dynamic>? query;
  String? url;

  @override
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool requiresAuth = false,
    ResponseType? responseType,
  }) async {
    this.url = url;
    query = queryParameters;
    final ro = RequestOptions(path: url);
    if (url.contains('seller-free-claims')) {
      // Real body (test store, 2026-11-17).
      return Response(requestOptions: ro, statusCode: 200, data: {
        'success': true,
        'data': {'claims': [], 'total': 0, 'page': 1, 'totalPages': 0},
      });
    }
    // Real body of seller-orders?tab=needs_action (test store, 2026-11-17).
    return Response(requestOptions: ro, statusCode: 200, data: {
      'success': true,
      'data': {
        'counts': {
          'needs_action': 0, 'shipped': 0, 'delivered': 0, 'completed': 0,
          'cancelled': 0, 'all': 0, 'toShip': 0, 'overdue': 0,
        },
        'stats': {'totalOrders': 0, 'revenue': 0, 'orderValue': 0, 'paidRevenue': 0, 'pending': 0, 'avgOrder': 0},
        'pagination': {'page': 1, 'limit': 10, 'totalPages': 0, 'totalOrders': 0},
        'orders': [],
      },
    });
  }
}

void main() {
  test('tabs are the API values (others -> 400 "Invalid tab")', () {
    expect(OrdersTab.values.map((t) => t.api),
        ['needs_action', 'shipped', 'delivered', 'completed', 'cancelled', 'all']);
  });

  test('seller-orders sends ?tab and reads the server counts', () async {
    final client = _Client();
    final r = await SellerOrdersRepository(client: client)
        .fetchSellerOrders(storeId: 's1', tab: 'needs_action');
    expect(client.query?['tab'], 'needs_action');
    expect(r.failed, isFalse);
    expect(r.counts['needs_action'], 0);
    expect(r.counts.containsKey('overdue'), isTrue);
  });

  test('free claims endpoint (empty live body)', () async {
    final client = _Client();
    final r = await SellerOrdersRepository(client: client).getFreeClaims('s1');
    expect(client.url, endsWith('/api/orders/seller-free-claims/s1'));
    expect(r.claims, isEmpty);
    expect(r.total, 0);
  });

  test('ship-by: server deadline, else paidAt + 48 h, only while to ship', () {
    final paid = DateTime.utc(2026, 11, 17, 8);
    SellerOrder row(Map<String, dynamic> x) => SellerOrder.fromApiJson({
          'orderId': 'o1', 'orderNumber': 'ORD-1', 'amount': 2500, 'status': 'processing',
          'isPaid': true, 'paymentType': 'card', 'type': 'physical', ...x,
        });
    expect(row({'paidAt': paid.toIso8601String()}).shipByDeadline,
        paid.add(const Duration(hours: 48)).toLocal());
    expect(row({'shipBy': '2026-11-18T08:00:00.000Z'}).shipByDeadline,
        DateTime.parse('2026-11-18T08:00:00.000Z').toLocal());
    expect(row({'paidAt': paid.toIso8601String(), 'status': 'shipped'}).shipByDeadline, isNull);
    expect(row({'paidAt': paid.toIso8601String(), 'type': 'digital'}).shipByDeadline, isNull);

    final now = DateTime(2026, 11, 17, 12);
    expect(shipByLevel(now.add(const Duration(hours: 30)), now), ShipByLevel.normal);
    expect(shipByLevel(now.add(const Duration(hours: 4)), now), ShipByLevel.soon);
    expect(shipByLevel(now.subtract(const Duration(hours: 1)), now), ShipByLevel.overdue);
  });

  test('delivered / cancelled statuses, cancel reason, gift note, buyer phone', () {
    final o = SellerOrder.fromApiJson({
      'orderId': 'o1', 'orderNumber': 'ORD-1', 'amount': 2500, 'status': 'cancelled',
      'isPaid': false, 'paymentType': 'cash_on_delivery', 'type': 'physical',
      'customer': {'name': 'Ali', 'email': 'a@x.com', 'phone': '03001234567'},
      'cancelReason': 'Ordered by mistake', 'giftMessage': 'Happy birthday',
    });
    expect(o.status, OrderStatus.cancelled);
    expect(o.cancelReason, 'Ordered by mistake');
    expect(o.giftNote, 'Happy birthday');
    expect(o.buyerPhone, '03001234567');
    expect(o.orderNumber, 'ORD-1');
    expect(SellerOrder.fromApiJson({'status': 'delivered'}).status, OrderStatus.delivered);
  });
}
