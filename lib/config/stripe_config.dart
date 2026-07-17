import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Stripe publishable key — safe to ship in the app (not secret), read from
/// `.env` (`STRIPE_PUBLISHABLE_KEY`). Same Stripe account as the backend's
/// `STRIPE_SECRET_KEY`. Left blank until the real key is provisioned —
/// online card payments stay disabled (Cash on Delivery keeps working)
/// rather than the app crashing on a missing key.
class StripeConfig {
  static String get publishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static bool get isConfigured => publishableKey.isNotEmpty;
}
