import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The active store's `baseCurrency` ('PKR' | 'USD'; live test store: PKR).
/// Seller prices, order amounts and store revenue are in this currency.
class StoreCurrency {
  StoreCurrency._();

  static const _key = 'store_base_currency';

  /// Empty until known.
  static final RxString code = ''.obs;

  static String get symbol => code.value.isEmpty ? '' : Money.symbol(code.value);

  /// Never guesses a currency: a plain number until the store's is known.
  static String format(num? amount) => code.value.isEmpty
      ? NumberFormat('#,##0.##', 'en_US').format(amount ?? 0)
      : Money.format(amount, code.value);

  static Future<void> set(String? currency) async {
    if (currency == null || currency.isEmpty) return;
    code.value = currency.toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code.value);
  }

  /// Cached value first, then the store itself.
  static Future<void> load({SellerRepository? repository}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_key);
    if (cached != null && cached.isNotEmpty) code.value = cached;
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) return;
    try {
      final store = await (repository ?? SellerRepository()).getStoreById(storeId);
      await set(store?.baseCurrency);
    } catch (_) {}
  }
}
