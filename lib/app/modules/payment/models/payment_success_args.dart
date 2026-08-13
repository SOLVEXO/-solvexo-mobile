/// Arguments handed to [PaymentSuccessView] via `Get.offAllNamed(..., arguments: ...)`
/// by both the COD and Stripe checkout paths.
class PaymentSuccessArgs {
  /// One order per seller store in the checkout — a multi-seller cart
  /// produces more than one.
  final List<String> orderIds;

  /// Present only for a split (mixed digital+physical) order — the amount
  /// the courier will collect in cash for the physical items on delivery.
  final double? codAmountDue;

  /// The checkout's resolved currency (see CheckoutController.currency) —
  /// [codAmountDue] is denominated in this, not always USD.
  final String currency;

  const PaymentSuccessArgs({
    this.orderIds = const [],
    this.codAmountDue,
    this.currency = 'PKR',
  });
}
