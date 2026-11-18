import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

// Store settings (docs 2.4, 6.13; checklist #15). Field rules are the live
// API's validation messages (2026-11-18), see the #15 commit.

class DayRange {
  const DayRange(this.min, this.max);
  final int min, max;
  static DayRange? fromJson(dynamic j) =>
      j is Map && j['min'] is num && j['max'] is num ? DayRange((j['min'] as num).toInt(), (j['max'] as num).toInt()) : null;
  Map<String, int> toJson() => {'min': min, 'max': max};
}

class StoreSettings {
  const StoreSettings({
    this.currency = '',
    this.productTypes = const [],
    this.codEnabled = true,
    this.deliveryFeeOn = false,
    this.deliveryFee,
    this.freeOverAmount,
    this.giftWrapOn = false,
    this.giftWrapFee,
    this.deliveryDays = const {},
    this.dispatchDays,
    this.shipFromCity,
    this.shipFromProvince,
    this.returnsAccepted = false,
    this.returnWindowDays,
    this.returnNote,
    this.digitalReturnNote,
  });

  final String currency;
  final List<String> productTypes; // physical_products | digital_downloads
  final bool codEnabled;
  final bool deliveryFeeOn;
  final num? deliveryFee;
  final num? freeOverAmount;
  final bool giftWrapOn;
  final num? giftWrapFee;

  /// sameCity | sameProvince | national -> {min, max} days (0-30).
  final Map<String, DayRange> deliveryDays;
  final int? dispatchDays; // 1-7
  final String? shipFromCity;
  final String? shipFromProvince;
  final bool returnsAccepted;
  final int? returnWindowDays; // 0-90
  final String? returnNote; // <= 300
  final String? digitalReturnNote; // <= 300

  static const routes = ['sameCity', 'sameProvince', 'national'];

  factory StoreSettings.fromJson(Map j) {
    Map m(String k) => j[k] is Map ? j[k] as Map : const {};
    final ds = m('deliverySettings'), gw = m('giftWrap'), dd = m('deliveryDays'), sf = m('shipFrom'), rp = m('returnPolicy');
    String? s(dynamic v) => v == null || '$v'.trim().isEmpty ? null : '$v';
    return StoreSettings(
      currency: '${j['baseCurrency'] ?? ''}',
      productTypes: (j['productTypes'] as List?)?.map((e) => '$e').toList() ?? const [],
      codEnabled: j['codEnabled'] != false,
      deliveryFeeOn: ds['enabled'] == true,
      deliveryFee: ds['fee'] as num?,
      freeOverAmount: ds['freeOverAmount'] as num?,
      giftWrapOn: gw['enabled'] == true,
      giftWrapFee: gw['fee'] as num?,
      deliveryDays: {
        for (final r in routes)
          if (DayRange.fromJson(dd[r]) != null) r: DayRange.fromJson(dd[r])!,
      },
      dispatchDays: (j['dispatchDays'] as num?)?.toInt(),
      shipFromCity: s(sf['city']),
      shipFromProvince: s(sf['province']),
      returnsAccepted: rp['returnsAccepted'] == true,
      returnWindowDays: (rp['windowDays'] as num?)?.toInt(),
      returnNote: s(rp['note']),
      digitalReturnNote: s(rp['digitalNote']),
    );
  }

  /// The update-store body. Objects are sent whole (the API replaces them).
  Map<String, dynamic> toBody(String storeId) => {
        'storeId': storeId,
        'productTypes': productTypes,
        'codEnabled': codEnabled,
        'deliverySettings': {'enabled': deliveryFeeOn, 'fee': deliveryFee ?? 0, 'freeOverAmount': freeOverAmount},
        'giftWrap': {'enabled': giftWrapOn, 'fee': giftWrapFee ?? 0},
        'deliveryDays': deliveryDays.isEmpty ? null : {for (final e in deliveryDays.entries) e.key: e.value.toJson()},
        if (dispatchDays != null) 'dispatchDays': dispatchDays,
        'shipFrom': shipFromCity == null && shipFromProvince == null
            ? null
            : {'city': shipFromCity, 'province': shipFromProvince},
        'returnPolicy': {
          'returnsAccepted': returnsAccepted,
          'windowDays': returnWindowDays ?? 0,
          'note': returnNote,
          'digitalNote': digitalReturnNote,
        },
      };
}

/// Admin shipping zone (read-only for sellers):
/// GET /api/checkout/getShippingZones -> {message, data: [zone]}.
/// Live list is empty (2026-11-18); fields from the API schema.
class ShippingZone {
  const ShippingZone({required this.country, this.province, this.city, this.price, this.estimate, this.status = ''});
  final String country;
  final String? province, city, estimate;
  final num? price;
  final String status;

  factory ShippingZone.fromJson(Map j) => ShippingZone(
        country: '${j['country'] ?? ''}',
        province: j['province']?.toString(),
        city: j['city']?.toString(),
        price: j['shippingPrice'] as num?,
        estimate: j['estimatedDeliveryTime']?.toString(),
        status: '${j['status'] ?? ''}',
      );

  String get place => [city, province, country].whereType<String>().where((s) => s.isNotEmpty).join(', ');
}

class SellerStoreSettingsRepository {
  SellerStoreSettingsRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  /// Throws on failure.
  Future<StoreSettings> load(String storeId) async {
    final res = await _client.get(ApiConstants.getStoreById(storeId), requiresAuth: true);
    return StoreSettings.fromJson((res.data as Map)['data'] as Map);
  }

  Future<({bool ok, StoreSettings? saved, String? message})> save(String storeId, StoreSettings s) async {
    try {
      final res = await _client.post(ApiConstants.updateStore, data: s.toBody(storeId), requiresAuth: true);
      final b = res.data is Map ? res.data as Map : const {};
      final ok = b['success'] == true && b['data'] is Map;
      return (ok: ok, saved: ok ? StoreSettings.fromJson(b['data'] as Map) : null, message: ApiError.msg(b['message']));
    } on DioException catch (e) {
      return (ok: false, saved: null, message: ApiError.fromDio(e) ?? 'Could not save the settings.');
    }
  }

  /// Throws on failure.
  Future<List<ShippingZone>> zones() async {
    final res = await _client.get(ApiConstants.getShippingZones, requiresAuth: true);
    final data = (res.data as Map)['data'];
    return (data is List ? data : const []).whereType<Map>().map(ShippingZone.fromJson).toList();
  }
}
