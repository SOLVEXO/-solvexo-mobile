import 'package:book_store_app/utils/price_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('price must be 0..1,000,000; 0 is a valid free resource', () {
    expect(PriceRules.validate(null), isNotNull);
    expect(PriceRules.validate(double.nan), isNotNull);
    expect(PriceRules.validate(-0.01), contains('between 0 and 1,000,000'));
    expect(PriceRules.validate(0), isNull);
    expect(PriceRules.validate(1000000), isNull);
    expect(PriceRules.validate(1000000.01), isNotNull);
  });

  test('optional compare-at price may be empty', () {
    expect(PriceRules.validateOptional(null), isNull);
    expect(PriceRules.validateOptional(2000000), isNotNull);
  });
}
