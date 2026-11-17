import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/services/account_switch_prompt.dart';
import 'package:book_store_app/app/services/account_switch_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Client extends BaseClient {
  _Client(this.status, this.body);
  final int status;
  final Map<String, dynamic> body;
  final List<String> urls = [];

  @override
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    Map<String, dynamic>? headers,
  }) async {
    urls.add(url);
    if (status >= 400) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        response: Response(requestOptions: RequestOptions(path: url), statusCode: status, data: body),
        type: DioExceptionType.badResponse,
      );
    }
    return Response(requestOptions: RequestOptions(path: url), statusCode: status, data: body);
  }
}

// Real 201 of POST /api/auth/switch-to-buyer (seller session, 2026-11-17);
// tokens replaced. become-seller answers the same shape with role 'seller'.
Map<String, dynamic> _session(String role, String id, String message) => {
      'message': message,
      'success': true,
      'data': {
        'user': {'id': id, 'name': 'Test', 'email': 'test@example.com', 'role': role, 'image': null},
        'token': {'accessToken': 'acc-$role', 'refreshToken': 'ref-$role'},
      },
    };

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AppPreferences.clearTokens();
  });

  test('buyer-only API areas', () {
    expect(AccountSwitchPrompt.isBuyerOnlyPath('https://api.edudeen.com/api/checkout/gift-options'), isTrue);
    expect(AccountSwitchPrompt.isBuyerOnlyPath('/api/payment/manual-transfer/bank-details'), isTrue);
    expect(AccountSwitchPrompt.isBuyerOnlyPath('/api/cart/buy-now'), isTrue);
    expect(AccountSwitchPrompt.isBuyerOnlyPath('/api/cart/unified'), isFalse,
        reason: 'a seller session gets 200 there (verified)');
    expect(AccountSwitchPrompt.isBuyerOnlyPath('/api/orders/my-orders'), isFalse);
  });

  test('switch-to-buyer stores the returned buyer session like a login', () async {
    final client = _Client(201, _session('user', '6ae449ef097f6699bcb3dc5b', 'Buyer account ready'));
    final r = await AccountSwitchService(client: client).switchToBuyer();
    expect(r.ok, isTrue);
    expect(client.urls.single, endsWith('/api/auth/switch-to-buyer'));
    expect(await AppPreferences.getAccessTokenAsync(), 'acc-user');
    expect(await AppPreferences.getUserRole(), 'user');
  });

  test('become-seller stores the seller session', () async {
    final client = _Client(201, _session('seller', '6aba406e970ab696ea480f9b', 'Seller account ready'));
    final r = await AccountSwitchService(client: client).becomeSeller();
    expect(r.ok, isTrue);
    expect(client.urls.single, endsWith('/api/auth/become-seller'));
    expect(await AppPreferences.getUserRole(), 'seller');
  });

  test('a refusal keeps the session and returns the server message', () async {
    final client = _Client(403, {'message': 'Access Denied: Insufficient role', 'statusCode': 403});
    final r = await AccountSwitchService(client: client).switchToBuyer();
    expect(r.ok, isFalse);
    expect(r.message, 'Access Denied: Insufficient role');
    expect(await AppPreferences.getAccessTokenAsync(), isNull);
  });
}
