import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_status_history.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _order({
  String status = 'pending',
  Map<String, dynamic> store = const {},
  bool isPaid = false,
  String? paidAt,
}) =>
    {
      'orderId': 'o1',
      'orderNumber': 'ORD-1',
      'orderStatus': status,
      'paymentStatus': isPaid ? 'paid' : 'unpaid',
      'paymentType': 'cash_on_delivery',
      'isPaid': isPaid,
      'paidAt': paidAt,
      'totalAmount': 2500,
      'currency': 'PKR',
      'createdAt': '2026-11-04T08:14:26.638Z',
      'stores': [
        {
          'storeId': 's1',
          'storeName': 'Uzair Book Center',
          'status': 'pending',
          // Real keys of my-orders stores[] (2026-11-17): tracking null,
          // trackingEvents [], shippedAt/deliveredAt null.
          'tracking': null,
          'trackingEvents': [],
          'shippedAt': null,
          'deliveredAt': null,
          'items': [],
          ...store,
        }
      ],
    };

void main() {
  test('nothing happened after placing -> no history (block hidden)', () {
    expect(buildOrderHistory(OrderModel.fromJson(_order())), isEmpty);
  });

  test('only real steps, in time order', () {
    final h = buildOrderHistory(OrderModel.fromJson(_order(
      isPaid: true,
      paidAt: '2026-11-04T09:00:00.000Z',
      store: {
        'status': 'delivered',
        'shippedAt': '2026-11-05T10:00:00.000Z',
        'deliveredAt': '2026-11-07T12:00:00.000Z',
        'tracking': {'carrier': 'TCS', 'trackingNumber': 'TCS123'},
      },
    )));
    expect(h.map((e) => e.title).toList(),
        ['Order placed', 'Payment confirmed', 'Shipped', 'Delivered']);
    expect(h[2].detail, 'TCS · TCS123');
  });

  test('cancelled order shows its cancel step, no invented delivery steps', () {
    final h = buildOrderHistory(OrderModel.fromJson(_order(status: 'cancelled', store: {'status': 'cancelled'})));
    expect(h.map((e) => e.title).toList(), ['Order placed', 'Order cancelled']);
  });

  test('tracking events are read when the API sends them', () {
    final h = buildOrderHistory(OrderModel.fromJson(_order(store: {
      'trackingEvents': [
        {'status': 'picked_up', 'at': '2026-11-05T09:00:00.000Z', 'location': 'Lahore'},
        {'note': 'no title -> skipped'},
      ],
    })));
    expect(h.map((e) => e.title).toList(), ['Order placed', 'Picked up']);
    expect(h[1].detail, 'Lahore');
  });
}
