import 'package:book_store_app/app/modules/checkout/models/checkout_item_model.dart';

class CreateCheckoutResponse {
  final CheckoutSession checkout;
  final List<String> allowedPaymentMethods;
  final CheckoutSummary summary;

  /// Checkout-time upsell computed server-side: stores in this cart the buyer
  /// is NOT subscribed to whose cheapest active plan would have saved them
  /// money on this exact order.
  final List<SubscriptionSavingsHint> subscriptionSavingsHints;

  CreateCheckoutResponse({
    required this.checkout,
    required this.allowedPaymentMethods,
    required this.summary,
    this.subscriptionSavingsHints = const [],
  });

  factory CreateCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CreateCheckoutResponse(
      checkout: CheckoutSession.fromJson(json['checkout']),
      allowedPaymentMethods:
          List<String>.from(json['allowedPaymentMethods'] ?? []),
      summary: CheckoutSummary.fromJson(json['summary']),
      subscriptionSavingsHints: (json['subscriptionSavingsHints'] as List? ?? [])
          .map((e) => SubscriptionSavingsHint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Subscription upsell hint ──────────────────────────────────────────────────

class SubscriptionSavingsHint {
  final String storeId;
  final String storeName;
  final String storeSlug;
  final String planId;
  final String planName;
  final double potentialSavingsUSD;

  SubscriptionSavingsHint({
    required this.storeId,
    required this.storeName,
    required this.storeSlug,
    required this.planId,
    required this.planName,
    required this.potentialSavingsUSD,
  });

  factory SubscriptionSavingsHint.fromJson(Map<String, dynamic> json) {
    return SubscriptionSavingsHint(
      storeId: json['storeId'] as String? ?? '',
      storeName: json['storeName'] as String? ?? 'this store',
      storeSlug: json['storeSlug'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      potentialSavingsUSD: (json['potentialSavingsUSD'] ?? 0).toDouble(),
    );
  }
}

// ── Checkout session returned by the API ─────────────────────────────────────

class CheckoutSession {
  final String id;
  final String userId;
  final String? addressId;
  final String currency;
  final List<ApiCheckoutItem> items;
  final double subtotal;
  final double shippingFee;
  final double taxAmount;
  final double totalAmount;
  final String status;
  final String? expiredAt;

  CheckoutSession({
    required this.id,
    required this.userId,
    this.addressId,
    required this.currency,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    this.expiredAt,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      addressId: json['addressId'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      items: (json['items'] as List? ?? [])
          .map((e) => ApiCheckoutItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] as String? ?? 'pending',
      expiredAt: json['expiredAt'] as String?,
    );
  }
}

// ── Individual item from the API ──────────────────────────────────────────────

class ApiCheckoutItem {
  final String productId;
  final String? variantId;
  final String? sellerId;
  final String? storeId;
  final String type; // 'physical' | 'digital'
  final String name;
  final String? image;
  final String? sku;
  final String? size;
  final String? color;
  final String? licenseType;
  final int quantity;
  final double price;
  final double totalPrice;

  /// Set only when a subscriber discount was applied server-side — `price`/
  /// `totalPrice` already reflect the discounted amount, these exist for
  /// "you saved $X" display.
  final double? originalPrice;
  final double subscriberDiscountUSD;

  ApiCheckoutItem({
    required this.productId,
    this.variantId,
    this.sellerId,
    this.storeId,
    required this.type,
    required this.name,
    this.image,
    this.sku,
    this.size,
    this.color,
    this.licenseType,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.originalPrice,
    this.subscriberDiscountUSD = 0,
  });

  factory ApiCheckoutItem.fromJson(Map<String, dynamic> json) {
    return ApiCheckoutItem(
      productId: json['productId'] as String,
      variantId: json['variantId'] as String?,
      sellerId: json['sellerId'] as String?,
      storeId: json['storeId'] as String?,
      type: json['type'] as String? ?? 'physical',
      name: json['name'] as String,
      image: json['image'] as String?,
      sku: json['sku'] as String?,
      size: json['size'] as String?,
      color: json['color'] as String?,
      licenseType: json['licenseType'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      originalPrice: json['originalPrice'] != null ? (json['originalPrice'] as num).toDouble() : null,
      subscriberDiscountUSD: (json['subscriberDiscountUSD'] ?? 0).toDouble(),
    );
  }

  /// Convert to the display model used by CheckoutController / view.
  CheckoutItem toCheckoutItem() => CheckoutItem(
        id: productId,
        name: name,
        color: color,
        image: image ?? '',
        price: price,
        quantity: quantity,
        productType: type,
        originalPrice: originalPrice,
      );
}

// ── Summary block ─────────────────────────────────────────────────────────────

class CheckoutSummary {
  final double subtotal;
  final double shippingFee;
  final double taxAmount;
  final double totalAmount;

  /// Total member-benefit savings already baked into `subtotal`/`totalAmount`
  /// (line-item discounts). Display-only — never subtract it again.
  final double subscriberSavingsUSD;

  CheckoutSummary({
    required this.subtotal,
    required this.shippingFee,
    required this.taxAmount,
    required this.totalAmount,
    this.subscriberSavingsUSD = 0,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutSummary(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      subscriberSavingsUSD: (json['subscriberSavingsUSD'] ?? 0).toDouble(),
    );
  }
}
