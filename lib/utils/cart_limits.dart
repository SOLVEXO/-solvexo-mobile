/// The API accepts a cart line quantity that is an integer from 1 to 1000
/// (`MAX_CART_LINE_QUANTITY`); anything else is a 400.
class CartLimits {
  CartLimits._();

  static const int minQuantity = 1;
  static const int maxQuantity = 1000;

  static int clamp(int quantity) => quantity.clamp(minQuantity, maxQuantity);
  static bool canDecrease(int quantity) => quantity > minQuantity;
  static bool canIncrease(int quantity) => quantity < maxQuantity;
}
