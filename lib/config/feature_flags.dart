/// Compile-time feature switches. Flip one on with
/// `--dart-define=FEATURE_BOOKINGS=true`.
class FeatureFlags {
  FeatureFlags._();

  /// Services & Bookings (seller services, buyer "My Bookings", storefront
  /// services teaser). Off: the backend (`jami-branch`) has no bookings module
  /// — every `/api/bookings/*` call would 404. The code stays in place.
  static const bool bookings = bool.fromEnvironment(
    'FEATURE_BOOKINGS',
    defaultValue: false,
  );
}
