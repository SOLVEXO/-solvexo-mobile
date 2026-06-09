import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/data/repositories/cart_repository.dart';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/config/resources/app_sounds.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final CartRepository _cartRepository = CartRepository();

  // ─── Arguments ────────────────────────────────────────────────────────────
  late final String productId;

  // ─── State ────────────────────────────────────────────────────────────────
  final Rx<ProductModel?> product = Rx<ProductModel?>(null);
  final RxList<ProductVariant> variants = <ProductVariant>[].obs;
  final Rx<ProductVariant?> selectedVariant = Rx<ProductVariant?>(null);
  final Rx<ProductVariant?> defaultVariant = Rx<ProductVariant?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isAddtoCartLoading = false.obs;
  final RxBool isLoadingVariant = false.obs;

  // ─── Quantity ─────────────────────────────────────────────────────────────
  final RxInt productQty = 1.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    fetchProductDetails();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      productId = args['productId'] as String? ?? '';
    } else if (args is String) {
      productId = args;
    } else {
      productId = '';
    }
    debugPrint('🛍️ ProductDetailController — productId: $productId');
  }

  // ─── 1. Fetch product + all variants ─────────────────────────────────────

  Future<void> fetchProductDetails() async {
    if (productId.isEmpty) {
      ToastUtil.showToast('Invalid product');
      return;
    }

    isLoading.value = true;

    try {
      final response = await _productRepository.getProductDetailById(productId);

      if (response != null) {
        product.value = response.product;
        variants.assignAll(response.variants);

        // Select default variant; fall back to first variant if none
        final def =
            response.defaultVariant ??
            (response.variants.isNotEmpty ? response.variants.first : null);
        selectedVariant.value = def;
        defaultVariant.value = def;

        // Reset quantity
        productQty.value = 1;

        debugPrint(
          '✅ Loaded product: ${response.product.name} '
          'with ${response.variants.length} variants',
        );
      } else {
        ToastUtil.showToast('Product not found');
        Get.back();
      }
    } catch (e) {
      debugPrint('❌ Error loading product details: $e');
      ToastUtil.showToast('Failed to load product details');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 2. Fetch variant by ID (when user taps a specific variant) ───────────

  Future<void> fetchVariantById(String variantId) async {
    isLoadingVariant.value = true;
    try {
      final response = await _productRepository.getVariantById(variantId);
      if (response != null) {
        selectedVariant.value = response.variant;
        // Reset qty so it doesn't exceed new variant stock
        if (productQty.value > response.variant.stock) {
          productQty.value = 1;
        }
        debugPrint('✅ Loaded variant: ${response.variant.sku}');
      }
    } catch (e) {
      debugPrint('❌ Error loading variant: $e');
      ToastUtil.showToast('Failed to load variant');
    } finally {
      isLoadingVariant.value = false;
    }
  }

  // ─── 3. Select variant from the chip list ────────────────────────────────
  // Immediately updates selectedVariant from the already-loaded list.
  // Also triggers fetchVariantById to get the most up-to-date stock/price.

  void selectVariant(ProductVariant variant) {
    selectedVariant.value = variant;
    productQty.value = 1;
    fetchVariantById(variant.id); // refresh from API
  }

  // ─── 4. Quantity controls ─────────────────────────────────────────────────

  void increaseQty() {
    final maxStock = selectedVariant.value?.stock ?? product.value?.stock ?? 0;
    if (productQty.value < maxStock) {
      productQty.value++;
    } else {
      ToastUtil.showToast('Maximum stock reached');
    }
  }

  void decreaseQty() {
    if (productQty.value > 1) productQty.value--;
  }

  // ─── 5. Add to cart ───────────────────────────────────────────────────────

  Future<void> addToCart() async {
    final p = product.value;
    if (p == null) {
      ToastUtil.showToast('Product not available');
      return;
    }

    final variant = selectedVariant.value;
    final stockAvailable = variant?.stock ?? p.stock;

    if (stockAvailable == 0) {
      ToastUtil.showToast('Product is out of stock');
      return;
    }

    if (productQty.value > stockAvailable) {
      ToastUtil.showToast('Not enough stock available');
      return;
    }
    if (variant!.id.isEmpty) {
      ToastUtil.showToast('Please select a variant first');
      return;
    }
    try {
      isAddtoCartLoading.value = true;
      final cart = await _cartRepository.addToCart(
        productId: p.id,
        productVariantId: variant.id,
        quantity: productQty.value,
      );
      final cartController = Get.find<CartController>();
      cartController.addToCartBackend(cart: cart);

      CustomAppSnackbar.show(
        soundPath: AppSounds.successSound,
        title: 'Added to Cart',
        message: '${p.name} (x$productQty.value)',
      );
      ToastUtil.showToast('${p.name} added to cart');
      debugPrint(
        '🛒 Added to cart: ${p.name} x${productQty.value} '
        '(variant: ${variant.sku})',
      );
      isAddtoCartLoading.value = false;
    } catch (e) {
      ToastUtil.showToast('Failed to add to cart');
    } finally {
      isAddtoCartLoading.value = false;
    }
  }

  // ─── Computed helpers ─────────────────────────────────────────────────────

  /// Price from selected variant, fallback to product computed price
  double get displayPrice =>
      selectedVariant.value?.price ?? product.value?.price ?? 0.0;

  /// Stock from selected variant, fallback to product total stock
  int get displayStock =>
      selectedVariant.value?.stock ?? product.value?.stock ?? 0;

  bool get inStock => displayStock > 0;

  /// Images: selected variant images first, then product images
  List<String> get displayImages {
    final variantImgs = selectedVariant.value?.images ?? [];
    if (variantImgs.isNotEmpty) return variantImgs;
    return product.value?.images ?? [];
  }

  /// Refresh
  @override
  Future<void> refresh() => fetchProductDetails();
}
