import 'package:intl/intl.dart';

/// One money formatter (docs Part B 2.2): USD `$12.50`, PKR `Rs 1,440`.
/// Display only — amounts always come from the server; nothing is
/// calculated here.
class Money {
  Money._();

  static String symbol(String? currency) =>
      (currency ?? '').toUpperCase() == 'PKR' ? 'Rs' : r'$';

  static String format(num? amount, String? currency) {
    final v = amount ?? 0;
    if ((currency ?? '').toUpperCase() == 'PKR') {
      // PKR prices are whole rupees; keep paisa only if the server sent them.
      return 'Rs ${NumberFormat('#,##0.##', 'en_US').format(v)}';
    }
    return '\$${NumberFormat('#,##0.00', 'en_US').format(v)}';
  }

  /// Plain USD for platform charges (plans, add-ons, promotions, invoices).
  static String usd(num? amount, {int decimals = 2}) =>
      '\$${NumberFormat(decimals == 0 ? '#,##0' : '#,##0.00', 'en_US').format(amount ?? 0)}';
}
