import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/category/widgets/filter_bottom_sheet.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  RxInt selectedCategoryIndex = 0.obs;

  // ---------------- Filter -----------------

  RxDouble minPrice = 0.0.obs;
  RxDouble maxPrice = 1000.0.obs;

  RxDouble currentMinFilter = 0.0.obs;
  RxDouble currentMaxFilter = 1000.0.obs;

  RxString selectedBrand = "".obs;
  RxDouble selectedRating = 0.0.obs;

  List<String> brands = ["Ikea", "HomeZ", "UrbanHouse", "KitchenPro"];
  List<double> ratings = [1, 2, 3, 4, 5];

  void resetFilters() {
    selectedBrand.value = "";
    selectedRating.value = 0;
    currentMinFilter.value = minPrice.value;
    currentMaxFilter.value = maxPrice.value;
  }

  Future bottomsheet(context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(),
    );
  }

  // ---------------- Category Model -----------------

  final RxList<CategoryModel> categories = <CategoryModel>[
    CategoryModel(
      title: "Storage & Organization",
      icon: AppImages.sampleProduct,
      children: [
        "All Products",
        "Storage Basket",
        "Storage Boxes",
        "Closet Storage",
        "Storage Racks",
        "Desk Organization",
        "Tissue Box",
      ],
    ),
    CategoryModel(
      title: "Kitchen & Dining",
      icon: AppImages.sampleProduct,
      children: ["Containers", "Plates", "Bowls"],
    ),
    CategoryModel(
      title: "Home Decor",
      icon: AppImages.sampleProduct,
      children: ["Storage Racks", "Desk Organization", "Tissue Box"],
    ),
    CategoryModel(
      title: "Home Essential",
      icon: AppImages.sampleProduct,
      children: ["Desk Organization"],
    ),
    CategoryModel(
      title: "Art & Sewing",
      icon: AppImages.sampleProduct,
      children: ["Desk Organization", "Tissue Box"],
    ),
    CategoryModel(
      title: "Household Cleaning",
      icon: AppImages.sampleProduct,
      children: ["Storage Racks", "Desk Organization"],
    ),
    CategoryModel(
      title: "Color Asseccories",
      icon: AppImages.sampleProduct,
      children: ["Storage Racks", "Tissue Box"],
    ),
  ].obs;

  // ---------------- Product Model -----------------

  RxList<ProductModel> products = <ProductModel>[
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
      customerReviews: [],
      variants: [],
      category: "Art & Sewing",
      description: "Shoe box, strip grey, black, white",
      name: "Baby World",
      image: AppImages.sampleProduct,
      price: 12.9,
      rating: 4.9,
      reviews: 92,
    ),
    ProductModel(
      customerReviews: [],
      variants: [],
      category: "Art & Sewing",
      description: "Shoe box, strip grey, black, white",
      name: "Tom & Friends",
      image: AppImages.sampleProduct,
      price: 10.9,
      rating: 4.3,
      reviews: 82,
    ),
    ProductModel(
      customerReviews: [],
      variants: [],
      category: "History",
      description: "Shoe box, strip grey, black, white",
      name: "Ancient Egypt",
      image: AppImages.sampleProduct,
      price: 13.9,
      rating: 4.7,
      reviews: 65,
    ),
    ProductModel(
      customerReviews: [],
      variants: [],
      category: "Lighting Essential",
      description: "Shoe box, strip grey, black, white",
      name: "Quran Tafseer",
      image: AppImages.sampleProduct,
      price: 15.9,
      rating: 4.9,
      reviews: 470,
    ),
  ].obs;

  // -------------- Get products by category -----------------

  RxList<ProductModel> filteredCategoryProducts = <ProductModel>[].obs;

  void loadProductsByCategory(String categoryName) {
    filteredCategoryProducts.assignAll(
      products.where((p) => p.category == categoryName),
    );
  }

  // ---------------- Product Details -----------------

  /// Selected product for detail screen
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);

  /// Quantity
  RxInt productQty = 1.obs;

  /// Selected variant index
  RxInt selectedVariantIndex = 0.obs;

  /// Load product details safely
  void openProductDetails(ProductModel product) {
    selectedProduct.value = product;
    productQty.value = 1;
    selectedVariantIndex.value = 0;

    Get.toNamed(Routes.productDetailsView);
  }

  /// Increase quantity
  void increaseQty() {
    productQty.value++;
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
  List<ProductModel> get relatedProducts {
    if (selectedProduct.value == null) return [];

    return products
        .where(
          (p) =>
              p.category == selectedProduct.value!.category &&
              p.name != selectedProduct.value!.name,
        )
        .toList();
  }

  /// Add to cart (dummy for now)
  void addToCart(context, prodImg) {
    if (selectedProduct.value == null) return;

    final size = MediaQuery.of(context).size;
    final cartController = Get.put(CartController());

    cartController.addToCart(
      product: selectedProduct.value!,
      quantity: productQty.value,
      selectedVariant: selectedVariantIndex.value,
    );
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        height: size.height / 2.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              text: "You might like",
              fontSize: AppFontSize.medium,
              fontWeight: FontWeight.w600,
            ),
            RecommendedProductList(),
            SizedBox(height: 20),
            Row(
              spacing: 20,
              children: [
                SvgIcon(assetName: prodImg, size: 50),
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

    Get.snackbar(
      "Added to Cart",
      "${selectedProduct.value!.name} (x$productQty)",
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.white,
    );
  }
}
