import 'dart:io';

import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

// Edudeen Premium (B3). Backend 5adba44 src/premium (api/premium, role
// user). Prices always come from the server (USD + PKR per plan; the PKR
// amount to transfer is fixed by the server on subscribe).

class PremiumPlan {
  const PremiumPlan(this.raw);
  final Map raw;
  String get id => '${raw['_id']}';
  String get name => '${raw['name'] ?? ''}';
  String? get description => raw['description'] as String?;
  num? price(String interval, String currency) => raw['${interval}Price$currency'] as num?;
  num? get yearlySavingsPercent => raw['yearlySavingsPercent'] as num?;
  Map get benefits => raw['benefits'] is Map ? raw['benefits'] as Map : const {};
}

/// GET /api/premium/me -> {isPremium, entitlements, membership, coupon, pendingPayment}.
class PremiumStatus {
  const PremiumStatus(this.raw);
  final Map raw;
  bool get isPremium => raw['isPremium'] == true;
  Map get entitlements => raw['entitlements'] is Map ? raw['entitlements'] as Map : const {};
  Map? get membership => raw['membership'] is Map ? raw['membership'] as Map : null;
  Map? get coupon => raw['coupon'] is Map ? raw['coupon'] as Map : null;
  Map? get pendingPayment => raw['pendingPayment'] is Map ? raw['pendingPayment'] as Map : null;
  int get childrenLimit => (entitlements['childrenLimit'] as num?)?.toInt() ?? 8;
}

class PremiumRepository {
  PremiumRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  dynamic _data(Response r) => (r.data as Map)['data'];

  /// Public. Throws on failure.
  Future<List<PremiumPlan>> plans() async =>
      [for (final p in (_data(await _client.get(ApiConstants.premiumPlans)) as List).whereType<Map>()) PremiumPlan(p)];

  Future<PremiumStatus> me() async => PremiumStatus(_data(await _client.get(ApiConstants.premiumMe, requiresAuth: true)) as Map);

  /// Platform bank account. 400 "Bank transfer is not available right now"
  /// while the admin has not filled it in.
  Future<({Map? data, String? error})> bankDetails() async {
    try {
      return (data: _data(await _client.get(ApiConstants.premiumBankDetails, requiresAuth: true)) as Map, error: null);
    } on DioException catch (e) {
      return (data: null, error: ApiError.fromDio(e) ?? 'Bank transfer is not available right now.');
    }
  }

  /// POST subscribe {planId, interval: monthly|yearly} -> {payment, bankDetails}.
  Future<({Map? data, String? error})> subscribe(String planId, String interval) async {
    try {
      final r = await _client.post(ApiConstants.premiumSubscribe, data: {'planId': planId, 'interval': interval}, requiresAuth: true);
      return (data: _data(r) as Map, error: null);
    } on DioException catch (e) {
      return (data: null, error: ApiError.fromDio(e) ?? 'Could not start your Premium purchase.');
    }
  }

  /// POST payments/:paymentId/proof, multipart `file` (max 15 MB) +
  /// transactionReference / senderName (<= 120). Sends an Idempotency-Key
  /// per payment so a retried upload is the same request (the server also
  /// refuses a second proof once the payment is "pending").
  Future<({Map? data, String? error})> uploadProof(String paymentId, File file, {String? reference, String? senderName}) async {
    try {
      final name = file.path.split('/').last;
      final r = await _client.post(
        ApiConstants.premiumProof(paymentId),
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path, filename: name),
          if (reference != null && reference.trim().isNotEmpty) 'transactionReference': reference.trim(),
          if (senderName != null && senderName.trim().isNotEmpty) 'senderName': senderName.trim(),
        }),
        headers: {'Idempotency-Key': idempotencyKey(paymentId)},
        requiresAuth: true,
      );
      return (data: _data(r) as Map?, error: null);
    } on DioException catch (e) {
      return (data: null, error: ApiError.fromDio(e) ?? 'Could not upload your proof.');
    }
  }

  static String idempotencyKey(String paymentId) => 'premium-proof:$paymentId';

  Future<String?> cancel() => _action(ApiConstants.premiumCancel);
  Future<String?> resume() => _action(ApiConstants.premiumResume);

  /// Null = OK, else the server's message.
  Future<String?> _action(String url) async {
    try {
      await _client.post(url, requiresAuth: true);
      return null;
    } on DioException catch (e) {
      return ApiError.fromDio(e) ?? 'Something went wrong. Please try again.';
    }
  }

  /// GET /api/products/premium-deals -> {isPremium, products} (empty for
  /// non-members). Throws on failure.
  Future<List<Map>> deals({int limit = 12}) async {
    final d = _data(await _client.get(ApiConstants.premiumDeals(limit), requiresAuth: true));
    return d is Map && d['products'] is List ? (d['products'] as List).whereType<Map>().toList() : const [];
  }
}
