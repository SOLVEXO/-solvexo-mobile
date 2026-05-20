import 'package:book_store_app/app/modules/category/models/product_model.dart';

// ─── Response model for GET /api/products/getProductById/:id ──────────────
// data: { product, variants[], defaultVariant }

class ProductDetailResponse {
  final ProductModel product;
  final List<ProductVariant> variants;
  final ProductVariant? defaultVariant;

  ProductDetailResponse({
    required this.product,
    required this.variants,
    this.defaultVariant,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    // Parse core product — inject variants from the sibling key
    final productJson = data['product'] as Map<String, dynamic>;
    final variantsList = (data['variants'] as List? ?? [])
        .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
        .toList();

    // Merge variants into the productJson so ProductModel.fromJson gets them
    final mergedProductJson = {
      ...productJson,
      'variants': data['variants'] ?? [],
    };

    final product = ProductModel.fromJson(mergedProductJson);

    // Default variant
    ProductVariant? defaultVariant;
    if (data['defaultVariant'] != null) {
      defaultVariant = ProductVariant.fromJson(
        data['defaultVariant'] as Map<String, dynamic>,
      );
    }

    return ProductDetailResponse(
      product: product,
      variants: variantsList,
      defaultVariant: defaultVariant,
    );
  }
}

// ─── Response model for GET /api/products/getVariantById/:id ─────────────
// data: { variant, product }

class VariantDetailResponse {
  final ProductVariant variant;
  final ProductModel product;

  VariantDetailResponse({required this.variant, required this.product});

  factory VariantDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    final variant = ProductVariant.fromJson(
      data['variant'] as Map<String, dynamic>,
    );

    // Product comes without variants array in this endpoint —
    // wrap the single variant so computed getters work correctly
    final productJson = {
      ...(data['product'] as Map<String, dynamic>),
      'variants': [data['variant']],
    };
    final product = ProductModel.fromJson(productJson);

    return VariantDetailResponse(variant: variant, product: product);
  }
}
