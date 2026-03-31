class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      isActive: json['isActive'] ?? true,
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
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ProductRatings {
  final double average;
  final int count;

  ProductRatings({required this.average, required this.count});

  factory ProductRatings.fromJson(Map<String, dynamic> json) {
    return ProductRatings(
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'average': average, 'count': count};
  }
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final CategoryModel? category; // Populated category object
  final List<String> images;
  final int stock;
  final String? brand;
  final Map<String, String>? specifications;
  final List<String> tags;
  final ProductRatings ratings;
  final bool isActive;
  final bool isFeatured;
  final int? discountPercentage; // Virtual field from backend
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    this.category,
    required this.images,
    required this.stock,
    this.brand,
    this.specifications,
    required this.tags,
    required this.ratings,
    required this.isActive,
    required this.isFeatured,
    this.discountPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle category - it can be either String (ID) or Object
    String categoryId;
    CategoryModel? categoryObj;

    if (json['category'] is String) {
      categoryId = json['category'];
    } else if (json['category'] is Map<String, dynamic>) {
      categoryObj = CategoryModel.fromJson(json['category']);
      categoryId = categoryObj.id;
    } else {
      categoryId = '';
    }

    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice']).toDouble()
          : null,
      categoryId: categoryId,
      category: categoryObj,
      images: List<String>.from(json['images'] ?? []),
      stock: json['stock'] ?? 0,
      brand: json['brand'],
      specifications: json['specifications'] != null
          ? Map<String, String>.from(json['specifications'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      ratings: ProductRatings.fromJson(json['ratings'] ?? {}),
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      discountPercentage: json['discountPercentage'],
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
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'category': categoryId,
      'images': images,
      'stock': stock,
      'brand': brand,
      'specifications': specifications,
      'tags': tags,
      'ratings': ratings.toJson(),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'discountPercentage': discountPercentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get the actual price (discounted if available)
  double get actualPrice => discountPrice ?? price;

  // Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  // Check if product is in stock
  bool get inStock => stock > 0;
}

class ProductListResponse {
  final bool success;
  final int count;
  final int total;
  final int page;
  final int pages;
  final List<ProductModel> products;

  ProductListResponse({
    required this.success,
    required this.count,
    required this.total,
    required this.page,
    required this.pages,
    required this.products,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
      products: (json['data'] as List)
          .map((product) => ProductModel.fromJson(product))
          .toList(),
    );
  }
}
