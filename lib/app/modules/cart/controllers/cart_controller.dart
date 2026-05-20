import 'package:book_store_app/app/base_view/controller/base_view_controller.dart';
import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/data/repositories/cart_repository.dart';
import 'package:book_store_app/app/modules/cart/models/cart_response_model.dart';
import 'package:book_store_app/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:book_store_app/config/resources/app_sounds.dart';
import 'package:book_store_app/utils/custom_alert_dialog_util.dart';
import 'package:book_store_app/utils/toast_util.dart';

import 'package:get/get.dart';

class CartController extends BaseController {
  final CartRepository _cartRepository = CartRepository();

  // ─── State ────────────────────────────────────────────────────────────────
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool selectAll = false.obs;
  final RxBool isLoading = false.obs;

  final Rx<double> subtotal = 0.0.obs;
  final Rx<double> shipping = 0.0.obs;
  final Rx<double> tax = 0.0.obs;
  final Rx<double> total = 0.0.obs;

  final Rx<CartResponseModel?> backendCart = Rx<CartResponseModel?>(null);

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> refreshCart() => fetchCart();

  // ─── 1. Fetch cart ────────────────────────────────────────────────────────

  Future<void> fetchCart() async {
    try {
      print("Fetching cart....");
      isLoading.value = true;

      final cart = await _cartRepository.getCart();
      print("cart: $cart");

      if (cart != null) {
        backendCart.value = cart;
        cartItems.assignAll(cart.items);
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

  // ─── 2. Add to cart ───────────────────────────────────────────────────────

  Future<void> addToCartBackend({CartResponseModel? cart}) async {
    try {
      isLoading.value = true;

      if (cart != null) {
        backendCart.value = cart;
        cartItems.assignAll(cart.items);
        for (final item in cartItems) {
          item.isSelected = true;
        }
        selectAll.value = true;
        calculateTotal();
      } else {
        await fetchCart();
      }
    } catch (e) {
      ToastUtil.showToast('Failed to add to cart');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateQuantity(
    String productId,
    String productVariantId,
    String action,
  ) async {
    try {
      isLoading.value = true;

      final updatedItem = await _cartRepository.updateCartItem(
        productId: productId,
        productVariantId: productVariantId,
        action: action,
      );

      if (updatedItem != null) {
        final index = cartItems.indexWhere(
          (i) =>
              i.productId == updatedItem.productId &&
              i.productVariantId == updatedItem.productVariantId,
        );

        if (index != -1) {
          cartItems[index] = cartItems[index].copyWith(
            quantity: updatedItem.quantity,
            price: updatedItem.price, // ← price (not backendPrice)
            isSelected: cartItems[index].isSelected,
          );
          cartItems.refresh();
        }

        calculateTotal();
      }
    } catch (e) {
      ToastUtil.showToast('Failed to update quantity');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Increase ───────────────────────────────────────────────────────────────
  Future<void> increaseQuantity(
    String productId,
    String productVariantId,
  ) async {
    await updateQuantity(productId, productVariantId, 'increase');
  }

  Future<void> decreaseQuantity(
    String productId,
    String productVariantId,
  ) async {
    await updateQuantity(productId, productVariantId, 'decrease');
  }

  Future<void> removeFromCart(String productId, String productVariantId) async {
    try {
      isLoading.value = true;

      final remainingItems = await _cartRepository.removeFromCart(
        productId,
        productVariantId,
      );

      if (remainingItems != null) {
        // Replace cartItems with the remaining items from the response
        cartItems.assignAll(remainingItems);
        updateSelectAll();
        calculateTotal();
        ToastUtil.showToast('Item removed');
      }
    } catch (e) {
      ToastUtil.showToast('Failed to remove item');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 5. Clear cart ────────────────────────────────────────────────────────

  Future<void> clearCart() async {
    try {
      isLoading.value = true;

      final success = await _cartRepository.clearCart();

      if (success) {
        backendCart.value = null;
        cartItems.clear();
        calculateTotal();
      }
    } catch (e) {
      ToastUtil.showToast('Failed to clear cart');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 6. Selection logic ───────────────────────────────────────────────────

  void toggleSelectAll(bool value) {
    selectAll.value = value;
    for (final item in cartItems) {
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
    selectAll.value =
        cartItems.isNotEmpty && cartItems.every((item) => item.isSelected);
  }

  void removeSelectedItems() {
    final selectedItems = cartItems.where((item) => item.isSelected).toList();
    for (final item in selectedItems) {
      removeFromCart(item.productId, item.productVariantId);
    }
  }

  // ─── 7. Total calculation ─────────────────────────────────────────────────

  void calculateTotal() {
    final selected = cartItems.where((e) => e.isSelected);

    subtotal.value = selected.fold(
      0.0,
      (sum, item) => sum + (item.actualPrice * item.quantity),
    );

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

  // ─── 8. Getters ───────────────────────────────────────────────────────────

  int get itemCount => cartItems.length;
  int get totalItems => backendCart.value?.totalItems ?? 0;
  bool get isEmpty => cartItems.isEmpty;
  bool get hasItems => cartItems.isNotEmpty;
  bool get hasSelectedItems => cartItems.any((item) => item.isSelected);

  // ─── 9. Checkout ──────────────────────────────────────────────────────────

  List<Map<String, dynamic>> getOrderItems() {
    return cartItems
        .where((item) => item.isSelected)
        .map((item) => item.toBackendJson())
        .toList();
  }

  // ─── 10. UI helpers ───────────────────────────────────────────────────────
  final WishlistController wishlistController = Get.put(WishlistController());
  void moveToWishlist(CartItem item) {
    wishlistController.addToWishlist(
      productId: item.productId,
      productVariantId: item.productVariantId,
    );
    CustomAppSnackbar.show(
      soundPath: AppSounds.successSound,
      title: 'Wishlist',
      message: '${item.name} moved to wishlist',
    );
  }

  void showDeleteConfirmation({
    Function()? onLeftButtonTap,
    Function()? onRightButtonTap,
  }) {
    showCustomDialog(
      title: 'Are you sure?',
      content:
          'Try moving the item to your wishlist, just in case you need it someday.',
      onLeftButtonTap: onLeftButtonTap,
      leftButtonName: 'Move to Wishlist',
      onRightButtonTap: onRightButtonTap,
      rightButtonName: 'Delete',
    );
  }

  void showWishListConformation({Function()? onRightButtonTap}) {
    showCustomDialog(
      title: 'Move to Wishlist?',
      content: 'Are you sure you want to move the item to your wishlist?',
      leftButtonName: 'Cancel',
      onRightButtonTap: onRightButtonTap,
      rightButtonName: 'Yes',
      onLeftButtonTap: Get.back,
    );
  }
}
