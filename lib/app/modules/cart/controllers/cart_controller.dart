import 'package:book_store_app/app/modules/cart/models/cart_item_model.dart';
import 'package:book_store_app/app/modules/cart/widgets/conformation_bottom_sheet_content.dart';
import 'package:get/get.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';

class CartController extends GetxController {
  // ---------------- CART STATE ----------------

  /// Cart items
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  /// Select all checkbox
  RxBool selectAll = false.obs;

  /// Loading (for API later)
  RxBool isLoading = false.obs;

  // ---------------- ADD TO CART ----------------

  void addToCart({
    required ProductModel product,
    required int quantity,
    int selectedVariant = 0,
  }) {
    final index = cartItems.indexWhere((e) => e.product.name == product.name);

    if (index != -1) {
      cartItems[index].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(
        CartItem(
          product: product,
          quantity: quantity,
          selectedVariant: selectedVariant,
        ),
      );
    }

    updateSelectAll();
  }

  // ---------------- REMOVE ----------------

  void removeItem(CartItem item) {
    cartItems.remove(item);
    updateSelectAll();
  }

  void removeSelectedItems() {
    cartItems.removeWhere((item) => item.isSelected);
    selectAll.value = false;
  }

  // ---------------- QUANTITY ----------------

  void increaseQty(CartItem item) {
    item.quantity++;
    cartItems.refresh();
  }

  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    }
  }

  // ---------------- SELECTION ----------------

  void toggleSelectAll(bool value) {
    selectAll.value = value;
    for (var item in cartItems) {
      item.isSelected = value;
    }
    cartItems.refresh();
  }

  void toggleItemSelection(CartItem item, bool value) {
    item.isSelected = value;
    cartItems.refresh();
    updateSelectAll();
  }

  void updateSelectAll() {
    if (cartItems.isEmpty) {
      selectAll.value = false;
    } else {
      selectAll.value = cartItems.every((item) => item.isSelected == true);
    }
  }

  // ---------------- WISHLIST ----------------

  void moveToWishlist(CartItem item) {
    cartItems.remove(item);

    Get.snackbar(
      "Wishlist",
      "${item.product.name} moved to wishlist",
      snackPosition: SnackPosition.TOP,
    );
  }

  // ---------------- PRICE ----------------

  double get subTotal {
    double total = 0;
    for (var item in cartItems) {
      if (item.isSelected) {
        total += item.product.price * item.quantity;
      }
    }
    return total;
  }

  bool get hasSelectedItems => cartItems.any((item) => item.isSelected);

  // ---------------- BOTTOM SHEETS ----------------

  void showDeleteConfirmation(Function() onConfirm) {
    Get.bottomSheet(
      ConformationBottomSheetContent(
        onConfirm: onConfirm,
        title: "Are you sure",
        subTitle:
            "Try to move item to wishlist, just incase you need it someday.",
        btnOneText: "Delete",
        btnTweOnPressed: () {
          Get.back();
          showWishListConformation();
        },
        btnTwoText: "Move to Wishlist",
        btnOneOnPressed: () {
          Get.back();
          onConfirm();
        },
      ),
    );
  }

  void showWishListConformation() {
    Get.bottomSheet(
      ConformationBottomSheetContent(
        title: "Move to wishlis?",
        subTitle: "Are you sure the item move to wishlist?",
        btnOneText: "Cancle",
        btnTweOnPressed: Get.back,
        btnTwoText: "Yes",
        btnOneOnPressed: () {
          Get.back();
        },
        onConfirm: () {},
      ),
    );
  }
}
