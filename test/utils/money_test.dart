import 'package:book_store_app/app/modules/seller/utils/store_currency.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one formatter: USD \$12.50, PKR Rs 1,440 (docs Part B 2.2)', () {
    expect(Money.format(12.5, 'USD'), r'$12.50');
    expect(Money.format(1440, 'PKR'), 'Rs 1,440');
    expect(Money.symbol('PKR'), 'Rs');
    expect(Money.symbol('USD'), r'$');
    expect(Money.usd(29, decimals: 0), r'$29');
  });

  test('store currency never guesses before it is known', () {
    StoreCurrency.code.value = '';
    expect(StoreCurrency.symbol, isEmpty);
    expect(StoreCurrency.format(100), '100');
    StoreCurrency.code.value = 'PKR'; // live test store baseCurrency
    expect(StoreCurrency.symbol, 'Rs');
    expect(StoreCurrency.format(2500), 'Rs 2,500');
    StoreCurrency.code.value = '';
  });
}
