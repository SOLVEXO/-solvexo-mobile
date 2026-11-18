import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/library_repository.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Real GET /api/orders/my-library for the test buyer (2026-11-18): two rows,
// both online courses (deliveryFormat "course"; one "unavailable":"removed").
// The download rows below are made up from the same shape to cover files.
final _live = jsonDecode(File('test/fixtures/my_library.json').readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> _download(String id, {bool paid = true, String? unavailable, String paidAt = '2026-11-10T10:00:00.000Z'}) => {
      ...(_live['data']['items'] as List).first as Map<String, dynamic>,
      'orderId': 'o-$id', 'orderNumber': 'ORD-$id', 'itemId': 'i-$id', 'productId': 'p-$id',
      'name': 'Worksheets $id', 'isPaid': paid, 'paidAt': paid ? paidAt : null, 'purchasedAt': paidAt,
      'unavailable': unavailable, 'deliveryFormat': 'download', 'fileCount': 2, 'fileTypes': ['pdf'],
    };

class _Client extends BaseClient {
  _Client(this.body);
  final Object body;
  final urls = <String>[];
  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    urls.add(url);
    return Response(requestOptions: RequestOptions(path: url), statusCode: 200, data: body);
  }
}

void main() {
  test('one call to my-library; courses are left out (live rows)', () async {
    final c = _Client(_live);
    final files = await LibraryRepository(client: c).fetchFiles();
    expect(c.urls, hasLength(1));
    expect(c.urls.single, endsWith('/orders/my-library'));
    expect(files, isEmpty, reason: 'both live rows are courses');
  });

  test('download rows: paid, unpaid, removed, expired; newest first', () async {
    final body = {
      'success': true,
      'data': {
        'items': [
          ...(_live['data']['items'] as List),
          _download('a', paidAt: '2026-11-01T10:00:00.000Z'),
          _download('b', paid: false),
          _download('c', unavailable: 'removed'),
          _download('d', unavailable: 'expired', paidAt: '2026-11-12T10:00:00.000Z'),
        ],
      },
    };
    final files = await LibraryRepository(client: _Client(body)).fetchFiles();
    final byName = {for (final f in files) f.name: f};
    expect(byName.keys, ['Worksheets d', 'Worksheets b', 'Worksheets c', 'Worksheets a']);
    expect(byName['Worksheets a']!.canDownload, isTrue);
    expect(byName['Worksheets b']!.canDownload, isFalse, reason: 'not paid');
    expect(byName['Worksheets c']!.available, isFalse);
    expect(byName['Worksheets d']!.unavailable, 'expired');
    expect(byName['Worksheets a']!.key, 'o-a:i-a');
  });
}
