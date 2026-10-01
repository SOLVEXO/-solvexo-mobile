import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/utils/otp_errors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the API error code, not the message text', () {
    expect(OtpErrors.fromCode('OTP_INVALID'), OtpFailure.invalid);
    expect(OtpErrors.fromCode('OTP_LOCKED'), OtpFailure.locked);
    expect(OtpErrors.fromCode('OTP_EXPIRED'), OtpFailure.expired);
    expect(OtpErrors.fromCode(null), OtpFailure.other);
    expect(OtpErrors.fromCode('SOMETHING_ELSE'), OtpFailure.other);
  });

  test('locked and expired are burned; invalid and other are not', () {
    expect(OtpErrors.isBurned(OtpFailure.locked), isTrue);
    expect(OtpErrors.isBurned(OtpFailure.expired), isTrue);
    expect(OtpErrors.isBurned(OtpFailure.invalid), isFalse);
    expect(OtpErrors.isBurned(null), isFalse);
  });

  test('reads code and attemptsLeft from the error body', () {
    final body = {
      'statusCode': 401,
      'message': 'Invalid OTP',
      'code': 'OTP_INVALID',
      'attemptsLeft': 3,
    };
    expect(ApiError.codeFromBody(body), 'OTP_INVALID');
    expect(ApiError.attemptsLeftFromBody(body), 3);
    expect(ApiError.attemptsLeftFromBody({'code': 'OTP_LOCKED'}), isNull);
    expect(ApiError.codeFromBody('<html>'), isNull);
  });
}
