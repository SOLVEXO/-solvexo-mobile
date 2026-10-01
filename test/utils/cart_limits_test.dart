import 'package:book_store_app/app/data/repositories/cart_repository.dart';
import 'package:book_store_app/utils/cart_limits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quantity stays within 1..1000', () {
    expect(CartLimits.clamp(0), 1);
    expect(CartLimits.clamp(5), 5);
    expect(CartLimits.clamp(1001), 1000);
    expect(CartLimits.canDecrease(1), isFalse);
    expect(CartLimits.canDecrease(2), isTrue);
    expect(CartLimits.canIncrease(1000), isFalse);
    expect(CartLimits.canIncrease(999), isTrue);
  });

  test('cart badge reads data.totalItems from /cart/unified', () {
    expect(
      CartRepository.parseTotalItems({
        'success': true,
        'data': {'totalItems': 7, 'grandTotal': null},
      }),
      7,
    );
    expect(CartRepository.parseTotalItems({'data': {}}), 0);
    expect(CartRepository.parseTotalItems(null), 0);
  });
}
