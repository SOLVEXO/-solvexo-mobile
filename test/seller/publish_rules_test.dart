import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/app/modules/seller/utils/publish_rules.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _CaptureClient extends BaseClient {
  final List<dynamic> posted = [];

  @override
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    Map<String, dynamic>? headers,
  }) async {
    posted.add(data);
    return Response(
      requestOptions: RequestOptions(path: url),
      statusCode: 201,
      // Shape of the real 201 from add-digital-product (2026-11-17).
      data: {
        'success': true,
        'message': 'Digital product created successfully',
        'data': {
          'product': {'_id': 'p1', 'name': 'Grade 3 English Worksheets'},
        },
      },
    );
  }
}

void main() {
  group('class levels', () {
    test('slugs verified against the live class filter, in order', () {
      expect(kClassLevels.first.slug, 'nursery');
      expect(kClassLevels.map((c) => c.slug), containsAllInOrder(
          ['nursery', 'kg', 'prep', 'class-1', 'class-12', 'o-level', 'a-level', 'university']));
      expect(PublishRules.classLabel('class-3'), 'Class 3');
      expect(PublishRules.knownClass('class-13'), isNull);
    });
  });

  group('PublishRules.validate', () {
    test('draft needs nothing', () {
      expect(
          PublishRules.validate(
              status: 'draft', isDigital: true, coverStyle: null, classFrom: null, classTo: null),
          isNull);
    });

    test('going live needs a card style', () {
      expect(
          PublishRules.validate(
              status: 'active', isDigital: false, coverStyle: null, classFrom: null, classTo: null),
          contains('card style'));
      expect(
          PublishRules.validate(
              status: 'scheduled', isDigital: false, coverStyle: 'flat', classFrom: null, classTo: null),
          isNull,
          reason: 'class range is optional for physical');
    });

    test('digital needs a class range to publish', () {
      expect(
          PublishRules.validate(
              status: 'active', isDigital: true, coverStyle: 'book', classFrom: null, classTo: null),
          contains('class range'));
      expect(
          PublishRules.validate(
              status: 'active', isDigital: true, coverStyle: 'book', classFrom: 'class-3', classTo: 'class-5',
              hasSample: true),
          isNull);
    });

    test('digital needs a free sample to publish (#3), drafts do not', () {
      expect(
          PublishRules.validate(
              status: 'active', isDigital: true, coverStyle: 'book', classFrom: 'class-3', classTo: 'class-5'),
          contains('free sample'));
      expect(
          PublishRules.validate(
              status: 'draft', isDigital: true, coverStyle: null, classFrom: null, classTo: null),
          isNull);
      expect(
          PublishRules.validate(
              status: 'active', isDigital: false, coverStyle: 'book', classFrom: null, classTo: null),
          isNull,
          reason: 'physical needs no sample');
    });

    test('range must be complete and in order, even for drafts', () {
      // API: 400 "classFrom cannot be after classTo".
      expect(PublishRules.classRangeError('class-9', 'class-2'), isNotNull);
      expect(PublishRules.classRangeError('class-2', null), isNotNull);
      expect(
          PublishRules.validate(
              status: 'draft', isDigital: true, coverStyle: null, classFrom: 'class-9', classTo: 'class-2'),
          isNotNull);
      expect(PublishRules.classRangeError('kg', 'kg'), isNull);
    });
  });

  test('sampleFile uses the stored shape {url, name, size, mimeType}', () {
    // GET get-my-product after upload + edit (2026-11-17):
    // digital.sampleFile = {url: 'r2/private/...-sample-test.pdf',
    //   name: 'sample-test.pdf', size: 594, mimeType: 'application/pdf', pageCount: null}
    final e = DigitalFileEntry()
      ..fillFromStored({
        'url': 'r2/private/digital-products/x-sample-test.pdf',
        'name': 'sample-test.pdf',
        'size': 594,
        'mimeType': 'application/pdf',
        'pageCount': null,
      });
    expect(e.isUploaded, isTrue);
    expect(e.toSampleJson(), {
      'url': 'r2/private/digital-products/x-sample-test.pdf',
      'name': 'sample-test.pdf',
      'size': 594,
      'mimeType': 'application/pdf',
    });
    e.clear();
    expect(e.isUploaded, isFalse);
  });

  test('add-digital-product sends coverStyle and class range', () async {
    final client = _CaptureClient();
    final ok = await SellerProductRepository(client: client).addDigitalProduct(
      storeId: 's1',
      name: 'Grade 3 English Worksheets',
      price: 100,
      status: 'draft',
      coverStyle: 'book',
      classFrom: 'class-3',
      classTo: 'class-5',
      sampleFile: {'url': 'r2/private/s.pdf', 'name': 's.pdf', 'size': 1, 'mimeType': 'application/pdf'},
    );
    expect(ok, isTrue);
    final body = client.posted.single as Map;
    expect((body['digital'] as Map)['sampleFile'], containsPair('url', 'r2/private/s.pdf'));
    expect(body['coverStyle'], 'book');
    expect(body['classFrom'], 'class-3');
    expect(body['classTo'], 'class-5');
  });
}
