import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:get/get.dart';

// ─── Variant Model ────────────────────────────────────────────────────────────
class ProductVariant {
  final String id;
  final String productId;
  final String sku;
  final String? size;
  final String? color;
  final double price;
  final int? stock; // null = unlimited
  final List<String> images;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.sku,
    this.size,
    this.color,
    required this.price,
    required this.stock,
    required this.images,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // null  → unlimited; int → as-is; "∞"/"unlimited"/"Infinity" → null
  static int? _parseStock(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    final s = raw.toString().trim().toLowerCase();
    if (s.isEmpty || s == '∞' || s.startsWith('∞') ||
        s == 'unlimited' || s == 'infinity' || s == 'infinite') {
      return null;
    }
    return int.tryParse(s);
  }

  bool get isUnlimited => stock == null;
  bool get isInStock => stock == null || stock! > 0;
  // Large sentinel so qty-cap comparisons work without special-casing nulls
  int get resolvedStock => stock ?? 999999;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'] ?? json['id'] ?? '',
      productId: json['productId'] ?? '',
      sku: json['sku'] ?? '',
      size: json['size'],
      color: json['color'],
      price: (json['price'] ?? 0).toDouble(),
      stock: _parseStock(json['stock']),
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'sku': sku,
      'size': size,
      'color': color,
      'price': price,
      'stock': stock,
      'images': images,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// ─── Product Model ────────────────────────────────────────────────────────────
class ProductModel {
  final String id;
  final String name;
  final String sellerId;
  final String slug;
  final String description;
  final String categoryId;
  final CategoryModel? category;
  final List<String> images;
  final List<ProductVariant> variants;
  final String type; // 'physical' | 'digital'

  // Analytics fields
  final int viewCount;
  final int wishlistCount;
  final int purchaseCount;
  final double averageRating;
  final int totalRatings;

  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.sellerId,
    required this.slug,
    required this.description,
    required this.categoryId,
    this.category,
    required this.images,
    required this.variants,
    this.type = 'physical',
    required this.viewCount,
    required this.wishlistCount,
    required this.purchaseCount,
    required this.averageRating,
    required this.totalRatings,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // categoryId can come as a raw string or a populated object
    String categoryId;
    CategoryModel? categoryObj;

    if (json['categoryId'] is String) {
      categoryId = json['categoryId'];
    } else if (json['categoryId'] is Map<String, dynamic>) {
      categoryObj = CategoryModel.fromJson(json['categoryId']);
      categoryId = categoryObj.id;
    } else {
      categoryId = '';
    }

    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      sellerId: json['sellerId'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      categoryId: categoryId,
      category: categoryObj,
      images: List<String>.from(json['images'] ?? []),
      variants: (json['variants'] as List? ?? [])
          .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String? ?? 'physical',
      viewCount: json['viewCount'] ?? 0,
      wishlistCount: json['wishlistCount'] ?? 0,
      purchaseCount: json['purchaseCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'sellerId': sellerId,
      'slug': slug,
      'description': description,
      'categoryId': categoryId,
      'images': images,
      'variants': variants.map((v) => v.toJson()).toList(),
      'viewCount': viewCount,
      'wishlistCount': wishlistCount,
      'purchaseCount': purchaseCount,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ─── Computed helpers (derived from variants) ─────────────────────────────

  /// Cheapest variant price — shown as the "starting from" price
  double get price {
    if (variants.isEmpty) return 0.0;
    return variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  /// Most expensive variant price
  double get maxPrice {
    if (variants.isEmpty) return 0.0;
    return variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  /// True when there are multiple price points across variants
  bool get hasPriceRange => price != maxPrice;

  bool get isDigital => type.toLowerCase() == 'digital';

  /// Total stock across active variants. Returns 999999 if any variant is unlimited.
  int get stock {
    final active = variants.where((v) => v.status == 'active');
    if (active.any((v) => v.isUnlimited)) return 999999;
    return active.fold(0, (sum, v) => sum + v.stock!);
  }

  /// True when at least one active variant is in stock (or product is digital).
  bool get inStock {
    if (isDigital) return true;
    return variants.any((v) => v.status == 'active' && v.isInStock);
  }

  /// True when product and all logic is active
  bool get isActive => status == 'active';

  /// All unique colors across variants (null-safe)
  List<String> get availableColors => variants
      .where((v) => v.color != null && v.color!.isNotEmpty)
      .map((v) => v.color!)
      .toSet()
      .toList();

  /// All unique sizes across variants (null-safe)
  List<String> get availableSizes => variants
      .where((v) => v.size != null && v.size!.isNotEmpty)
      .map((v) => v.size!)
      .toSet()
      .toList();

  /// Get a specific variant by color + size (for product detail screen)
  ProductVariant? findVariant({String? color, String? size}) {
    return variants.firstWhereOrNull(
      (v) =>
          (color == null || v.color == color) &&
          (size == null || v.size == size),
    );
  }
}

// ─── Response wrapper ─────────────────────────────────────────────────────────
class ProductListResponse {
  final int total;
  final int page;
  final int pages;
  final List<ProductModel> products;

  ProductListResponse({
    required this.total,
    required this.page,
    required this.pages,
    required this.products,
  });

  /// Handles both response shapes:
  ///   • new:  { total, page, limit, products: [...] }   ← products-by-category
  ///   • old:  { success, count, total, page, pages, data: [...] }
  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    // Determine the products list key
    final rawList = (json['products'] ?? json['data'] ?? []) as List;

    // pages may not exist in the new response — derive it from total + limit
    int total = json['total'] ?? 0;
    int page = int.tryParse(json['page'].toString()) ?? 1;
    int limit = int.tryParse(json['limit'].toString()) ?? 10;
    int pages = json['pages'] ?? (limit > 0 ? (total / limit).ceil() : 1);

    return ProductListResponse(
      total: total,
      page: page,
      pages: pages,
      products: rawList
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
