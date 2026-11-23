import 'dart:async';

import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Current maintenance state as told by the API (docs §3 "Maintenance").
///
/// Sources: a 503 body `{maintenanceMode, scope, scopes, title, message,
/// endsAt}` from any call, or `GET /api/platform-config/maintenance`, whose
/// `state` is exactly 'off' | 'scheduled' | 'active' (documented by backend
/// fix #12, `MAINTENANCE_STATES`): 'off' = nothing else is sent;
/// 'scheduled' = future `startsAt`, nothing blocked (banner); 'active' =
/// blocking now for `scopes`. `endsAt` is only an estimate.
class MaintenanceState {
  const MaintenanceState({
    required this.enabled,
    required this.scopes,
    this.title,
    this.message,
    this.startsAt,
    this.endsAt,
    this.scopeMessages = const {},
    this.serverState,
  });

  /// The status endpoint's `state` ('scheduled' | 'active'), null when the
  /// value came from a 503 body.
  final String? serverState;

  final bool enabled;
  final List<String> scopes;
  final String? title;
  final String? message;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final Map<String, String> scopeMessages;

  static const off = MaintenanceState(enabled: false, scopes: []);

  /// Scheduled: banner only, nothing is blocked. The server's `state` wins;
  /// without it (503 body) a future `startsAt` means scheduled.
  bool get isScheduled => serverState != null
      ? serverState == 'scheduled'
      : startsAt != null && startsAt!.isAfter(DateTime.now());

  bool get isActive => enabled && !isScheduled;

  /// Whole buyer app is down -> full-screen page.
  bool get blocksBuyerApp =>
      isActive && (scopes.contains('all') || scopes.contains('buyer'));

  bool blocksFeature(String feature) =>
      isActive &&
      (blocksBuyerApp ||
          scopes.contains(feature) ||
          scopes.contains('feature:$feature'));

  String messageFor(String feature) =>
      scopeMessages['feature:$feature'] ??
      scopeMessages[feature] ??
      message ??
      'This part of Edudeen is being updated. Please try again soon.';

  static DateTime? _date(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

  factory MaintenanceState.fromJson(Map<String, dynamic> raw) {
    final json = raw['data'] is Map<String, dynamic>
        ? raw['data'] as Map<String, dynamic>
        : raw;
    // Status endpoint: 'off' | 'scheduled' | 'active' (backend fix #12).
    // No `state` = a 503 body (`maintenanceMode: true`).
    final state = json['state']?.toString().toLowerCase();
    final known = state == 'off' || state == 'scheduled' || state == 'active';
    final enabled = known ? state != 'off' : json['maintenanceMode'] == true || json['enabled'] == true;
    final scopes = <String>[
      if (json['scopes'] is List)
        ...(json['scopes'] as List).map((e) => e.toString()),
      if (json['scope'] is String) json['scope'] as String,
    ];
    final scopeMessages = <String, String>{};
    final sm = json['scopeMessages'];
    if (sm is Map) {
      sm.forEach((k, v) {
        final text = v is Map ? (v['message'] ?? v['title']) : v;
        if (text != null) scopeMessages[k.toString()] = text.toString();
      });
    }
    return MaintenanceState(
      enabled: enabled,
      // Enabled with no scope means everything.
      scopes: enabled && scopes.isEmpty ? const ['all'] : scopes,
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      startsAt: _date(json['startsAt']),
      endsAt: _date(json['endsAt']),
      scopeMessages: scopeMessages,
      serverState: known && state != 'off' ? state : null,
    );
  }
}

/// Holds the maintenance state for the whole app and polls while it is on so
/// the app returns by itself when the admin switches it off.
class MaintenanceService extends GetxService {
  static MaintenanceService get to => Get.isRegistered<MaintenanceService>()
      ? Get.find<MaintenanceService>()
      : Get.put(MaintenanceService(), permanent: true);

  final Rx<MaintenanceState> state = MaintenanceState.off.obs;
  final BaseClient _client = BaseClient();
  Timer? _poll;
  bool _checking = false;

  @override
  void onInit() {
    super.onInit();
    ever<MaintenanceState>(state, (s) {
      if (s.enabled) {
        _poll ??= Timer.periodic(const Duration(seconds: 60), (_) => check());
      } else {
        _poll?.cancel();
        _poll = null;
      }
    });
  }

  /// Called by the network layer for every 503 that carries maintenance data.
  void reportFrom503(Map<String, dynamic> body) {
    final next = MaintenanceState.fromJson(body);
    if (next.enabled) state.value = next;
  }

  /// Reads the public status. Errors keep the last known state.
  Future<void> check() async {
    if (_checking) return;
    _checking = true;
    try {
      final res = await _client.get(ApiConstants.maintenanceStatus);
      if (res.data is Map<String, dynamic>) {
        state.value = MaintenanceState.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Maintenance status check failed: $e');
    } finally {
      _checking = false;
    }
  }

  @override
  void onClose() {
    _poll?.cancel();
    super.onClose();
  }
}
