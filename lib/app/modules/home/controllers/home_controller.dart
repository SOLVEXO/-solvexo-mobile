import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/models/banner_model.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxInt bannerIndex = 0.obs;
  RxBool isLoading = true.obs;
  RxInt selectedCategoryIndex = 0.obs;
  RxInt tabIndex = 0.obs;

  /// Favourite handling
  RxMap<String, bool> favouriteMap = <String, bool>{}.obs;

  // -------------------- BANNERS --------------------

  final List<BannerModel> banners = [
    BannerModel(
      title: "Nice and Tidy",
      desc: "Get organized with best selling Storage system",
      image: AppImages.sampleProduct,
    ),
    BannerModel(
      title: "Smooth and Comfortable",
      desc: "Get organized with best selling Storage system",
      image: AppImages.sampleProduct,
    ),
    BannerModel(
      title: "Nice and Tidy",
      desc: "Get organized with best selling Storage system",
      image: AppImages.sampleProduct,
    ),
  ];

  // -------------------- TABS --------------------

  final List<String> tabs = [
    "All Products",
    "Kitchen & Dining",
    "Art & Sewing",
    "History",
    "Lighting Essential",
  ];
  @override
  void onInit() {
    super.onInit();

    filterProducts();

    for (var p in products) {
      favouriteMap[p.name] = false;
    }

    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
    });
  }

  // RIGHT SIDE PRODUCTS
  Map<int, List<Map<String, dynamic>>> productData = {
    0: [
      {"name": "All Products"},
      {"name": "Storage Basket"},
      {"name": "Storage Boxes"},
      {"name": "Closet Storage"},
      {"name": "Storage Racks"},
      {"name": "Desk Organization"},
      {"name": "Tissue Box"},
    ],
    1: [
      {"name": "Containers"},
      {"name": "Plates"},
      {"name": "Bowls"},
    ],
  };

  List<Map<String, dynamic>> get selectedProducts =>
      productData[selectedCategoryIndex.value] ?? [];

  final List<ProductModel> products = [
    ProductModel(
      category: "Kitchen & Dining",
      description: "Shoe box, strip grey, black, white",
      name: "Dark Forest",
      image: AppImages.sampleProduct,
      price: 19.9,
      rating: 4.5,
      reviews: 122,
      variants: [],
      customerReviews: [],
    ),
    ProductModel(
      category: "Kitchen & Dining",
      description: "Shoe box, strip grey, black, white",
      name: "Ocean Blue",
      image: AppImages.sampleProduct,
      price: 17.9,
      rating: 4.2,
      reviews: 210,
      variants: [],
      customerReviews: [],
    ),
    ProductModel(
      category: "Art & Sewing",
      description: "Shoe box, strip grey, black, white",
      name: "Baby World",
      image: AppImages.sampleProduct,
      price: 12.9,
      rating: 4.9,
      reviews: 92,
      variants: [],
      customerReviews: [],
    ),
    ProductModel(
      category: "Art & Sewing",
      description: "Shoe box, strip grey, black, white",
      name: "Tom & Friends",
      image: AppImages.sampleProduct,
      price: 10.9,
      rating: 4.3,
      reviews: 82,
      variants: [],
      customerReviews: [],
    ),
    ProductModel(
      category: "History",
      description: "Shoe box, strip grey, black, white",
      name: "Ancient Egypt",
      image: AppImages.sampleProduct,
      price: 13.9,
      rating: 4.7,
      reviews: 65,
      variants: [],
      customerReviews: [],
    ),
    ProductModel(
      category: "Lighting Essential",
      description: "Shoe box, strip grey, black, white",
      name: "Quran Tafseer",
      image: AppImages.sampleProduct,
      price: 15.9,
      rating: 4.9,
      reviews: 470,
      variants: [],
      customerReviews: [],
    ),
  ];

  // -------------------- FILTERED PRODUCTS --------------------

  RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  void filterProducts() {
    final selectedTab = tabs[tabIndex.value];

    if (selectedTab == "All Products") {
      filteredProducts.assignAll(products);
    } else {
      filteredProducts.assignAll(
        products.where((p) => p.category == selectedTab),
      );
    }
  }

  void toggleFavourite(String productName) {
    favouriteMap[productName] = !(favouriteMap[productName] ?? false);
  }
}
