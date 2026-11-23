import 'package:book_store_app/app/data/repositories/seller_course_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_store_settings_repository.dart';
import 'package:book_store_app/app/modules/seller_course/controllers/course_builder_controller.dart';
import 'package:book_store_app/app/modules/seller_store_settings/controllers/seller_store_settings_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// Backend fixes #2 and #3 (edudeen_api jami-branch): the server answers 400
// with a message; the app shows that message.

DioException _bad(String url, String message) {
  final ro = RequestOptions(path: url);
  return DioException(requestOptions: ro, response: Response(requestOptions: ro, statusCode: 400, data: {'message': message, 'error': 'Bad Request', 'statusCode': 400}));
}

class _CourseClient extends BaseClient {
  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async =>
      throw _bad(url, 'Invalid id');

  @override
  Future<Response> put(String url, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true}) async =>
      throw _bad(url, 'Section 1 title must be at most 120 characters');
}

class _StoreClient extends BaseClient {
  _StoreClient(this.message);
  final String message;
  @override
  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true, Map<String, dynamic>? headers}) async =>
      throw _bad(url, message);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('course builder: a load 400 keeps the server message', () async {
    final ctrl = CourseBuilderController(repository: SellerCourseRepository(client: _CourseClient()), storeId: 'bad', productId: 'p1');
    await ctrl.load();
    expect(ctrl.failed.value, isTrue);
    expect(ctrl.loadError.value, 'Invalid id');
  });

  test('course builder: a save 400 returns the server message', () async {
    final r = await SellerCourseRepository(client: _CourseClient()).save('s', 'p', CourseContent.fromJson({'sections': []}));
    expect(r.ok, isFalse);
    expect(r.message, 'Section 1 title must be at most 120 characters');
  });

  test('store settings: server 400s are put under their field', () {
    String? f(String m) => SellerStoreSettingsController.fieldForServerError(m);
    expect(f('Choose at least one product type for your store'), 'types');
    expect(f('Choose the city you ship from for this province'), 'city');
    expect(f('shipFrom.province must be one of: Sindh, Punjab'), 'province');
    expect(f('Store not found'), isNull);
  });

  test('store settings: save shows the server message under the field', () async {
    final repo = SellerStoreSettingsRepository(client: _StoreClient('shipFrom.province must be one of: Sindh, Punjab'));
    final r = await repo.save('s1', const StoreSettings(productTypes: ['digital_downloads'], shipFromCity: 'Lahore', shipFromProvince: 'Punjab'));
    expect(r.ok, isFalse);
    expect(r.message, startsWith('shipFrom.province must be one of'));
  });
}
