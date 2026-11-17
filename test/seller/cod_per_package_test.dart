import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Client extends BaseClient {
  String? url;
  dynamic data;

  @override
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    this.url = url;
    this.data = data;
    return Response(requestOptions: RequestOptions(path: url), statusCode: 200, data: {'success': true});
  }
}

SellerOrder _row(Map<String, dynamic> extra) => SellerOrder.fromApiJson({
      'orderId': 'o1',
      'orderNumber': 'ORD-1',
      'amount': 2500,
      'status': 'pending',
      'isPaid': false,
      'paymentType': 'cash_on_delivery',
      'type': 'physical',
      ...extra,
    });

void main() {
  test('Mark paid only when the seller collects the cash', () {
    expect(_row({'codCollector': 'seller'}).canMarkPaid, isTrue);
    expect(_row({'codCollector': 'platform'}).canMarkPaid, isFalse);
    // Row without codCollector: follows the fulfilment (docs Part B 2.3).
    expect(_row({}).canMarkPaid, isTrue);
    expect(_row({'fulfillmentMode': 'platform'}).canMarkPaid, isFalse);
    expect(_row({'codCollector': 'seller', 'isPaid': true}).canMarkPaid, isFalse);
    expect(_row({'codCollector': 'seller', 'paymentType': 'card'}).canMarkPaid, isFalse);
  });

  test('partially_paid is shown, the package keeps its own paid state', () {
    final o = _row({'codCollector': 'seller', 'paymentStatus': 'partially_paid'});
    expect(o.isPartiallyPaid, isTrue);
    expect(o.paymentLabel, 'Unpaid (order partly paid)');
    expect(_row({'codCollector': 'platform'}).paymentLabel, 'Unpaid - Edudeen collects');
  });

  test('mark-paid sends this store id (PUT /api/orders/mark-paid/:id)', () async {
    final client = _Client();
    final ok = await SellerOrdersRepository(client: client).markOrderPaid('o1', storeId: 's1');
    expect(ok, isTrue);
    expect(client.url, endsWith('/api/orders/mark-paid/o1'));
    expect(client.data, {'storeId': 's1'});
  });

  test('buyer: partially_paid label', () {
    final o = OrderModel.fromJson({
      'orderId': 'o1',
      'orderNumber': 'ORD-1',
      'orderStatus': 'pending',
      'paymentStatus': 'partially_paid',
      'paymentType': 'cash_on_delivery',
      'totalAmount': 2500,
      'currency': 'PKR',
      'createdAt': '2026-11-04T08:14:26.638Z',
      'stores': [],
    });
    expect(o.paymentStatusDisplay, 'Partly paid');
  });
}
