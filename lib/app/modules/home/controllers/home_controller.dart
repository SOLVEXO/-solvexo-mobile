import 'package:book_store_app/app/data/repositories/banners_repository.dart';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/models/banner_model.dart';
import 'package:book_store_app/app/modules/address/models/address_model.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final BannersRepository _bannersRepository = BannersRepository();
  // UI State
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxInt bannerIndex = 0.obs;
  final RxBool isLoadingBanners = false.obs;
  RxBool isLoading = true.obs;
  RxBool isFetchingProducts = false.obs;
  RxInt selectedCategoryIndex = 0.obs;
  RxInt tabIndex = 0.obs;

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxBool hasMoreProducts = true.obs;

  // Products & Categories
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // Favourite handling
  RxMap<String, bool> favouriteMap = <String, bool>{}.obs;

  // Search & Filter
  RxString searchQuery = ''.obs;
  RxString selectedSort = 'newest'.obs; // newest, price_asc, price_desc, rating
  Rx<double?> minPrice = Rx<double?>(null);
  Rx<double?> maxPrice = Rx<double?>(null);

  AddressModel get address => AddressModel(
    label: "home",
    fullName: "Jami Raza",
    phone: "028866372",
    addressLine1: "flat 1, fb area",
    state: "sindh",
    city: "Karachi",
    zipCode: "21092",
    country: "Pakistan",
  );

  // -------------------- TABS --------------------

  List<String> get tabs {
    List<String> tabList = ["All Products"];
    tabList.addAll(categories.map((cat) => cat.name).toList());
    return tabList;
  }

  @override
  void onInit() {
    super.onInit();
    initializeHome();
    fetchBanners();
  }

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

  /// Initialize home screen - fetch all data
  Future<void> initializeHome() async {
    isLoading.value = true;

    try {
      // Fetch categories first
      await fetchCategories();

      // Fetch featured products
      await fetchFeaturedProducts();

      // Fetch all products
      await fetchProducts();
    } catch (e) {
      debugPrint('Error initializing home: $e');
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

  /// Fetch featured products
  Future<void> fetchFeaturedProducts() async {
    try {
      final fetchedProducts = await _productRepository.getFeaturedProducts();

      if (fetchedProducts != null) {
        featuredProducts.assignAll(fetchedProducts);

        // Add to favourites map
        for (var product in fetchedProducts) {
          favouriteMap[product.id] = false;
        }

        debugPrint('Fetched ${fetchedProducts.length} featured products');
      }
    } catch (e) {
      debugPrint('Error fetching featured products: $e');
    }
  }

  /// Fetch products with filters
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
      // Get selected category ID if not "All Products"
      String? categoryId;
      final selectedTab = tabs[tabIndex.value];
      if (selectedTab != "All Products") {
        final selectedCategory = categories.firstWhereOrNull(
          (cat) => cat.name == selectedTab,
        );
        categoryId = selectedCategory?.id;
      }

      final response = await _productRepository.getProducts(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        category: categoryId,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        sort: selectedSort.value,
        page: currentPage.value,
        limit: 10,
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

        // Add to favourites map
        for (var product in response.products) {
          favouriteMap[product.id] = false;
        }

        // Update filtered products
        filterProducts();

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
    }
  }

  /// Filter products based on selected tab
  void filterProducts() {
    final selectedTab = tabs[tabIndex.value];

    if (selectedTab == "All Products") {
      filteredProducts.assignAll(products);
    } else {
      // Filter by category name
      filteredProducts.assignAll(
        products.where((p) => p.category?.name == selectedTab),
      );
    }

    debugPrint('Filtered ${filteredProducts.length} products for $selectedTab');
  }

  /// Change tab and reload products
  void onTabChanged(int index) {
    tabIndex.value = index;
    fetchProducts(); // Reload products for new category
  }

  /// Toggle favourite status
  void toggleFavourite(String productId) {
    favouriteMap[productId] = !(favouriteMap[productId] ?? false);

    // For now just updating locally
  }

  /// Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    fetchProducts();
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    fetchProducts();
  }

  /// Change sort order
  void changeSortOrder(String sort) {
    selectedSort.value = sort;
    fetchProducts();
  }

  /// Apply price filter
  void applyPriceFilter(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
    fetchProducts();
  }

  /// Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedSort.value = 'newest';
    minPrice.value = null;
    maxPrice.value = null;
    tabIndex.value = 0;
    fetchProducts();
  }

  /// Refresh all data
  Future<void> refreshHome() async {
    await initializeHome();
  }

  /// Load more products (for pagination)
  Future<void> loadMoreProducts() async {
    await fetchProducts(loadMore: true);
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final product = await _productRepository.getProductById(productId);

      if (product != null) {
        debugPrint('Fetched product: ${product.name}');
      }

      return product;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      ToastUtil.showToast('Failed to load product details');
      return null;
    }
  }

  /// Check if product is favourite
  bool isFavourite(String productId) {
    return favouriteMap[productId] ?? false;
  }

  /// Get product count for category
  int getProductCount(String categoryName) {
    if (categoryName == "All Products") {
      return products.length;
    }
    return products.where((p) => p.category?.name == categoryName).length;
  }

  final items = [
    {
      "title": "Sheet Sets",
      "price": "\$3.99",
      "image": "https://www.pngall.com/wp-content/uploads/2/Pillow.png",
      "color": const Color(0xffE7E6F2),
    },
    {
      "title": "Laundry Bags",
      "price": "\$4.99",
      "image":
          "https://www.pngall.com/wp-content/uploads/4/Leather-Bag-PNG.png",
      "color": const Color(0xffDDF0F1),
    },
    {
      "title": "Towel Sets",
      "price": "\$14.99",
      "image": "https://pngimg.com/uploads/towel/towel_PNG20.png",
      "color": const Color(0xffF4DFDF),
    },
    {
      "title": "Floor Lamps",
      "price": "\$7.99",
      "image":
          "https://static.vecteezy.com/system/resources/previews/052/648/828/non_2x/gold-floor-lamp-with-pleated-shade-png.png",
      "color": const Color(0xffF2E8DC),
    },
  ];
}
