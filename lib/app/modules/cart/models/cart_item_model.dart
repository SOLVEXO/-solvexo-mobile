import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:flutter/material.dart';

class CartItem {
  final ProductModel product;

  // Backend-specific fields
  final String? productId; // Backend product ID
  final int? stock; // Available stock
  final double? backendPrice; // Actual price from backend
  final double? originalPrice; // Original price (for discounts)
  final String? imageUrl; // Backend image URL

  int quantity;
  int selectedVariant;
  bool isSelected;

  CartItem({
    required this.product,
    this.productId,
    required this.quantity,
    this.selectedVariant = 0,
    this.isSelected = true,
    this.stock,
    this.backendPrice,
    this.originalPrice,
    this.imageUrl,
  });

  /// Parse from backend cart item response
  factory CartItem.fromBackendJson(Map<String, dynamic> json) {
    try {
      // Parse the populated product data
      final productData = json['product'] is Map
          ? json['product'] as Map<String, dynamic>
          : null;

      // Create ProductModel from backend data
      ProductModel? product;
      if (productData != null) {
        // Parse category if it exists
        CategoryModel? category;
        if (productData['category'] != null) {
          if (productData['category'] is Map) {
            final categoryData =
                productData['category'] as Map<String, dynamic>;
            // category = CategoryModel(
            //   id: categoryData['_id'] as String,
            //   name: categoryData['name'] as String,
            //   description: categoryData['description'] as String?,
            //   image: categoryData['image'] as String?,
            //   isActive: categoryData['isActive'] as bool? ?? true,
            //   createdAt: categoryData['createdAt'] != null
            //       ? DateTime.parse(categoryData['createdAt'])
            //       : DateTime.now(),
            //   updatedAt: categoryData['updatedAt'] != null
            //       ? DateTime.parse(categoryData['updatedAt'])
            //       : DateTime.now(),
            // );
          }
        }

        // Parse ratings
        ProductRatings ratings = ProductRatings(
          average: productData['ratings'] != null
              ? (productData['ratings']['average'] as num?)?.toDouble() ?? 0.0
              : 0.0,
          count: productData['ratings'] != null
              ? productData['ratings']['count'] as int? ?? 0
              : 0,
        );

        product = ProductModel(
          id: productData['_id'] as String,
          name: productData['name'] as String,
          description: productData['description'] as String? ?? '',
          price: (productData['price'] as num).toDouble(),
          images: productData['images'] != null
              ? List<String>.from(productData['images'])
              : [],
          stock: productData['stock'] as int? ?? 0,
          brand: productData['brand'] as String?,
          isFeatured: productData['isFeatured'] as bool? ?? false,
          isActive: productData['isActive'] as bool? ?? true,
          categoryId: productData['category'] is Map
              ? (productData['category'] as Map<String, dynamic>)['_id']
                    as String
              : productData['category'] as String? ?? '',
          category: category,
          ratings: ratings,
          tags: [], // Tags not populated in cart response
          createdAt: productData['createdAt'] != null
              ? DateTime.parse(productData['createdAt'])
              : DateTime.now(),
          updatedAt: productData['updatedAt'] != null
              ? DateTime.parse(productData['updatedAt'])
              : DateTime.now(),
          discountPrice: null, // Will be set from cart item price if different
        );
      } else {
        // If product is not populated (only ID), create a minimal product
        product = ProductModel(
          id: json['product'] as String,
          name: json['name'] as String,
          description: '',
          price: (json['price'] as num).toDouble(),
          images: json['image'] != null ? [json['image'] as String] : [],
          stock: 0,
          categoryId: '',
          ratings: ProductRatings(average: 0.0, count: 0),
          tags: [],
          isFeatured: false,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      return CartItem(
        product: product,
        productId: productData?['_id'] as String? ?? json['product'] as String,
        quantity: json['quantity'] as int,
        selectedVariant: 0,
        isSelected: true,
        stock: productData?['stock'] as int?,
        backendPrice: (json['price'] as num).toDouble(),
        originalPrice: null, // Not provided by backend
        imageUrl: json['image'] as String?,
      );
    } catch (e) {
      debugPrint('❌ CartItem.fromBackendJson error: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  // ============================================================
  // ✅ BACKEND INTEGRATION - Convert to NestJS format
  // ============================================================

  /// Convert to backend format for API requests
  Map<String, dynamic> toBackendJson() {
    return {
      'product': productId ?? product.id,
      'name': product.name,
      'quantity': quantity,
      'price': backendPrice ?? product.price,
      'image':
          imageUrl ?? (product.images.isNotEmpty ? product.images.first : null),
      'brand': product.brand,
    };
  }

  // ============================================================
  // PRICE & DISCOUNT CALCULATIONS
  // ============================================================

  /// Get the actual price (backend or local)
  double get actualPrice => backendPrice ?? product.price;

  /// Check if item has discount
  bool get hasDiscount {
    if (originalPrice != null && backendPrice != null) {
      return originalPrice! > backendPrice!;
    }
    // Check if product has discount price
    if (product.discountPrice != null) {
      return product.discountPrice! < product.price;
    }
    return false;
  }

  /// Calculate discount percentage
  int get discountPercentage {
    if (!hasDiscount) return 0;

    if (originalPrice != null && backendPrice != null) {
      return (((originalPrice! - backendPrice!) / originalPrice!) * 100)
          .round();
    }

    if (product.discountPrice != null) {
      return (((product.price - product.discountPrice!) / product.price) * 100)
          .round();
    }

    return 0;
  }

  /// Calculate item total
  double get itemTotal => actualPrice * quantity;

  /// Calculate savings for this item
  double get savings {
    if (!hasDiscount) return 0.0;

    if (originalPrice != null && backendPrice != null) {
      return (originalPrice! - backendPrice!) * quantity;
    }

    if (product.discountPrice != null) {
      return (product.price - product.discountPrice!) * quantity;
    }

    return 0.0;
  }

  // ============================================================
  // IMAGE & STOCK HELPERS
  // ============================================================

  /// Get display image (backend URL or local asset)
  String get displayImage {
    // If imageUrl from backend is available, use it
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }

    // Otherwise, try to get from product images
    if (product.images.isNotEmpty) {
      return product.images.first;
    }

    // Fallback to empty string (or you can return a placeholder)
    return '';
  }

  /// Check if in stock
  bool get inStock {
    if (stock == null) return true; // Assume in stock if not specified
    return stock! > 0;
  }

  /// Check if quantity exceeds stock
  bool get exceedsStock {
    if (stock == null) return false;
    return quantity > stock!;
  }

  // ============================================================
  // LOCAL STORAGE - JSON SERIALIZATION
  // ============================================================

  /// Convert to JSON for local storage (SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId ?? product.id,
      'productName': product.name,
      'productDescription': product.description,
      'productImages': product.images,
      'productPrice': product.price,
      'productRating': product.ratings.average,
      'productRatingCount': product.ratings.count,
      'categoryId': product.categoryId,
      'categoryName': product.category?.name,
      'quantity': quantity,
      'selectedVariant': selectedVariant,
      'isSelected': isSelected,
      'stock': stock,
      'backendPrice': backendPrice,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'brand': product.brand,
      'isFeatured': product.isFeatured,
      'isActive': product.isActive,
    };
  }

  /// Create from JSON (local storage)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Create ProductRatings if available
    ProductRatings? ratings;
    if (json['productRating'] != null) {
      ratings = ProductRatings(
        average: (json['productRating'] ?? 0).toDouble(),
        count: json['productRatingCount'] ?? 0,
      );
    }

    // // Create CategoryModel if available
    // CategoryModel? category;
    // if (json['categoryName'] != null) {
    //   category = CategoryModel(
    //     id: json['categoryId'] ?? '',
    //     name: json['categoryName'],
    //     description: null,
    //     image: null,
    //     isActive: true,
    //     createdAt: DateTime.now(),
    //     updatedAt: DateTime.now(),
    //   );
    // }

    final product = ProductModel(
      id: json['productId'] ?? '',
      name: json['productName'] ?? '',
      description: json['productDescription'] ?? '',
      images: json['productImages'] != null
          ? List<String>.from(json['productImages'])
          : [AppImages.sampleProduct],
      price: (json['productPrice'] ?? 0).toDouble(),
      ratings: ratings ?? ProductRatings(average: 0.0, count: 0),
      // category: category,
      categoryId: json['categoryId'] ?? '',
      stock: json['stock'] ?? 0,
      tags: [],
      brand: json['brand'],
      isFeatured: json['isFeatured'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      discountPrice: json['backendPrice'] != null
          ? (json['backendPrice']).toDouble()
          : null,
    );

    return CartItem(
      product: product,
      productId: json['productId'],
      quantity: json['quantity'] ?? 1,
      selectedVariant: json['selectedVariant'] ?? 0,
      isSelected: json['isSelected'] ?? true,
      stock: json['stock'],
      backendPrice: json['backendPrice'] != null
          ? (json['backendPrice']).toDouble()
          : null,
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice']).toDouble()
          : null,
      imageUrl: json['imageUrl'],
    );
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Create a copy with updated values
  CartItem copyWith({
    ProductModel? product,
    String? productId,
    int? quantity,
    int? selectedVariant,
    bool? isSelected,
    int? stock,
    double? backendPrice,
    double? originalPrice,
    String? imageUrl,
  }) {
    return CartItem(
      product: product ?? this.product,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      isSelected: isSelected ?? this.isSelected,
      stock: stock ?? this.stock,
      backendPrice: backendPrice ?? this.backendPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'CartItem(productId: $productId, name: ${product.name}, qty: $quantity, price: $actualPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartItem &&
        other.productId == productId &&
        other.product.name == product.name;
  }

  @override
  int get hashCode => productId.hashCode ^ product.name.hashCode;
}
