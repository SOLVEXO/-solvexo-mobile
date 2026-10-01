import 'dart:convert';
import 'dart:typed_data';

import 'package:book_store_app/app/network/auth_refresh_interceptor.dart';
import 'package:book_store_app/app/network/token_refresher.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _Handler = Future<ResponseBody> Function(RequestOptions options);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final _Handler handler;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? body,
          Future<void>? cancel) =>
      handler(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int refreshCalls;
  late int expiredCalls;
  late Dio api;
  late TokenRefresher refresher;
  late _Handler refreshHandler;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'secure_tokens_initialised': true});
    FlutterSecureStorage.setMockInitialValues({
      'token': 'old-access',
      'refreshToken': 'old-refresh',
    });
    await AppPreferences.clearTokens();
    await AppPreferences.setTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
    );
    refreshCalls = 0;
    expiredCalls = 0;

    refreshHandler = (o) async {
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return _json(201, {
        'success': true,
        'data': {
          'token': {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
        },
      });
    };
    final refreshDio = Dio()
      ..httpClientAdapter = _FakeAdapter((o) => refreshHandler(o));
    refresher = TokenRefresher(dio: refreshDio, url: 'http://t/auth/refresh');

    api = Dio()
      ..httpClientAdapter = _FakeAdapter((o) async {
        final auth = o.headers['Authorization'];
        if (auth == 'Bearer new-access') return _json(200, {'ok': true});
        return _json(401, {'message': 'expired'});
      });
    api.interceptors.add(
      AuthRefreshInterceptor(
        dio: api,
        refresher: refresher,
        onSessionExpired: () async => expiredCalls++,
      ),
    );
  });

  Future<Response> call({String token = 'old-access'}) => api.get(
        'http://t/x',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          extra: {'requiresAuth': true},
        ),
      );

  test('401 -> refresh once -> retry succeeds and tokens are stored', () async {
    final res = await call();
    expect(res.statusCode, 200);
    expect(refreshCalls, 1);
    expect(await AppPreferences.getAccessTokenAsync(), 'new-access');
    expect(await AppPreferences.getRefreshToken(), 'new-refresh');
    expect(expiredCalls, 0);
  });

  test('concurrent 401s share one refresh and are all retried', () async {
    final results = await Future.wait([call(), call(), call()]);
    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(refreshCalls, 1);
  });

  test('a request that 401s after the token was already rotated just retries', () async {
    await call();
    expect(refreshCalls, 1);
    final res = await call(token: 'old-access'); // stale header, token rotated
    expect(res.statusCode, 200);
    expect(refreshCalls, 1);
  });

  test('refresh rejected -> session ended once, original 401 surfaces', () async {
    refreshHandler = (o) async {
      refreshCalls++;
      return _json(401, {'message': 'Session revoked, please login again'});
    };
    final calls = Future.wait([
      call().then<Object?>((_) => null).catchError((e) => e),
      call().then<Object?>((_) => null).catchError((e) => e),
    ]);
    final errors = await calls;
    expect(errors.every((e) => e is DioException), isTrue);
    expect((errors.first as DioException).response?.statusCode, 401);
    expect(refreshCalls, 1);
    expect(expiredCalls, 2); // one per waiting request; DioService de-dupes
  });

  test('refresh unreachable -> no logout, error surfaces', () async {
    refreshHandler = (o) async {
      refreshCalls++;
      return _json(503, {'message': 'down'});
    };
    await expectLater(call(), throwsA(isA<DioException>()));
    expect(expiredCalls, 0);
    expect(await AppPreferences.getRefreshToken(), 'old-refresh');
  });

  test('guest 401 (no stored token) does not refresh', () async {
    await AppPreferences.clearTokens();
    await expectLater(call(), throwsA(isA<DioException>()));
    expect(refreshCalls, 0);
    expect(expiredCalls, 0);
  });

  test('a second 401 on the retried request is not refreshed again', () async {
    refreshHandler = (o) async {
      refreshCalls++;
      return _json(201, {
        'data': {
          'token': {'accessToken': 'still-bad', 'refreshToken': 'r2'},
        },
      });
    };
    await expectLater(call(), throwsA(isA<DioException>()));
    expect(refreshCalls, 1);
  });
}
