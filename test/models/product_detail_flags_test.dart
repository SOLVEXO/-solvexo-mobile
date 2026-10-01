import 'package:book_store_app/app/modules/product_details/models/product_detail_response.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> body(Map<String, dynamic> extra) => {
      'success': true,
      'data': {
        'product': {'_id': 'p1', 'name': 'Worksheet', 'type': 'digital'},
        'variants': [],
        'defaultVariant': null,
        ...extra,
      },
    };

void main() {
  test('logged-in buyer: canReview and hasReviewed are read', () {
    final r = ProductDetailResponse.fromJson(
      body({'canReview': true, 'hasReviewed': false}),
    );
    expect(r.canReview, isTrue);
    expect(r.hasReviewed, isFalse);
  });

  test('without a buyer token both flags are absent (null)', () {
    final r = ProductDetailResponse.fromJson(body({}));
    expect(r.canReview, isNull);
    expect(r.hasReviewed, isNull);
  });
}
