import 'package:book_store_app/app/data/repositories/wishlist_repository.dart';
import 'package:book_store_app/app/modules/wishlist/model/wishlist_model.dart';
import 'package:book_store_app/utils/custom_alert_dialog_util.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistController extends GetxController {
  final WishlistRepository _repo = WishlistRepository();

  // ─── State ────────────────────────────────────────────────────────────────
  final RxList<WishlistItem> wishlistItems = <WishlistItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Local set of wishlisted productVariantId strings for fast O(1) lookup
  // Used by product cards/detail to show filled/outlined heart icon
  final RxSet<String> _wishlistedVariantIds = <String>{}.obs;

  // Map of productVariantId → wishlistId for quick removal without re-fetch
  final Map<String, String> _variantToWishlistId = {};

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  // ─── 1. Fetch all ─────────────────────────────────────────────────────────

  Future<void> fetchWishlist() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final items = await _repo.getWishlist();
      wishlistItems.assignAll(items);
      _rebuildLookup();
      debugPrint('✅ Wishlist loaded: ${items.length}');
    } catch (e) {
      debugPrint('❌ fetchWishlist error: $e');
      ToastUtil.showToast('Failed to load wishlist');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => fetchWishlist();

  Future<void> clearWishlist() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final response = await _repo.clearWishList();
      if (response) {
        wishlistItems.clear();
        ToastUtil.showToast("Wishlist Items has been removed!");
      }
      isLoading.value = false;
    } catch (e) {
      ToastUtil.showToast("$e");
    } finally {
      isLoading.value = false;
    }
  }

  void showDeleteConfirmation() {
    showCustomDialog(
      title: 'Clearing Wishlist?',
      content: 'You are trying to clear wishlist.',
      onLeftButtonTap: () => Get.back(),
      leftButtonName: 'Cancle',
      onRightButtonTap: () => clearWishlist(),
      rightButtonName: 'Delete',
    );
  }
  // ─── 3. Add to wishlist ───────────────────────────────────────────────────

  Future<void> addToWishlist({
    required String productId,
    required String productVariantId,
  }) async {
    // Optimistic UI update
    _wishlistedVariantIds.add(productVariantId);

    try {
      final item = await _repo.addToWishlist(
        productId: productId,
        productVariantId: productVariantId,
      );

      if (item != null) {
        wishlistItems.add(item);

        // Store wishlistId for fast removal later
        if (item.wishlistId != null) {
          _variantToWishlistId[productVariantId] = item.wishlistId!;
        }

        ToastUtil.showToast('Added to wishlist');
        debugPrint('✅ Added to wishlist: $productId');
      } else {
        // Revert optimistic update on failure
        _wishlistedVariantIds.remove(productVariantId);
        ToastUtil.showToast('Failed to add to wishlist');
      }
    } catch (e) {
      _wishlistedVariantIds.remove(productVariantId);
      debugPrint('❌ addToWishlist error: $e');
      ToastUtil.showToast('Failed to add to wishlist');
    }
  }

  // ─── 4. Remove from wishlist ──────────────────────────────────────────────

  Future<void> removeFromWishlist({
    required String productVariantId,
    String? wishlistId, // pass directly if known
  }) async {
    // Resolve wishlistId from the local map if not passed
    final resolvedId = wishlistId ?? _variantToWishlistId[productVariantId];

    if (resolvedId == null || resolvedId.isEmpty) {
      debugPrint(
        '❌ removeFromWishlist: wishlistId not found for $productVariantId',
      );
      ToastUtil.showToast('Cannot remove — item not found');
      return;
    }

    // Optimistic UI update
    _wishlistedVariantIds.remove(productVariantId);
    final removed = wishlistItems
        .where((i) => i.wishlistEntry?.id == resolvedId)
        .toList();
    wishlistItems.removeWhere((i) => i.wishlistEntry?.id == resolvedId);

    try {
      final success = await _repo.removeFromWishlist(wishlistId: resolvedId);

      if (success) {
        _variantToWishlistId.remove(productVariantId);
        ToastUtil.showToast('Removed from wishlist');
        debugPrint('✅ Removed from wishlist: $resolvedId');
      } else {
        // Revert on failure
        _wishlistedVariantIds.add(productVariantId);
        wishlistItems.addAll(removed);
        ToastUtil.showToast('Failed to remove from wishlist');
      }
    } catch (e) {
      _wishlistedVariantIds.add(productVariantId);
      wishlistItems.addAll(removed);
      debugPrint('❌ removeFromWishlist error: $e');
      ToastUtil.showToast('Failed to remove from wishlist');
    }
  }

  // ─── 5. Toggle (add or remove) ────────────────────────────────────────────
  // Used by product cards — single tap toggles wishlist state

  Future<void> toggleWishlist({
    required String productId,
    required String productVariantId,
  }) async {
    if (isWishlisted(productVariantId)) {
      await removeFromWishlist(productVariantId: productVariantId);
    } else {
      await addToWishlist(
        productId: productId,
        productVariantId: productVariantId,
      );
    }
  }

  // ─── 6. Check if wishlisted ───────────────────────────────────────────────
  // O(1) — used by product cards to show heart icon state

  bool isWishlisted(String productVariantId) {
    return _wishlistedVariantIds.contains(productVariantId);
  }

  // ─── 7. Get wishlistId for a variant ─────────────────────────────────────

  String? getWishlistId(String productVariantId) {
    return _variantToWishlistId[productVariantId];
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _rebuildLookup() {
    _wishlistedVariantIds.clear();
    _variantToWishlistId.clear();

    for (final item in wishlistItems) {
      // From get-wishlist, wishlistEntry may be null —
      // use the first variant's productVariantId as key
      final variantId =
          item.wishlistEntry?.productVariantId ??
          (item.variants.isNotEmpty ? item.variants.first.id : null);

      if (variantId != null && variantId.isNotEmpty) {
        _wishlistedVariantIds.add(variantId);

        if (item.wishlistEntry?.id != null) {
          _variantToWishlistId[variantId] = item.wishlistEntry!.id;
        }
      }
    }

    debugPrint(
      '🔄 Wishlist lookup rebuilt: ${_wishlistedVariantIds.length} items',
    );
  }

  // ─── Getters ──────────────────────────────────────────────────────────────

  int get count => wishlistItems.length;
  bool get isEmpty => wishlistItems.isEmpty;
  bool get hasItems => wishlistItems.isNotEmpty;
}
