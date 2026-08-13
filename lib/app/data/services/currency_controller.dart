import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/repositories/exchange_rate_repository.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/currency_formatter.dart';
import 'package:get/get.dart';

/// App-wide buyer display currency — backs the currency dropdown next to the
/// Home notification icon and any product price shown across the app.
/// Mirrors the backend's `SUPPORTED_CURRENCIES` (`exchange-rate.schema.ts`)
/// and its USD-pivot conversion math (`ExchangeRateService.convert`).
///
/// Selection is cached locally so it survives restarts for guests too; for
/// logged-in buyers it's also persisted server-side via the same
/// `currencyPreference` field the Edit Profile screen's currency chips write
/// (`PUT /api/users/profile`), so it stays in sync with checkout's
/// server-side member pricing.
class CurrencyController extends GetxController {
  static const List<String> supportedCurrencies = ['PKR', 'USD'];
  static const String defaultCurrency = 'PKR';

  final ExchangeRateRepository _exchangeRateRepository =
      ExchangeRateRepository();
  final AuthRepository _authRepository = AuthRepository();

  final RxString selectedCurrency = defaultCurrency.obs;
  final RxMap<String, double> rates = <String, double>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialCurrency();
    _loadRates();
  }

  Future<void> _loadInitialCurrency() async {
    final cached = await AppPreferences.getDisplayCurrency();
    if (cached != null && cached.isNotEmpty) {
      selectedCurrency.value = cached;
      return;
    }

    // No local choice yet (e.g. first run after login on a new device) —
    // fall back to whatever the buyer already picked on Edit Profile.
    if (await AppPreferences.isLoggedIn()) {
      final token = await AppPreferences.getAccessTokenAsync();
      final preference = token == null
          ? null
          : (await _authRepository.getUserProfile(token: token))
              ?.currencyPreference;
      if (preference != null && preference.isNotEmpty) {
        selectedCurrency.value = preference;
        await AppPreferences.saveDisplayCurrency(preference);
      }
    }
  }

  Future<void> _loadRates() async {
    isLoading.value = true;
    final result = await _exchangeRateRepository.getCurrentRates();
    if (result != null) rates.assignAll(result);
    isLoading.value = false;
  }

  /// Switches the display currency, caches it locally, and — for logged-in
  /// buyers — persists it server-side so checkout member pricing agrees with
  /// what's shown while browsing.
  Future<void> setCurrency(String currency) async {
    if (currency == selectedCurrency.value) return;

    selectedCurrency.value = currency;
    await AppPreferences.saveDisplayCurrency(currency);

    if (!await AppPreferences.isLoggedIn()) return;
    final token = await AppPreferences.getAccessTokenAsync();
    if (token == null) return;

    final updatedUser = await _authRepository.updateProfile(
      token: token,
      currencyPreference: currency,
    );
    if (updatedUser != null && Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      profileController.user.value = updatedUser;
      profileController.currencyPreference.value = currency;
    }
  }

  /// Converts `amount` from `fromCurrency` (the product/order's own
  /// currency) into [selectedCurrency]. Falls back to the raw amount when a
  /// rate isn't available yet rather than showing nothing.
  double convert(double amount, String? fromCurrency) {
    final from = (fromCurrency == null || fromCurrency.isEmpty)
        ? defaultCurrency
        : fromCurrency;
    final to = selectedCurrency.value;
    if (from == to) return amount;

    final fromRate = rates[from];
    final toRate = rates[to];
    if (fromRate == null || toRate == null || fromRate == 0) return amount;

    final amountInUsd = amount / fromRate;
    final converted = amountInUsd * toRate;
    return to == 'PKR'
        ? converted.roundToDouble()
        : (converted * 100).round() / 100;
  }

  /// [convert] + symbol-formatted for direct display.
  String format(double amount, String? fromCurrency, {int decimals = 2}) {
    return CurrencyFormatter.amount(
      convert(amount, fromCurrency),
      selectedCurrency.value,
      decimals: selectedCurrency.value == 'PKR' ? 0 : decimals,
    );
  }
}
