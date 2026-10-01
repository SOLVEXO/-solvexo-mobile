import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> sub(String id, {String? mode, num? fee}) => {
      'storeId': id,
      'sellerOrderId': 'so$id',
      'fulfillmentType': 'physical',
      if (mode != null) 'fulfillmentMode': mode,
      if (fee != null) 'shippingFee': fee,
      'items': [],
    };

void main() {
  test('each sub-order keeps its own fulfillmentMode and shippingFee', () {
    final o = OrderModel.fromJson({
      'orderId': 'o1',
      'stores': [sub('a', mode: 'platform', fee: 4.5), sub('b', mode: 'seller', fee: 0)],
    });
    expect(o.stores.map((s) => s.fulfillmentMode), ['platform', 'seller']);
    expect(o.stores.map((s) => s.shippingFee), [4.5, 0]);
    expect(o.stores.first.isPlatformFulfilled, isTrue);
  });

  test('older responses default to seller-fulfilled with no shipping fee', () {
    final o = OrderModel.fromJson({'orderId': 'o1', 'stores': [sub('a')]});
    expect(o.stores.single.fulfillmentMode, 'seller');
    expect(o.stores.single.shippingFee, 0);
  });

  test('by-checkout body yields every order (digital + physical)', () {
    final orders = OrderRepository.parseOrdersByCheckout({
      'success': true,
      'data': {
        'pagination': {'page': 1},
        'orders': [
          {'orderId': 'd1', 'stores': [sub('a')]},
          {'orderId': 'p1', 'stores': [sub('b'), sub('c')]},
        ],
      },
    });
    expect(orders.map((o) => o.orderId), ['d1', 'p1']);
    expect(orders.last.stores.length, 2);
    expect(OrderRepository.parseOrdersByCheckout({'data': {}}), isEmpty);
  });
}
