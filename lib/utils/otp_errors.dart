/// The API reports every OTP problem as a 401 with only a text `message`, so the
/// kind of failure is read from that text.
enum OtpFailure {
  /// Wrong code; the user may try again (the server allows 5 wrong tries).
  invalid,

  /// The code can no longer be used: expired, or burned after 5 wrong tries.
  /// The user must request a new one.
  burned,

  /// Anything else (network, throttling, account state).
  other,
}

class OtpErrors {
  OtpErrors._();

  /// Wrong tries after which the server burns the code. The server answers the
  /// 5th wrong try with "Invalid OTP" too, so the client counts as well.
  static const int maxAttempts = 5;

  static OtpFailure classify(String? message) {
    final m = (message ?? '').toLowerCase();
    if (m.contains('too many wrong attempts') ||
        m.contains('expired') ||
        m.contains('request a new')) {
      return OtpFailure.burned;
    }
    if (m.contains('invalid otp')) return OtpFailure.invalid;
    return OtpFailure.other;
  }
}
