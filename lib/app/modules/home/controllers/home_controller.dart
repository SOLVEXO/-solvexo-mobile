import 'package:book_store_app/app/base_view/controller/base_view_controller.dart';
import 'package:book_store_app/app/data/repositories/banners_repository.dart';
import 'package:book_store_app/app/data/repositories/category_repository.dart';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/models/banner_model.dart';
import 'package:book_store_app/app/modules/address/models/address_model.dart';
import 'package:book_store_app/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends BaseController {
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final BannersRepository _bannersRepository = BannersRepository();

  // ─── UI State ─────────────────────────────────────────────────────────────
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxInt bannerIndex = 0.obs;
  final RxBool isLoadingBanners = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isFetchingProducts = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxInt tabIndex = 0.obs;

  // ─── Pagination ───────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreProducts = true.obs;

  // ─── Data ─────────────────────────────────────────────────────────────────
  // New ProductModel — variants-based, no top-level price/stock/ratings
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  // CategoryModel from getAllCategoryTrees — may have nested children
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // ─── Favourite map ────────────────────────────────────────────────────────
  final RxMap<String, bool> favouriteMap = <String, bool>{}.obs;

  // ─── Search & Filter ──────────────────────────────────────────────────────
  final RxString searchQuery = ''.obs;
  final RxString selectedSort = 'newest'.obs;
  final Rx<double?> minPrice = Rx<double?>(null);
  final Rx<double?> maxPrice = Rx<double?>(null);

  // ─── Static address (placeholder) ────────────────────────────────────────
  AddressModel get address => AddressModel(
    label: 'home',
    recipientName: 'Jami Raza',
    phoneNumber: '028866372',
    addressLine1: 'flat 1, fb area',
    state: 'sindh',
    city: 'Karachi',
    zipCode: '21092',
  );

  // ─── Tabs ─────────────────────────────────────────────────────────────────
  // "All Products" + one tab per root category name
  List<String> get tabs {
    return ['All Products', ...categories.map((cat) => cat.name)];
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    initializeHome();
    fetchBanners();
  }

  // ─── 1. Banners ───────────────────────────────────────────────────────────

  Future<void> fetchBanners() async {
    try {
      isLoadingBanners.value = true;
      final result = await _bannersRepository.fetchBanners();
      banners.assignAll(result);
      debugPrint('✅ Banners loaded: ${banners.length}');
    } catch (e) {
      debugPrint('❌ Error loading banners: $e');
      banners.clear();
    } finally {
      isLoadingBanners.value = false;
    }
  }

  // ─── 2. Initialize ────────────────────────────────────────────────────────

  Future<void> initializeHome() async {
    isLoading.value = true;
    try {
      await fetchCategories();
      await fetchFeaturedProducts();
      await fetchProducts();
    } catch (e) {
      debugPrint('❌ Error initializing home: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 3. Categories ────────────────────────────────────────────────────────
  // Uses getAllCategoryTrees() — same source as CategoryController — so the
  // tab list and CategoryView always show the same categories.

  Future<void> fetchCategories() async {
    try {
      final trees = await _categoryRepository.getAllCategoryTrees();
      categories.assignAll(trees);
      debugPrint('✅ Fetched ${trees.length} category trees for home');
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
      ToastUtil.showToast('Failed to load categories');
    }
  }

  // ─── 4. Featured Products ─────────────────────────────────────────────────

  Future<void> fetchFeaturedProducts() async {
    // try {
    //   // final fetched = await _productRepository.getFeaturedProducts();
    //   // if (fetched != null) {
    //   //   featuredProducts.assignAll(fetched);
    //   //   _updateFavouriteMap(fetched);
    //   //   debugPrint('✅ Featured products: ${fetched.length}');
    //   // }
    // } catch (e) {
    //   debugPrint('❌ Error fetching featured products: $e');
    // }
  }

  // ─── 5. Products ──────────────────────────────────────────────────────────
  // Uses getProductsByCategory() — same endpoint as SubCategoryController.
  // When tab is "All Products" no categoryId is sent and the backend returns
  // everything. When a tab is selected the root category ID is passed.

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (isFetchingProducts.value) return;

    if (loadMore) {
      if (!hasMoreProducts.value) return;
      currentPage.value++;
    } else {
      currentPage.value = 1;
    }

    isFetchingProducts.value = true;

    try {
      // Resolve category ID from the selected tab
      final String? categoryId = _categoryIdForCurrentTab();

      final response = await _productRepository.getProductsByCategory(
        categoryId: categoryId,
        page: currentPage.value,
        limit: 10,
      );

      if (response != null) {
        if (loadMore) {
          products.addAll(response.products);
        } else {
          products.assignAll(response.products);
        }

        totalPages.value = response.pages;
        hasMoreProducts.value = currentPage.value < totalPages.value;

        _updateFavouriteMap(response.products);
        _applyLocalFilters(); // search / sort filtering done client-side

        debugPrint(
          '✅ Fetched ${response.products.length} products '
          '(Page ${currentPage.value}/${totalPages.value})',
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      ToastUtil.showToast('Failed to load products');
      if (loadMore) currentPage.value--;
    } finally {
      isFetchingProducts.value = false;
    }
  }

  /// Returns the category ID for the active tab, or null for "All Products".
  String? _categoryIdForCurrentTab() {
    final index = tabIndex.value;
    if (index == 0) return null; // "All Products"

    // Tab index maps to categories list with offset of 1
    final catIndex = index - 1;
    if (catIndex < categories.length) {
      return categories[catIndex].id;
    }
    return null;
  }

  // ─── 6. Local filtering (search + sort) ──────────────────────────────────
  // Applied after every fetch so the displayed list is always up to date.
  // Heavy filtering (price, category) is handled server-side by the API.

  void _applyLocalFilters() {
    var result = products.toList();

    // Search filter — matches product name or description
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query),
          )
          .toList();
    }

    // Price filter — uses computed product.price (min variant price)
    if (minPrice.value != null) {
      result = result.where((p) => p.price >= minPrice.value!).toList();
    }
    if (maxPrice.value != null) {
      result = result.where((p) => p.price <= maxPrice.value!).toList();
    }

    // Sort
    switch (selectedSort.value) {
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        result.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'newest':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    filteredProducts.assignAll(result);
    debugPrint('🔍 Filtered to ${filteredProducts.length} products');
  }

  // ─── 7. Public actions ────────────────────────────────────────────────────

  /// Change tab — re-fetches products for the selected category
  void onTabChanged(int index) {
    tabIndex.value = index;
    fetchProducts();
  }

  final wishlistController = Get.put(WishlistController());

  /// Toggle favourite (local only for now)
  // void toggleFavourite(String productId) {
  //   favouriteMap[productId] = !(favouriteMap[productId] ?? false);
  // }

  bool isFavourite(String productId) => favouriteMap[productId] ?? false;

  Future<void> addorRemoveWishList(
    String productId,
    String productVariantId,
  ) async {
    try {
      if (isFavourite(productId)) {
        wishlistController.removeFromWishlist(
          productVariantId: productVariantId,
        );
        ToastUtil.showToast("Item removed From Wishlist");
      }
      await wishlistController.addToWishlist(
        productId: productId,
        productVariantId: productVariantId,
      );
      favouriteMap[productId] = !(favouriteMap[productId] ?? false);
      ToastUtil.showToast("Item Added to Wishlist");
    } catch (e) {
      ToastUtil.showToast("$e");
    }
  }

  /// Search — filters the already-loaded list instantly;
  /// fetches fresh results from the server after a tab reset
  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      fetchProducts();
    } else {
      _applyLocalFilters();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    fetchProducts();
  }

  /// Sort
  void changeSortOrder(String sort) {
    selectedSort.value = sort;
    _applyLocalFilters(); // sort is local — no need to re-fetch
  }

  /// Price filter
  void applyPriceFilter(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
    _applyLocalFilters();
  }

  /// Clear all filters and reset to "All Products"
  void clearFilters() {
    searchQuery.value = '';
    selectedSort.value = 'newest';
    minPrice.value = null;
    maxPrice.value = null;
    tabIndex.value = 0;
    fetchProducts();
  }

  /// Load more (pagination)
  Future<void> loadMoreProducts() => fetchProducts(loadMore: true);

  /// Full refresh
  final categoryController = Get.put(CategoryController());

  // ─── Replace refreshHome in HomeController ────────────────────────────────
  // Both home data and category data reset at the same time so
  // isLoading fires once for both, showing shimmer for all sections together.

  Future<void> refreshHome() async {
    // Set both loading states true simultaneously before any await
    isLoading.value = true;
    categoryController.isLoading.value = true;

    try {
      // Run both refreshes in parallel
      await Future.wait([initializeHome(), categoryController.refresh()]);
    } finally {
      // Both will set their own loading to false inside their methods,
      // but guard here just in case
      isLoading.value = false;
      categoryController.isLoading.value = false;
    }
  }

  /// Fetch single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final product = await _productRepository.getProductById(productId);
      if (product != null) {
        debugPrint('✅ Fetched product: ${product.name}');
      }
      return product;
    } catch (e) {
      debugPrint('❌ Error fetching product: $e');
      ToastUtil.showToast('Failed to load product details');
      return null;
    }
  }

  /// Product count per category tab (uses filteredProducts)
  int getProductCount(String categoryName) {
    if (categoryName == 'All Products') return filteredProducts.length;
    // category?.name may be null on the new model when not populated,
    // so fall back to matching categoryId via the categories list
    final cat = categories.firstWhereOrNull((c) => c.name == categoryName);
    if (cat == null) return 0;
    return filteredProducts.where((p) => p.categoryId == cat.id).length;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _updateFavouriteMap(List<ProductModel> list) {
    for (final p in list) {
      favouriteMap.putIfAbsent(p.id, () => false);
    }
  }

  // ─── Static items (home quick-links) ─────────────────────────────────────

  final items = [
    {
      'title': 'Sheet Sets',
      'price': '\$3.99',
      'image': 'https://www.pngall.com/wp-content/uploads/2/Pillow.png',
      'color': AppColors.categoryBg1,
    },
    {
      'title': 'Laundry Bags',
      'price': '\$4.99',
      'image':
          'https://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png',
      'color': AppColors.categoryBg2,
    },
    {
      'title': 'Towel Sets',
      'price': '\$14.99',
      'image': 'https://pngimg.com/uploads/towel/towel_PNG20.png',
      'color': AppColors.categoryBg3,
    },
    {
      'title': 'Floor Lamps',
      'price': '\$7.99',
      'image':
          'https://static.vecteezy.com/system/resources/previews/052/648/828/non_2x/gold-floor-lamp-with-pleated-shade-png.png',
      'color': AppColors.categoryBg4,
    },
  ];
}
