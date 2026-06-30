import 'package:flutter/material.dart';

// ─── Cart Response Model ───────────────────────────────────────────────────

class CartResponseModel {
  final String? id;
  final String userId;
  final List<CartItem> items;
  final int totalItems;
  final double totalPrice;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartResponseModel({
    this.id,
    required this.userId,
    required this.items,
    required this.totalItems,
    required this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return CartResponseModel(
        id: json['_id'] as String?,
        userId: json['userId'] as String? ?? '',
        items: (json['items'] as List? ?? [])
            .map(
              (item) => CartItem.fromBackendJson(item as Map<String, dynamic>),
            )
            .toList(),
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('❌ CartResponseModel.fromJson error: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'userId': userId,
    'items': items.map((i) => i.toBackendJson()).toList(),
    'totalItems': totalItems,
    'totalPrice': totalPrice,
    if (status != null) 'status': status,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  double get subtotal => totalPrice;
  String get formattedTotal => '\$${totalPrice.toStringAsFixed(2)}';
  bool get isEmpty => items.isEmpty;
  int get itemCount => items.length;

  double get computedTotal =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}

// ─── Cart Item ─────────────────────────────────────────────────────────────
// Handles THREE response shapes:
//
// Shape A — get-cart items:
//   { productId, productVariantId, name, unitPrice, quantity, image[] }
//
// Shape B — add-to-cart items:
//   { productId, productVariantId, name, price, quantity, images[] }
//
// Shape C — update-cart-quantity response:
//   { productId, productVariantId, name, price, quantity, images[] }
//
// All shapes are flat — no nested product object.

class CartItem {
  final String productId;
  final String productVariantId;
  final String name;
  final double price; // unitPrice (get-cart) or price (add/update)
  final int quantity;
  final List<String> images;
  final String productType; // 'physical' or 'digital'

  // UI only
  bool isSelected;

  CartItem({
    required this.productId,
    required this.productVariantId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.images,
    this.productType = 'physical',
    this.isSelected = true,
  });

  factory CartItem.fromBackendJson(Map<String, dynamic> json) {
    try {
      debugPrint('📦 CartItem.fromBackendJson: ${json.keys.toList()}');

      List<String> parseImages(dynamic raw) {
        if (raw == null) return [];
        if (raw is List) return List<String>.from(raw);
        if (raw is String && raw.isNotEmpty) return [raw];
        return [];
      }

      // price key: "price" in add-to-cart + update response
      //            "unitPrice" in get-cart response
      final rawPrice = json['price'] ?? json['unitPrice'] ?? 0;

      return CartItem(
        productId: json['productId'] as String? ?? '',
        productVariantId: json['productVariantId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        price: (rawPrice as num).toDouble(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        // images key: try every field the backend uses across all shapes
        images: parseImages(
          json['images'] ??
          json['image'] ??
          (json['product'] as Map<String, dynamic>?)?['images'] ??
          (json['product'] as Map<String, dynamic>?)?['image'] ??
          (json['productSnapshot'] as Map<String, dynamic>?)?['images'] ??
          (json['productSnapshot'] as Map<String, dynamic>?)?['image'],
        ),
        productType: (json['productType'] as String? ?? 'physical').toLowerCase(),
        isSelected: true,
      );
    } catch (e) {
      debugPrint('❌ CartItem.fromBackendJson error: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  double get actualPrice => price;
  double get itemTotal => price * quantity;
  String get displayImage => images.isNotEmpty ? images.first : '';

  Map<String, dynamic> toBackendJson() => {
    'productId': productId,
    'productVariantId': productVariantId,
    'quantity': quantity,
  };

  CartItem copyWith({
    String? productId,
    String? productVariantId,
    String? name,
    double? price,
    int? quantity,
    List<String>? images,
    String? productType,
    bool? isSelected,
  }) => CartItem(
    productId: productId ?? this.productId,
    productVariantId: productVariantId ?? this.productVariantId,
    name: name ?? this.name,
    price: price ?? this.price,
    quantity: quantity ?? this.quantity,
    images: images ?? this.images,
    productType: productType ?? this.productType,
    isSelected: isSelected ?? this.isSelected,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          other.productId == productId &&
          other.productVariantId == productVariantId;

  @override
  int get hashCode => productId.hashCode ^ productVariantId.hashCode;

  @override
  String toString() =>
      'CartItem(productId: $productId, variantId: $productVariantId, '
      'name: $name, qty: $quantity, price: $price)';
}

// ─── DTOs ──────────────────────────────────────────────────────────────────

class AddToCartDto {
  final String productId;
  final String productVariantId;
  final int quantity;

  const AddToCartDto({
    required this.productId,
    required this.productVariantId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productVariantId': productVariantId,
    'quantity': quantity,
  };
}

class UpdateCartItemDto {
  final int quantity;
  const UpdateCartItemDto({required this.quantity});
  Map<String, dynamic> toJson() => {'quantity': quantity};
}

// ─── Cart validation ───────────────────────────────────────────────────────

class CartValidationResponse {
  final bool isValid;
  final List<CartValidationError>? errors;
  final CartResponseModel? cart;

  CartValidationResponse({required this.isValid, this.errors, this.cart});

  factory CartValidationResponse.fromJson(Map<String, dynamic> json) {
    return CartValidationResponse(
      isValid: json['isValid'] as bool? ?? false,
      errors: json['errors'] != null
          ? (json['errors'] as List)
                .map(
                  (e) =>
                      CartValidationError.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      cart: json['data'] != null
          ? CartResponseModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CartValidationError {
  final String productId;
  final String name;
  final String error;
  final bool? warning;

  CartValidationError({
    required this.productId,
    required this.name,
    required this.error,
    this.warning,
  });

  factory CartValidationError.fromJson(Map<String, dynamic> json) =>
      CartValidationError(
        productId: json['productId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        error: json['error'] as String? ?? '',
        warning: json['warning'] as bool?,
      );

  bool get isWarning => warning == true;
}
