/// Build-time configuration. Nothing here is secret and nothing is read from a
/// bundled file: values come from `--dart-define` (or `--dart-define-from-file`)
/// so no `.env` is shipped inside the app package.
///
///   flutter run --dart-define-from-file=config/dev.json
///
/// Keys: API_BASE_URL, WEB_BASE_URL, STRIPE_PUBLISHABLE_KEY.
/// Compile-time feature switches. Flip in ONE place to change behaviour app-wide.
class AppFeatures {
  AppFeatures._();

  /// First store release: only PHYSICAL products can be bought in the app.
  /// Digital items (courses, files, e-books, downloads) stay visible but cannot
  /// be bought, and paid seller digital services (platform plan purchase /
  /// billing, add-ons, AI credits, promotions) and Premium are switched off.
  /// Set to true to enable all of them again.
  static const bool digitalPurchases = false;

  static const String digitalUnavailableMessage =
      "This item isn't available for purchase in the app yet.";

  /// 'digital' plus the legacy 'educational' type (migrated to digital).
  static bool isDigitalType(String? type) {
    final t = (type ?? '').toLowerCase();
    return t == 'digital' || t == 'educational';
  }

  /// True when [type] is a digital item that must not be bought right now.
  static bool blocksPurchase(String? type) =>
      !digitalPurchases && isDigitalType(type);
}

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
