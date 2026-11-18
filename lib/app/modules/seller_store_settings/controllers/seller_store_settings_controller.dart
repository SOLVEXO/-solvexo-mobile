import 'package:book_store_app/app/data/repositories/seller_store_settings_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Store settings (checklist #15). English, seller panel. Limits are the
/// live API's: fees 0-10,000,000, dispatch 1-7 days, delivery days 0-30
/// (min <= max), return window 0-90 days, notes <= 300 characters.
class SellerStoreSettingsController extends GetxController {
  SellerStoreSettingsController({SellerStoreSettingsRepository? repository, String? storeId})
      : _repo = repository ?? SellerStoreSettingsRepository(),
        _storeIdOverride = storeId;

  final SellerStoreSettingsRepository _repo;
  final String? _storeIdOverride;
  String _storeId = '';

  final RxBool isLoading = true.obs;
  final RxBool failed = false.obs;
  final RxBool saving = false.obs;
  final RxBool dirty = false.obs;
  StoreSettings _loaded = const StoreSettings();
  String get currency => _loaded.currency;

  // Toggles / choices.
  final RxBool physical = false.obs;
  final RxBool digital = false.obs;
  final RxBool cod = true.obs;
  final RxBool deliveryFeeOn = false.obs;
  final RxBool giftWrapOn = false.obs;
  final RxBool returnsAccepted = false.obs;
  final RxnString province = RxnString();

  // Text fields.
  final deliveryFee = TextEditingController();
  final freeOver = TextEditingController();
  final giftWrapFee = TextEditingController();
  final dispatchDays = TextEditingController();
  final city = TextEditingController();
  final returnWindow = TextEditingController();
  final returnNote = TextEditingController();
  final digitalNote = TextEditingController();
  final Map<String, (TextEditingController, TextEditingController)> days = {
    for (final r in StoreSettings.routes) r: (TextEditingController(), TextEditingController()),
  };

  /// Errors per field key, shown under each field.
  final RxMap<String, String> errors = <String, String>{}.obs;

  static const provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Gilgit-Baltistan',
    'Azad Kashmir',
  ];

  static const routeLabels = {
    'sameCity': 'Own city',
    'sameProvince': 'Same province',
    'national': 'Rest of Pakistan',
  };

  List<TextEditingController> get _all => [
        deliveryFee, freeOver, giftWrapFee, dispatchDays, city, returnWindow, returnNote, digitalNote,
        for (final d in days.values) ...[d.$1, d.$2],
      ];

  @override
  void onInit() {
    super.onInit();
    for (final c in _all) {
      c.addListener(_markDirty);
    }
    load();
  }

  @override
  void onClose() {
    for (final c in _all) {
      c.dispose();
    }
    super.onClose();
  }

  void _markDirty() => dirty.value = true;
  void touch() => dirty.value = true;

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    _storeId = _storeIdOverride ?? await AppPreferences.getStoreId() ?? '';
    try {
      _apply(await _repo.load(_storeId));
    } catch (_) {
      failed.value = true;
    }
    isLoading.value = false;
  }

  String _n(num? v) => v == null ? '' : (v % 1 == 0 ? v.toInt().toString() : '$v');

  void _apply(StoreSettings s) {
    _loaded = s;
    physical.value = s.productTypes.contains('physical_products');
    digital.value = s.productTypes.contains('digital_downloads');
    cod.value = s.codEnabled;
    deliveryFeeOn.value = s.deliveryFeeOn;
    giftWrapOn.value = s.giftWrapOn;
    returnsAccepted.value = s.returnsAccepted;
    province.value = provinces.contains(s.shipFromProvince) ? s.shipFromProvince : null;
    deliveryFee.text = _n(s.deliveryFee);
    freeOver.text = _n(s.freeOverAmount);
    giftWrapFee.text = _n(s.giftWrapFee);
    dispatchDays.text = _n(s.dispatchDays);
    city.text = s.shipFromCity ?? '';
    returnWindow.text = _n(s.returnWindowDays);
    returnNote.text = s.returnNote ?? '';
    digitalNote.text = s.digitalReturnNote ?? '';
    for (final r in StoreSettings.routes) {
      days[r]!.$1.text = _n(s.deliveryDays[r]?.min);
      days[r]!.$2.text = _n(s.deliveryDays[r]?.max);
    }
    errors.clear();
    dirty.value = false;
  }

  /// Money: whole rupees for PKR, 2 decimals otherwise; 0-10,000,000.
  String? _money(String raw, {bool required = false}) {
    final t = raw.trim();
    if (t.isEmpty) return required ? 'Enter an amount.' : null;
    final v = num.tryParse(t);
    if (v == null || v < 0 || v > 10000000) return 'Enter an amount from 0 to 10,000,000.';
    if (currency.toUpperCase() == 'PKR' && v % 1 != 0) return 'Use whole rupees.';
    return null;
  }

  String? _int(String raw, int min, int max, {bool required = false}) {
    final t = raw.trim();
    if (t.isEmpty) return required ? 'Required.' : null;
    final v = int.tryParse(t);
    if (v == null || v < min || v > max) return 'Whole number from $min to $max.';
    return null;
  }

  /// Returns the settings to save, or null with [errors] filled.
  StoreSettings? validate() {
    final e = <String, String>{};
    void put(String k, String? msg) {
      if (msg != null) e[k] = msg;
    }

    if (!physical.value && !digital.value) e['types'] = 'Choose at least one.';
    if (deliveryFeeOn.value) put('deliveryFee', _money(deliveryFee.text, required: true));
    put('freeOver', _money(freeOver.text));
    if (giftWrapOn.value) put('giftWrapFee', _money(giftWrapFee.text, required: true));
    put('dispatchDays', _int(dispatchDays.text, 1, 7));
    final parsedDays = <String, DayRange>{};
    for (final r in StoreSettings.routes) {
      final (minC, maxC) = days[r]!;
      if (minC.text.trim().isEmpty && maxC.text.trim().isEmpty) continue;
      final a = _int(minC.text, 0, 30, required: true), b = _int(maxC.text, 0, 30, required: true);
      if (a != null || b != null) {
        e['days_$r'] = 'Days must be whole numbers from 0 to 30.';
      } else if (int.parse(minC.text.trim()) > int.parse(maxC.text.trim())) {
        e['days_$r'] = 'The minimum cannot be more than the maximum.';
      } else {
        parsedDays[r] = DayRange(int.parse(minC.text.trim()), int.parse(maxC.text.trim()));
      }
    }
    if (city.text.trim().length > 80) e['city'] = 'Use at most 80 characters.';
    if (returnsAccepted.value) put('returnWindow', _int(returnWindow.text, 0, 90, required: true));
    if (returnNote.text.trim().length > 300) e['returnNote'] = 'Use at most 300 characters.';
    if (digitalNote.text.trim().length > 300) e['digitalNote'] = 'Use at most 300 characters.';
    errors.assignAll(e);
    if (e.isNotEmpty) return null;

    String? s(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    return StoreSettings(
      currency: currency,
      productTypes: [if (physical.value) 'physical_products', if (digital.value) 'digital_downloads'],
      codEnabled: cod.value,
      deliveryFeeOn: deliveryFeeOn.value,
      deliveryFee: num.tryParse(deliveryFee.text.trim()),
      freeOverAmount: num.tryParse(freeOver.text.trim()),
      giftWrapOn: giftWrapOn.value,
      giftWrapFee: num.tryParse(giftWrapFee.text.trim()),
      deliveryDays: parsedDays,
      dispatchDays: int.tryParse(dispatchDays.text.trim()),
      shipFromCity: s(city),
      shipFromProvince: province.value,
      returnsAccepted: returnsAccepted.value,
      returnWindowDays: int.tryParse(returnWindow.text.trim()),
      returnNote: s(returnNote),
      digitalReturnNote: s(digitalNote),
    );
  }

  Future<bool> save() async {
    final s = validate();
    if (s == null) {
      ToastUtil.showToast('Please fix the highlighted fields.');
      return false;
    }
    saving.value = true;
    try {
      final r = await _repo.save(_storeId, s);
      if (r.ok && r.saved != null) {
        _apply(r.saved!);
        ToastUtil.showToast('Settings saved');
        return true;
      }
      ToastUtil.showToast(r.message ?? 'Could not save the settings.');
      return false;
    } finally {
      saving.value = false;
    }
  }

  void discard() => _apply(_loaded);
}
