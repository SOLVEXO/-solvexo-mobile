import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:flutter_test/flutter_test.dart';

OrderModel order({required bool isPaid, required List<Map<String, dynamic>> items}) =>
    OrderModel.fromJson({
      'orderId': 'o1',
      'isPaid': isPaid,
      'orderStatus': 'pending',
      'stores': [
        {'storeId': 's1', 'items': items},
      ],
    });

Map<String, dynamic> item(String id, String type, String status, {bool reviewed = false}) => {
      'itemId': id,
      'productId': 'p$id',
      'type': type,
      'status': status,
      'isReviewed': reviewed,
    };

void main() {
  test('paid digital item is reviewable even though the order is not "completed"', () {
    final o = order(isPaid: true, items: [item('1', 'digital', 'pending')]);
    expect(o.canReview, isTrue);
  });

  test('unpaid digital item is not reviewable', () {
    final o = order(isPaid: false, items: [item('1', 'digital', 'pending')]);
    expect(o.canReview, isFalse);
  });

  test('refunded or cancelled digital item is not reviewable', () {
    final o = order(isPaid: true, items: [
      item('1', 'digital', 'refunded'),
      item('2', 'digital', 'cancelled'),
    ]);
    expect(o.canReview, isFalse);
  });

  test('physical item needs delivered/completed', () {
    final o = order(isPaid: true, items: [
      item('1', 'physical', 'shipped'),
      item('2', 'physical', 'delivered'),
    ]);
    expect(o.unreviewedItems.map((i) => i.itemId), ['2']);
  });

  test('already reviewed item is excluded', () {
    final o = order(isPaid: true, items: [item('1', 'digital', 'pending', reviewed: true)]);
    expect(o.canReview, isFalse);
  });
}
