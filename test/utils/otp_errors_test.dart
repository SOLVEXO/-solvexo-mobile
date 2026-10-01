import 'package:book_store_app/utils/otp_errors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies the backend OTP messages', () {
    expect(OtpErrors.classify('Invalid OTP'), OtpFailure.invalid);
    expect(
      OtpErrors.classify('Too many wrong attempts, please request a new OTP'),
      OtpFailure.burned,
    );
    expect(
      OtpErrors.classify('OTP has expired, please request a new one'),
      OtpFailure.burned,
    );
    expect(OtpErrors.classify('Too Many Requests'), OtpFailure.other);
    expect(OtpErrors.classify(null), OtpFailure.other);
  });
}
