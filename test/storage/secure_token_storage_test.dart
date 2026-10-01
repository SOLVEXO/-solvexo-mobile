import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<String?> secureRead(String key) =>
      const FlutterSecureStorage().read(key: key);

  test('upgrade: legacy SharedPreferences tokens move to secure storage', () async {
    SharedPreferences.setMockInitialValues({
      'token': 'legacy-access',
      'refreshToken': 'legacy-refresh',
    });
    FlutterSecureStorage.setMockInitialValues({});

    await AppPreferences.initSecureStorage();

    expect(await secureRead('token'), 'legacy-access');
    expect(await secureRead('refreshToken'), 'legacy-refresh');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('token'), isFalse);
    expect(prefs.containsKey('refreshToken'), isFalse);
  });

  test('fresh install: stale keychain tokens are wiped on first run', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({
      'token': 'stale-access',
      'refreshToken': 'stale-refresh',
    });

    await AppPreferences.initSecureStorage();

    expect(await secureRead('token'), isNull);
    expect(await secureRead('refreshToken'), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('secure_tokens_initialised'), isTrue);
  });

  test('initialised install keeps its tokens; clearPreference removes them', () async {
    SharedPreferences.setMockInitialValues({'secure_tokens_initialised': true});
    FlutterSecureStorage.setMockInitialValues({
      'token': 'a',
      'refreshToken': 'r',
    });

    await AppPreferences.initSecureStorage();
    expect(await secureRead('token'), 'a');

    await AppPreferences.clearPreference();
    expect(await secureRead('token'), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('secure_tokens_initialised'), isTrue);
  });
}
