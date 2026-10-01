/// The API accepts a product / variant price from 0 to 1,000,000 inclusive;
/// 0 means a free resource (it then goes through the free-checkout path).
class PriceRules {
  PriceRules._();

  static const double min = 0;
  static const double max = 1000000;

  static bool isValid(double? price) =>
      price != null && price.isFinite && price >= min && price <= max;

  /// Null when [price] is acceptable, else a message for the seller.
  static String? validate(double? price) {
    if (price == null || !price.isFinite) return 'Please enter a valid price.';
    if (!isValid(price)) {
      return 'Price must be between 0 and 1,000,000 (0 makes it a free resource).';
    }
    return null;
  }

  /// Optional compare-at price: empty is fine, otherwise the same range.
  static String? validateOptional(double? price) =>
      price == null ? null : validate(price);
}
