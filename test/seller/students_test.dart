import 'package:book_store_app/app/data/repositories/seller_students_repository.dart';
import 'package:book_store_app/app/modules/seller_course/controllers/students_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// #14b. Real roster response for the test store (no students, 2026-11-18).
const _realEmpty = {
  'success': true,
  'data': {
    'total': 0, 'page': 1, 'limit': 25, 'totalPages': 1, 'rows': [], 'products': [],
    'stats': {'totalStudents': 0, 'avgCompletionPct': null, 'active7d': 0},
    'statusCounts': {'all': 0, 'notStarted': 0, 'inProgress': 0, 'completed': 0, 'inactive14': 0},
  },
};
const _realCsvHeader =
    '"Student","Email","Product","Type","Enrolled","Free","Progress %","Lessons done","Downloads","Last activity","Status","Access"';

class _Client extends BaseClient {
  final queries = <Map<String, dynamic>?>[];

  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    queries.add(queryParameters);
    final ro = RequestOptions(path: url);
    if (url.endsWith('/export')) return Response(requestOptions: ro, statusCode: 200, data: _realCsvHeader);
    final status = queryParameters?['status'];
    if (status != null && !['not_started', 'in_progress', 'completed', 'inactive14'].contains(status)) {
      throw DioException(requestOptions: ro, response: Response(requestOptions: ro, statusCode: 400, data: {'message': 'status is not valid'}));
    }
    return Response(requestOptions: ro, statusCode: 200, data: _realEmpty);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('real empty roster', () {
    final p = RosterPage.fromJson(_realEmpty['data'] as Map);
    expect(p.rows, isEmpty);
    expect(p.totalStudents, 0);
    expect(p.avgCompletionPct, isNull);
    expect(p.counts[StudentStatus.inactive], 0);
  });

  test('filters use the API values (verified)', () async {
    final c = _Client();
    final ctrl = StudentsController(repository: SellerStudentsRepository(client: c), storeId: 's1');
    await ctrl.load();
    expect(c.queries.last, {'sort': 'activity', 'page': 1, 'limit': 25});
    ctrl.status.value = StudentStatus.notStarted;
    ctrl.sort.value = StudentSort.enrolled;
    ctrl.productId.value = '6afc4ff81f2e13faea3e651c';
    await ctrl.load();
    expect(ctrl.failed.value, isFalse);
    expect(c.queries.last, {'status': 'not_started', 'productId': '6afc4ff81f2e13faea3e651c', 'sort': 'enrolled', 'page': 1, 'limit': 25});
    expect(StudentStatus.values.map((s) => s.api), ['all', 'not_started', 'in_progress', 'completed', 'inactive14']);
    expect(StudentSort.values.map((s) => s.api), ['activity', 'progress', 'name', 'enrolled']);
  });

  test('export returns the CSV text', () async {
    final csv = await SellerStudentsRepository(client: _Client()).exportCsv('s1');
    expect(csv, startsWith('"Student","Email"'));
  });

  test('row parsing is defensive (row shape NOT verified: no students)', () {
    final r = StudentRow.fromJson({
      'buyerId': 'b1', 'name': 'Ali', 'email': 'ali.khan@example.com', 'productName': 'Maths course',
      'progressPct': 42.4, 'status': 'in_progress', 'isFree': true, 'lastActivityAt': '2026-11-10T10:00:00Z',
    });
    expect(r.buyerId, 'b1');
    expect(r.progressPct, 42);
    expect(r.status, StudentStatus.inProgress);
    expect(r.isFree, isTrue);
    expect(StudentRow.mask(r.maskedEmail!), 'a******@example.com');
    expect(StudentRow.mask('a***@example.com'), 'a***@example.com', reason: 'already masked by the API');
    final nested = StudentRow.fromJson({'buyer': {'_id': 'b2', 'name': 'Sara'}, 'product': {'_id': 'p1', 'name': 'Urdu'}});
    expect((nested.buyerId, nested.name, nested.productId), ('b2', 'Sara', 'p1'));
  });
}
