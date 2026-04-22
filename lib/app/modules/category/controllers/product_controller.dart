import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart'
    as BackendModel;
import 'package:book_store_app/app/modules/category/models/product_model.dart'
    as BackendModel;
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/category/widgets/filter_bottom_sheet.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_sounds.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  RxInt selectedCategoryIndex = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isFetchingProducts = false.obs;

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxBool hasMoreProducts = true.obs;

  // ---------------- Filter -----------------

  RxDouble minPrice = 0.0.obs;
  RxDouble maxPrice = 1000.0.obs;

  RxDouble currentMinFilter = 0.0.obs;
  RxDouble currentMaxFilter = 1000.0.obs;

  RxString selectedBrand = "".obs;
  RxDouble selectedRating = 0.0.obs;

  // Get unique brands from products
  List<String> get brands {
    final uniqueBrands = products
        .where((p) => p.brand != null && p.brand!.isNotEmpty)
        .map((p) => p.brand!)
        .toSet()
        .toList();
    return uniqueBrands.isEmpty
        ? ["Ikea", "HomeZ", "UrbanHouse", "KitchenPro"]
        : uniqueBrands;
  }

  List<double> ratings = [1, 2, 3, 4, 5];

  void resetFilters() {
    selectedBrand.value = "";
    selectedRating.value = 0;
    currentMinFilter.value = minPrice.value;
    currentMaxFilter.value = maxPrice.value;

    // Fetch products without filters
    fetchProducts();
  }

  void applyFilters() {
    currentMinFilter.value = minPrice.value;
    currentMaxFilter.value = maxPrice.value;

    // Fetch products with filters
    fetchProducts();
  }

  Future bottomsheet(context) {
    return Get.bottomSheet(
      CustomBottomSheet(
        title: "Filter",
        widget: FilterBottomSheet(),
        // height: Get.height / 2,
      ),
    );
  }

  // ---------------- Category Model -----------------

  final RxList<BackendModel.CategoryModel> categories =
      <BackendModel.CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  /// Initialize categories and products
  Future<void> initializeData() async {
    isLoading.value = true;

    try {
      await fetchCategories();
      await fetchProducts();
    } catch (e) {
      debugPrint('Error initializing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch categories from backend
  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await _productRepository.getCategories();

      if (fetchedCategories != null) {
        categories.assignAll(fetchedCategories);
        debugPrint('Fetched ${fetchedCategories.length} categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      ToastUtil.showToast('Failed to load categories');
    }
  }

  // ---------------- Product Model -----------------

  RxList<BackendModel.ProductModel> products =
      <BackendModel.ProductModel>[].obs;

  /// Fetch products from backend
  Future<void> fetchProducts({bool loadMore = false}) async {
    if (isFetchingProducts.value) return;

    // If loading more, increment page
    if (loadMore) {
      if (!hasMoreProducts.value) return;
      currentPage.value++;
    } else {
      currentPage.value = 1;
    }

    isFetchingProducts.value = true;

    try {
      // Build filter parameters
      final response = await _productRepository.getProducts(
        category: selectedCategoryIndex.value > 0
            ? categories[selectedCategoryIndex.value - 1].id
            : null,
        minPrice: currentMinFilter.value > 0 ? currentMinFilter.value : null,
        maxPrice: currentMaxFilter.value < 1000 ? currentMaxFilter.value : null,
        brand: selectedBrand.value.isNotEmpty ? selectedBrand.value : null,
        page: currentPage.value,
        limit: 20,
      );

      if (response != null) {
        if (loadMore) {
          // Append products
          products.addAll(response.products);
        } else {
          // Replace products
          products.assignAll(response.products);
        }

        // Update pagination info
        totalPages.value = response.pages;
        hasMoreProducts.value = currentPage.value < totalPages.value;

        debugPrint(
          'Fetched ${response.products.length} products (Page ${currentPage.value}/${totalPages.value})',
        );
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      ToastUtil.showToast('Failed to load products');

      // Revert page if error
      if (loadMore) {
        currentPage.value--;
      }
    } finally {
      isFetchingProducts.value = false;
      filterCategoryProducts();
    }
  }

  /// Load more products
  Future<void> loadMoreProducts() async {
    await fetchProducts(loadMore: true);
  }

  // -------------- Get products by category -----------------

  RxList<BackendModel.ProductModel> filteredCategoryProducts =
      <BackendModel.ProductModel>[].obs;

  void loadProductsByCategory(String categoryName) {
    filteredCategoryProducts.assignAll(
      products.where((p) => p.category?.name == categoryName),
    );
  }

  void filterCategoryProducts() {
    if (selectedCategoryIndex.value == 0) {
      // All categories
      filteredCategoryProducts.assignAll(products);
    } else {
      final selectedCategory = categories[selectedCategoryIndex.value - 1];
      filteredCategoryProducts.assignAll(
        products.where((p) => p.category?.id == selectedCategory.id),
      );
    }

    // Apply additional filters
    if (selectedBrand.value.isNotEmpty) {
      filteredCategoryProducts.assignAll(
        filteredCategoryProducts.where((p) => p.brand == selectedBrand.value),
      );
    }

    if (selectedRating.value > 0) {
      filteredCategoryProducts.assignAll(
        filteredCategoryProducts.where(
          (p) => p.ratings.average >= selectedRating.value,
        ),
      );
    }

    debugPrint('Filtered ${filteredCategoryProducts.length} products');
  }

  /// Change category
  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
    fetchProducts();
  }

  // ---------------- Product Details -----------------

  /// Selected product for detail screen
  final Rx<BackendModel.ProductModel?> selectedProduct =
      Rx<BackendModel.ProductModel?>(null);

  /// Quantity
  RxInt productQty = 1.obs;

  /// Selected variant index
  RxInt selectedVariantIndex = 0.obs;

  /// Load product details from backend by ID
  Future<void> loadProductDetails(String productId) async {
    try {
      isLoading.value = true;

      final product = await _productRepository.getProductById(productId);

      if (product != null) {
        selectedProduct.value = product;
        productQty.value = 1;
        selectedVariantIndex.value = 0;
        debugPrint('Loaded product details: ${product.name}');
      } else {
        ToastUtil.showToast('Product not found');
      }
    } catch (e) {
      debugPrint('Error loading product details: $e');
      ToastUtil.showToast('Failed to load product details');
    } finally {
      isLoading.value = false;
    }
  }

  /// Open product details safely
  void openProductDetails(dynamic product) {
    // Handle both old ProductModel and new BackendModel.ProductModel
    if (product is BackendModel.ProductModel) {
      selectedProduct.value = product;
      productQty.value = 1;
      selectedVariantIndex.value = 0;
      Get.toNamed(Routes.productDetailsView);
    } else if (product is ProductModel) {
      // For backward compatibility with old model
      // You might need to convert or fetch from backend
      ToastUtil.showToast('Please refresh and try again');
    }
  }

  /// Increase quantity
  void increaseQty() {
    if (selectedProduct.value != null) {
      // Check if stock is available
      if (productQty.value < selectedProduct.value!.stock) {
        productQty.value++;
      } else {
        ToastUtil.showToast('Maximum stock reached');
      }
    }
  }

  /// Decrease quantity
  void decreaseQty() {
    if (productQty.value > 1) {
      productQty.value--;
    }
  }

  /// Select variant
  void selectVariant(int index) {
    selectedVariantIndex.value = index;
  }

  /// Related products (same category, excluding current)
  List<BackendModel.ProductModel> get relatedProducts {
    if (selectedProduct.value == null) return [];

    return products
        .where(
          (p) =>
              p.category?.id == selectedProduct.value!.category?.id &&
              p.id != selectedProduct.value!.id,
        )
        .take(6) // Limit to 6 related products
        .toList();
  }

  /// Add to cart
  void addToCart(context, prodImg) {
    if (selectedProduct.value == null) {
      ToastUtil.showToast('Please select a product');
      return;
    }

    // Check stock
    if (!selectedProduct.value!.inStock) {
      ToastUtil.showToast('Product is out of stock');
      return;
    }

    if (productQty.value > selectedProduct.value!.stock) {
      ToastUtil.showToast('Not enough stock available');
      return;
    }

    final size = MediaQuery.of(context).size;
    final cartController = Get.put(CartController());

    // Convert backend model to your cart model format
    // You might need to create an adapter here
    cartController.addToCartBackend(
      product: selectedProduct.value!,
      quantity: productQty.value,
    );

    Get.bottomSheet(
      CustomBottomSheet(
        title: "You might like",
        height: size.height / 1.5,
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RecommendedProductList(),
            SizedBox(height: 20),
            Row(
              spacing: 20,
              children: [
                // Use network image if available
                selectedProduct.value!.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CommonImageView(
                          url: selectedProduct.value!.images.first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : SvgIcon(assetName: prodImg, size: 50),
                CustomText(
                  text: "Added to cart",
                  fontSize: AppFontSize.regular,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: AppButton(
                    label: "Go to Cart",
                    onPressed: () => Get.toNamed(Routes.cartView),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    CustomAppSnackbar.show(
      soundPath: AppSounds.successSound,
      title: "Added to Cart",
      message: "${selectedProduct.value!.name} (x$productQty)",
    );
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await initializeData();
  }

  /// Search products
  RxString searchQuery = ''.obs;

  Future<void> searchProducts(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      await fetchProducts();
      return;
    }

    isFetchingProducts.value = true;

    try {
      final response = await _productRepository.getProducts(
        search: query,
        page: 1,
        limit: 50,
      );

      if (response != null) {
        products.assignAll(response.products);
        filterCategoryProducts();
        debugPrint('Search found ${response.products.length} products');
      }
    } catch (e) {
      debugPrint('Error searching products: $e');
      ToastUtil.showToast('Search failed');
    } finally {
      isFetchingProducts.value = false;
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    fetchProducts();
  }
}
