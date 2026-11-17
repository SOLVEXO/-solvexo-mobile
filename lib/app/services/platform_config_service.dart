import 'dart:convert';

import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `GET /api/platform-config/public` (docs §3 "Platform config"): home
/// content, contact, social links, legal pages, commerce flags (COD, payment
/// methods), chatbot copy, stats thresholds.
///
/// Stale-while-revalidate: the last good answer is shown at once from disk and
/// replaced quietly when the network answers. Accessors return `null` when a
/// value is missing so callers hide the block instead of inventing content.
class PlatformConfigService extends GetxService {
  static PlatformConfigService get to =>
      Get.isRegistered<PlatformConfigService>()
          ? Get.find<PlatformConfigService>()
          : Get.put(PlatformConfigService(), permanent: true);

  static const _cacheKey = 'platform_config_public_v1';

  final RxMap<String, dynamic> config = <String, dynamic>{}.obs;
  final RxBool loaded = false.obs;
  final BaseClient _client = BaseClient();

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null && config.isEmpty) {
        final decoded = jsonDecode(cached);
        if (decoded is Map<String, dynamic>) {
          config.assignAll(decoded);
          loaded.value = true;
        }
      }
    } catch (_) {/* a bad cache is ignored */}
    await refreshConfig();
  }

  Future<void> refreshConfig() async {
    try {
      final res = await _client.get(ApiConstants.platformConfigPublic);
      final body = res.data;
      final data = body is Map<String, dynamic>
          ? (body['data'] is Map<String, dynamic> ? body['data'] : body)
          : null;
      if (data is Map<String, dynamic>) {
        config.assignAll(data);
        loaded.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(data));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Platform config refresh failed: $e');
    }
  }

  Map<String, dynamic>? _map(dynamic v) =>
      v is Map<String, dynamic> ? v : null;

  Map<String, dynamic>? get homeContent => _map(config['homeContent']);
  Map<String, dynamic>? get commerce => _map(config['commerce']);

  /// `{phone, whatsapp, address, email}`; any can be missing.
  Map<String, dynamic>? get contact => _map(homeContent?['contact']);

  Map<String, dynamic>? get socialLinks => _map(config['socialLinks']);

  bool get codAvailable => commerce?['codAvailable'] == true;

  String? _https(dynamic v) {
    final s = v?.toString() ?? '';
    return s.startsWith('https://') ? s : null;
  }

  String? get googlePlayUrl => _https(homeContent?['googlePlayUrl']);
  String? get appStoreUrl => _https(homeContent?['appStoreUrl']);
}
