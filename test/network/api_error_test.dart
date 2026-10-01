import 'package:book_store_app/app/network/api_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiError.msg', () {
    test('string passes through', () => expect(ApiError.msg('Nope'), 'Nope'));
    test('list of strings is joined on new lines', () {
      expect(
        ApiError.msg([
          'Password must be at least 8 characters',
          'email must be an email',
        ]),
        'Password must be at least 8 characters\nemail must be an email',
      );
    });
    test('null, empty string and empty list give null', () {
      expect(ApiError.msg(null), isNull);
      expect(ApiError.msg('  '), isNull);
      expect(ApiError.msg(<String>[]), isNull);
    });
  });

  group('ApiError.fromDio / fromBody', () {
    DioException err(dynamic data) => DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 400,
            data: data,
          ),
        );

    test('reads a list message from a ValidationPipe body', () {
      expect(
        ApiError.fromDio(err({'statusCode': 400, 'message': ['a', 'b']})),
        'a\nb',
      );
    });
    test('non-map body gives null', () {
      expect(ApiError.fromDio(err('<html>')), isNull);
      expect(ApiError.fromBody(null), isNull);
    });
  });
}
