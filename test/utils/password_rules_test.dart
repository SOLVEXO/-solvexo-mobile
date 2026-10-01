import 'package:book_store_app/utils/password_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new password must be 8-72 characters', () {
    expect(PasswordRules.validateNew(null), isNotNull);
    expect(PasswordRules.validateNew(''), isNotNull);
    expect(PasswordRules.validateNew('1234567'), contains('at least 8'));
    expect(PasswordRules.validateNew('12345678'), isNull);
    expect(PasswordRules.validateNew('a' * 72), isNull);
    expect(PasswordRules.validateNew('a' * 73), contains('at most 72'));
  });
}
