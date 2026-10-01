import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum RefreshOutcome {
  /// New token pair obtained and stored.
  refreshed,

  /// The server refused the refresh token (expired, revoked by a password
  /// reset / suspension, account inactive) or there is none — the session is over.
  rejected,

  /// Could not reach the server or got an unexpected reply — keep the session
  /// and let the original error surface.
  unavailable,
}

/// `POST /api/auth/refresh` with single-flight semantics: any number of
/// requests that hit a 401 at the same time share one refresh call.
class TokenRefresher {
  TokenRefresher({Dio? dio, String? url})
      : _dio = dio ?? _defaultDio(),
        _url = url ?? ApiConstants.refreshToken;

  static final TokenRefresher instance = TokenRefresher();

  final Dio _dio;
  final String _url;
  Future<RefreshOutcome>? _inflight;

  // No interceptors: a 401 from the refresh call itself must never recurse.
  static Dio _defaultDio() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/json'},
        ),
      );

  Future<RefreshOutcome> refresh() {
    final running = _inflight;
    if (running != null) return running;
    final future = _run().whenComplete(() => _inflight = null);
    _inflight = future;
    return future;
  }

  Future<RefreshOutcome> _run() async {
    final refreshToken = await AppPreferences.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return RefreshOutcome.rejected;
    }
    try {
      final response = await _dio.post(
        _url,
        data: {'refreshToken': refreshToken},
        options: Options(contentType: 'application/json'),
      );
      final token = (response.data is Map ? response.data['data'] : null);
      final pair = token is Map ? token['token'] : null;
      if (pair is Map &&
          pair['accessToken'] is String &&
          pair['refreshToken'] is String) {
        await AppPreferences.setTokens(
          accessToken: pair['accessToken'] as String,
          refreshToken: pair['refreshToken'] as String,
        );
        return RefreshOutcome.refreshed;
      }
      return RefreshOutcome.unavailable;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      debugPrint('Token refresh failed: $code');
      if (code == 400 || code == 401 || code == 403) {
        return RefreshOutcome.rejected;
      }
      return RefreshOutcome.unavailable;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return RefreshOutcome.unavailable;
    }
  }
}
