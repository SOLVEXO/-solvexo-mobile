/// Server-side rule for NEW passwords (register, reset, change): 8–72
/// characters. Login deliberately does not use this — existing accounts keep
/// working with whatever password they already have.
class PasswordRules {
  PasswordRules._();

  static const int minLength = 8;
  static const int maxLength = 72;

  static String? validateNew(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return 'Password must be at most $maxLength characters';
    }
    return null;
  }
}
