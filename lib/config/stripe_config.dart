import 'package:book_store_app/config/app_config.dart';

/// Stripe publishable key from `--dart-define=STRIPE_PUBLISHABLE_KEY=...`.
/// Blank = card payments stay hidden (COD / bank transfer keep working).
/// Cards are USD-only (docs §2.2).
class StripeConfig {
  static String get publishableKey => AppConfig.stripePublishableKey;
  static bool get isConfigured => publishableKey.isNotEmpty;
}
