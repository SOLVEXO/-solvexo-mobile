/// Build-time configuration. Nothing here is secret and nothing is read from a
/// bundled file: values come from `--dart-define` (or `--dart-define-from-file`)
/// so no `.env` is shipped inside the app package.
///
///   flutter run --dart-define-from-file=config/dev.json
///
/// Keys: API_BASE_URL, WEB_BASE_URL, STRIPE_PUBLISHABLE_KEY, FACEBOOK_APP_ID.
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

  /// Facebook app id (public). Empty = the "Facebook" sign-in button is
  /// hidden. The native SDK also needs the id (and client token) in iOS
  /// Info.plist / Android strings before Facebook login can work.
  static const String facebookAppId = String.fromEnvironment('FACEBOOK_APP_ID');
  static bool get facebookLoginEnabled => facebookAppId.trim().isNotEmpty;

  static String web(String path) =>
      '$webBaseUrl${path.startsWith('/') ? path : '/$path'}';

  static String get becomeSellerUrl => web('/become-a-seller');
  static String get deleteAccountUrl => web('/delete-account');
  static String get privacyUrl => web('/privacy');
  static String get termsUrl => web('/terms');
}
