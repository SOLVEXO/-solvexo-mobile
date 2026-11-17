/// Build-time configuration. Nothing here is secret and nothing is read from a
/// bundled file: values come from `--dart-define` (or `--dart-define-from-file`)
/// so no `.env` is shipped inside the app package.
///
///   flutter run --dart-define-from-file=config/dev.json
///
/// Keys: API_BASE_URL, WEB_BASE_URL, STRIPE_PUBLISHABLE_KEY.
class AppConfig {
  AppConfig._();

  /// Public web site (legal pages, become-a-seller, account deletion).
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://edudeen.com',
  );

  /// Stripe *publishable* key (safe to ship). Empty = card payments hidden.
  static const String stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static String web(String path) =>
      '$webBaseUrl${path.startsWith('/') ? path : '/$path'}';

  static String get becomeSellerUrl => web('/become-a-seller');
  static String get deleteAccountUrl => web('/delete-account');
  static String get privacyUrl => web('/privacy');
  static String get termsUrl => web('/terms');
}
