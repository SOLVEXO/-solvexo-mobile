import 'package:book_store_app/app/network/token_refresher.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';

/// On a 401 for a request that carried a session token: refresh once, retry the
/// request with the new token, and end the session if the server refuses the
/// refresh. Concurrent 401s share a single refresh (see [TokenRefresher]).
class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor({
    required Dio dio,
    required TokenRefresher refresher,
    required Future<void> Function() onSessionExpired,
  })  : _dio = dio,
        _refresher = refresher,
        _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final TokenRefresher _refresher;
  final Future<void> Function() _onSessionExpired;

  static const retriedKey = 'authRetried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final requiresAuth = options.extra['requiresAuth'] == true;
    if (err.response?.statusCode != 401 ||
        !requiresAuth ||
        options.extra[retriedKey] == true) {
      return handler.next(err);
    }

    final current = await AppPreferences.getAccessTokenAsync();
    if (current == null || current.isEmpty) {
      // Guest: there is no session to refresh or end.
      return handler.next(err);
    }

    // Another request may already have rotated the token while this one was
    // in flight; then just retry with the new one.
    var token = current;
    if (options.headers['Authorization'] == 'Bearer $current') {
      final outcome = await _refresher.refresh();
      if (outcome == RefreshOutcome.rejected) {
        await _onSessionExpired();
        return handler.next(err);
      }
      if (outcome == RefreshOutcome.unavailable) {
        return handler.next(err);
      }
      token = await AppPreferences.getAccessTokenAsync() ?? current;
    }

    try {
      final retry = options.copyWith(
        headers: {...options.headers, 'Authorization': 'Bearer $token'},
        extra: {...options.extra, retriedKey: true},
        // A FormData body is single-use once it has been sent.
        data: options.data is FormData
            ? (options.data as FormData).clone()
            : options.data,
      );
      handler.resolve(await _dio.fetch(retry));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
