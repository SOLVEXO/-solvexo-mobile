import 'package:book_store_app/app/services/error_monitoring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test('off without SENTRY_DSN: the app runs, nothing is started', () async {
    expect(ErrorMonitoring.enabled, isFalse);
    var ran = false;
    await ErrorMonitoring.run(() => ran = true);
    expect(ran, isTrue);
    expect(Sentry.isEnabled, isFalse);
  });

  test('scrubs emails, phones, tokens and secret query params', () {
    final s = ErrorMonitoring.scrub(
        'user sidd@example.com +92 317 2040161 Bearer abc.def eyJhbGciOi.eyJzdWIi.sig /x?token=123&page=2');
    expect(s, isNot(contains('example.com')));
    expect(s, isNot(contains('2040161')));
    expect(s, isNot(contains('abc.def')));
    expect(s, isNot(contains('eyJhbGciOi')));
    expect(s, contains('token=[redacted]'));
    expect(s, contains('page=2'));
  });

  test('breadcrumbs: console + UI dropped; http keeps method/status, url without query', () {
    final h = Hint();
    expect(ErrorMonitoring.scrubBreadcrumb(Breadcrumb(category: 'console', message: 'x'), h), isNull);
    final b = ErrorMonitoring.scrubBreadcrumb(
      Breadcrumb(category: 'http', type: 'http', data: {
        'url': 'https://api.edudeen.com/api/orders/download-zip-file?token=secret',
        'method': 'GET',
        'status_code': 200,
        'request_body': '{"email":"a@b.co"}',
      }),
      h,
    )!;
    expect(b.data, {'url': 'https://api.edudeen.com/api/orders/download-zip-file', 'method': 'GET', 'status_code': 200});
  });
}
