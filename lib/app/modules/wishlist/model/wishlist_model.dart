import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:flutter/material.dart';

class WishlistEntry {
  final String id;
  final String userId;
  final String productId;
  final String productVariantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WishlistEntry({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productVariantId,
    this.createdAt,
    this.updatedAt,
  });

  factory WishlistEntry.fromJson(Map<String, dynamic> json) {
    return WishlistEntry(
      id: json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productVariantId: json['productVariantId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'productId': productId,
    'productVariantId': productVariantId,
  };
}

class WishlistItem {
  final WishlistEntry? wishlistEntry; // present in add/get-item responses
  final ProductModel product;
  final List<ProductVariant> variants;
  final ProductVariant? selectedVariant; // present in add/get-item responses

  WishlistItem({
    this.wishlistEntry,
    required this.product,
    required this.variants,
    this.selectedVariant,
  });

  factory WishlistItem.fromListJson(Map<String, dynamic> json) {
    try {
      final productJson = json['product'] as Map<String, dynamic>? ?? {};
      final variantsList = (json['variants'] as List? ?? [])
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList();

      // Merge variants into product JSON so computed getters work
      final mergedProduct = ProductModel.fromJson({
        ...productJson,
        'variants': json['variants'] ?? [],
      });

      return WishlistItem(product: mergedProduct, variants: variantsList);
    } catch (e) {
      debugPrint('❌ WishlistItem.fromListJson error: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  // ── Parse from add-to-wishlist / get-wishlist-item responses ───────────
  // Shape: { wishlist: {...}, product: {...}, variant: {...} }

  factory WishlistItem.fromDetailJson(Map<String, dynamic> json) {
    try {
      final productJson = json['product'] as Map<String, dynamic>? ?? {};
      final variantJson = json['variant'] as Map<String, dynamic>?;
      final wishlistJson = json['wishlist'] as Map<String, dynamic>?;

      final variant = variantJson != null
          ? ProductVariant.fromJson(variantJson)
          : null;

      final mergedProduct = ProductModel.fromJson({
        ...productJson,
        'variants': variantJson != null ? [variantJson] : [],
      });

      return WishlistItem(
        wishlistEntry: wishlistJson != null
            ? WishlistEntry.fromJson(wishlistJson)
            : null,
        product: mergedProduct,
        variants: variant != null ? [variant] : [],
        selectedVariant: variant,
      );
    } catch (e) {
      debugPrint('❌ WishlistItem.fromDetailJson error: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Price from selected/first variant
  double get price =>
      selectedVariant?.price ??
      (variants.isNotEmpty ? variants.first.price : product.price);

  /// Display image from selected/first variant or product
  String get displayImage {
    final imgs =
        selectedVariant?.images ??
        (variants.isNotEmpty ? variants.first.images : []);
    if (imgs.isNotEmpty) return imgs.first;
    if (product.images.isNotEmpty) return product.images.first;
    return '';
  }

  /// Wishlist entry ID used for remove
  String? get wishlistId => wishlistEntry?.id;
}

// ─── DTOs ──────────────────────────────────────────────────────────────────

class AddToWishlistDto {
  final String productId;
  final String productVariantId;

  const AddToWishlistDto({
    required this.productId,
    required this.productVariantId,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productVariantId': productVariantId,
  };
}

class RemoveFromWishlistDto {
  final String wishlistId;
  const RemoveFromWishlistDto({required this.wishlistId});
  Map<String, dynamic> toJson() => {'wishlistId': wishlistId};
}
