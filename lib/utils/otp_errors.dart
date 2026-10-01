/// OTP failures come back as 401 with a machine-readable `code` in the body
/// (and `attemptsLeft` on `OTP_INVALID`) — never match on the message text.
enum OtpFailure {
  /// `OTP_INVALID`: wrong code; the user may try again.
  invalid,

  /// `OTP_LOCKED`: the code was burned by too many wrong tries (this response
  /// is also the one for the attempt that burned it).
  locked,

  /// `OTP_EXPIRED`: no code was issued, or it is past its time.
  expired,

  /// Anything else (network, throttling, account state).
  other,
}

class OtpErrors {
  OtpErrors._();

  static OtpFailure fromCode(String? code) {
    switch (code) {
      case 'OTP_INVALID':
        return OtpFailure.invalid;
      case 'OTP_LOCKED':
        return OtpFailure.locked;
      case 'OTP_EXPIRED':
        return OtpFailure.expired;
      default:
        return OtpFailure.other;
    }
  }

  /// The code can no longer be used; the user must request a new one.
  static bool isBurned(OtpFailure? failure) =>
      failure == OtpFailure.locked || failure == OtpFailure.expired;
}
