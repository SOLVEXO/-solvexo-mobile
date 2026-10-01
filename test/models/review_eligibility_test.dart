import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:flutter_test/flutter_test.dart';

OrderModel order(List<Map<String, dynamic>> items) => OrderModel.fromJson({
      'orderId': 'o1',
      'orderStatus': 'pending',
      'stores': [
        {'storeId': 's1', 'items': items},
      ],
    });

Map<String, dynamic> item(String id, {bool? canReview, bool reviewed = false}) => {
      'itemId': id,
      'productId': 'p$id',
      'isReviewed': reviewed,
      if (canReview != null) 'canReview': canReview,
    };

void main() {
  test('offers Review only for lines the server marked canReview', () {
    final o = order([item('1', canReview: true), item('2', canReview: false)]);
    expect(o.unreviewedItems.map((i) => i.itemId), ['1']);
    expect(o.canReview, isTrue);
  });

  test('a line without the flag is not reviewable', () {
    expect(order([item('1')]).canReview, isFalse);
  });

  test('an already reviewed line is excluded even if canReview is true', () {
    expect(order([item('1', canReview: true, reviewed: true)]).canReview, isFalse);
  });
}
