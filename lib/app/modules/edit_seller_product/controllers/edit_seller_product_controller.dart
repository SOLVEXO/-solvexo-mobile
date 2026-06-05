import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<String> kProductEmojis = [
  '📐', '☕', '🖼️', '➗', '🔬', '🧩', '📚', '📋', '💾', '🎨',
  '🧴', '👜', '📦', '🕯️', '✏️', '📷', '🎀', '📔', '💧', '🗝️',
  '🍜', '🐝', '🧸', '🎯', '🏆', '💡', '🔮', '🌿', '📱', '🖥️',
];

class EditSellerProductController extends GetxController {
  late SellerProduct product;

  // Text controllers (pre-filled on init)
  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController stockCtrl;

  // Reactive form state
  final RxString name = ''.obs;
  final RxString description = ''.obs;
  final RxString price = ''.obs;
  final RxString stock = ''.obs;
  final RxString selectedEmoji = '📦'.obs;
  final RxBool unlimitedStock = false.obs;
  final RxBool isActive = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  // ── Computed ─────────────────────────────────────────────────────────────────

  bool get isPhysical => product.type == 'Physical';

  bool get canSave =>
      name.value.trim().isNotEmpty && price.value.trim().isNotEmpty;

  bool get hasChanges =>
      name.value != product.name ||
      price.value != product.price.toStringAsFixed(2) ||
      selectedEmoji.value != product.emoji ||
      isActive.value != (product.status == ProductStatus.active);

  // ── Actions ───────────────────────────────────────────────────────────────────

  void pickEmoji(String emoji) {
    selectedEmoji.value = emoji;
    Get.back();
  }

  Future<void> saveChanges() async {
    if (!canSave || isSaving.value) return;
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    isSaving.value = false;
    Get.back();
    Get.snackbar(
      '',
      'Product updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> deleteProduct() async {
    isDeleting.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    isDeleting.value = false;
    Get.back();
    Get.snackbar(
      '',
      '${product.name} deleted.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as SellerProduct;

    // Pre-fill
    nameCtrl = TextEditingController(text: product.name);
    descCtrl = TextEditingController();
    priceCtrl = TextEditingController(
      text: product.price.toStringAsFixed(2),
    );
    stockCtrl = TextEditingController(
      text: product.stock?.toString() ?? '',
    );

    name.value = product.name;
    price.value = product.price.toStringAsFixed(2);
    stock.value = product.stock?.toString() ?? '';
    selectedEmoji.value = product.emoji;
    unlimitedStock.value = product.isUnlimitedStock;
    isActive.value = product.status == ProductStatus.active;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    super.onClose();
  }
}
