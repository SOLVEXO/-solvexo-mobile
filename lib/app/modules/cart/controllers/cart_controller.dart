import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/data/repositories/cart_repository.dart';
import 'package:book_store_app/app/modules/cart/models/cart_item_model.dart';
import 'package:book_store_app/app/modules/cart/models/cart_response_model.dart';
import 'package:book_store_app/app/modules/cart/widgets/conformation_bottom_sheet_content.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart'
    as BackendModel;
import 'package:book_store_app/config/resources/app_sounds.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final CartRepository _cartRepository = CartRepository();

  // ---------------- STATE ----------------
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  RxBool selectAll = false.obs;
  RxBool isLoading = false.obs;

  Rx<double> subtotal = 0.0.obs;
  Rx<double> shipping = 0.0.obs;
  Rx<double> tax = 0.0.obs;
  Rx<double> total = 0.0.obs;

  Rx<CartResponseModel?> backendCart = Rx<CartResponseModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> refreshCart() async {
    await fetchCart();
  }

  // =====================================================
  // FETCH CART
  // =====================================================

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;

      final cart = await _cartRepository.getCart();

      if (cart != null) {
        backendCart.value = cart;
        cartItems.value = cart.items;

        // 🔥 Auto select all on load
        for (var item in cartItems) {
          item.isSelected = true;
        }
        selectAll.value = true;

        calculateTotal();
      } else {
        cartItems.clear();
        calculateTotal();
      }
    } catch (e) {
      ToastUtil.showToast('Failed to load cart');
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // ADD TO CART
  // =====================================================

  Future<void> addToCartBackend({
    required BackendModel.ProductModel product,
    int quantity = 1,
  }) async {
    try {
      isLoading.value = true;

      final cart = await _cartRepository.addToCart(
        productId: product.id,
        quantity: quantity,
      );

      if (cart != null) {
        backendCart.value = cart;
        cartItems.value = cart.items;

        // keep selected by default
        for (var item in cartItems) {
          item.isSelected = true;
        }

        selectAll.value = true;
        calculateTotal();

        ToastUtil.showToast('${product.name} added to cart');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // QUANTITY
  // =====================================================

  Future<void> updateQuantity(String productId, int qty) async {
    try {
      if (qty < 1) {
        removeFromCart(productId);
        return;
      }

      isLoading.value = true;

      final cart = await _cartRepository.updateCartItem(
        productId: productId,
        quantity: qty,
      );

      if (cart != null) {
        backendCart.value = cart;
        cartItems.value = cart.items;

        calculateTotal();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> increaseQuantity(String productId) async {
    final index = cartItems.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      final newQty = cartItems[index].quantity + 1;

      if (cartItems[index].stock != null && newQty > cartItems[index].stock!) {
        ToastUtil.showToast("Maximum stock reached");
        return;
      }

      await updateQuantity(productId, newQty);
    }
  }

  Future<void> decreaseQuantity(String productId) async {
    final index = cartItems.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      final newQty = cartItems[index].quantity - 1;

      if (newQty < 1) {
        await removeFromCart(productId);
      } else {
        await updateQuantity(productId, newQty);
      }
    }
  }

  // =====================================================
  // REMOVE
  // =====================================================

  Future<void> removeFromCart(String productId) async {
    try {
      isLoading.value = true;

      final cart = await _cartRepository.removeFromCart(productId);

      if (cart != null) {
        backendCart.value = cart;
        cartItems.value = cart.items;

        updateSelectAll();
        calculateTotal();

        ToastUtil.showToast("Item removed");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearCart() async {
    try {
      isLoading.value = true;

      final success = await _cartRepository.clearCart();

      if (success) {
        backendCart.value = null;
        cartItems.clear();

        calculateTotal();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // SELECTION LOGIC
  // =====================================================

  void toggleSelectAll(bool value) {
    selectAll.value = value;

    for (var item in cartItems) {
      item.isSelected = value;
    }

    cartItems.refresh();
    calculateTotal();
  }

  void toggleItemSelection(CartItem item, bool value) {
    item.isSelected = value;

    cartItems.refresh();
    updateSelectAll();
    calculateTotal();
  }

  void updateSelectAll() {
    if (cartItems.isEmpty) {
      selectAll.value = false;
    } else {
      selectAll.value = cartItems.every((item) => item.isSelected == true);
    }
  }

  void removeSelectedItems() {
    final selectedIds = cartItems
        .where((item) => item.isSelected)
        .map((item) => item.productId)
        .toList();

    for (var id in selectedIds) {
      if (id != null) {
        removeFromCart(id);
      }
    }
  }

  // =====================================================
  // TOTAL CALCULATION (🔥 IMPORTANT FIX)
  // =====================================================

  double _calculateSelectedSubtotal() {
    final selected = cartItems.where((e) => e.isSelected == true);

    return selected.fold(
      0.0,
      (sum, item) => sum + (item.actualPrice * item.quantity),
    );
  }

  void calculateTotal() {
    subtotal.value = _calculateSelectedSubtotal();

    if (subtotal.value == 0) {
      shipping.value = 0;
      tax.value = 0;
      total.value = 0;
      return;
    }

    shipping.value = subtotal.value >= 50 ? 0 : 5;
    tax.value = subtotal.value * 0.1;

    total.value = subtotal.value + shipping.value + tax.value;
  }

  // =====================================================
  // GETTERS
  // =====================================================

  int get itemCount => cartItems.length;
  int get totalItems => backendCart.value?.totalItems ?? 0;

  bool get isEmpty => cartItems.isEmpty;
  bool get hasItems => cartItems.isNotEmpty;

  bool get hasSelectedItems => cartItems.any((item) => item.isSelected);

  // =====================================================
  // CHECKOUT ITEMS
  // =====================================================

  List<Map<String, dynamic>> getOrderItems() {
    return cartItems
        .where((item) => item.isSelected)
        .map((item) => item.toBackendJson())
        .toList();
  }

  // =====================================================
  // UI HELPERS
  // =====================================================

  void moveToWishlist(CartItem item) {
    cartItems.remove(item);
    CustomAppSnackbar.show(
      soundPath: AppSounds.successSound,
      title: "Wishlist",
      message: "${item.product.name} moved to wishlist",
    );
  }

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
