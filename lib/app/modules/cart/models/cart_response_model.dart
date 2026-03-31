import 'package:book_store_app/app/modules/cart/models/cart_item_model.dart';
import 'package:flutter/material.dart';

class CartResponseModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final int totalItems;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartResponseModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalItems,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return CartResponseModel(
        id: json['_id'] as String,
        userId: json['user'] is String
            ? json['user'] as String
            : (json['user'] as Map<String, dynamic>)['_id'] as String,
        items: (json['items'] as List)
            .map((item) => CartItem.fromBackendJson(item))
            .toList(),
        totalItems: json['totalItems'] as int,
        totalPrice: (json['totalPrice'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
    } catch (e) {
      debugPrint('❌ CartResponseModel parsing error: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'items': items.map((item) => item.toBackendJson()).toList(),
      'totalItems': totalItems,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  double get subtotal => totalPrice;

  String get formattedTotal => '\$${totalPrice.toStringAsFixed(2)}';

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.length;
}

// DTO for adding to cart
class AddToCartDto {
  final String productId;
  final int quantity;

  AddToCartDto({required this.productId, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }
}

// DTO for updating cart item
class UpdateCartItemDto {
  final int quantity;

  UpdateCartItemDto({required this.quantity});

  Map<String, dynamic> toJson() {
    return {'quantity': quantity};
  }
}

// Cart validation response
class CartValidationResponse {
  final bool isValid;
  final List<CartValidationError>? errors;
  final CartResponseModel? cart;

  CartValidationResponse({required this.isValid, this.errors, this.cart});

  factory CartValidationResponse.fromJson(Map<String, dynamic> json) {
    return CartValidationResponse(
      isValid: json['isValid'] as bool,
      errors: json['errors'] != null
          ? (json['errors'] as List)
                .map((e) => CartValidationError.fromJson(e))
                .toList()
          : null,
      cart: json['data'] != null
          ? CartResponseModel.fromJson(json['data'])
          : null,
    );
  }
}

// Validation error model
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

  factory CartValidationError.fromJson(Map<String, dynamic> json) {
    return CartValidationError(
      productId: json['productId'] as String,
      name: json['name'] as String,
      error: json['error'] as String,
      warning: json['warning'] as bool?,
    );
  }

  bool get isWarning => warning == true;
}
