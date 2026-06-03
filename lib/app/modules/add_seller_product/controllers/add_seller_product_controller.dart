import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Enums ──────────────────────────────────────────────────────────────────────

enum ProductTypeOption { physical, digital, educational, subscription }

enum AddProductStep { type, details }

// ── Type metadata ──────────────────────────────────────────────────────────────

class ProductTypeData {
  final ProductTypeOption type;
  final String emoji;
  final String name;
  final String subtitle;

  const ProductTypeData({
    required this.type,
    required this.emoji,
    required this.name,
    required this.subtitle,
  });
}

const List<ProductTypeData> kProductTypes = [
  ProductTypeData(
    type: ProductTypeOption.physical,
    emoji: '📦',
    name: 'Physical',
    subtitle: 'Tangible goods',
  ),
  ProductTypeData(
    type: ProductTypeOption.digital,
    emoji: '💾',
    name: 'Digital',
    subtitle: 'Files & downloads',
  ),
  ProductTypeData(
    type: ProductTypeOption.educational,
    emoji: '📚',
    name: 'Educational',
    subtitle: 'Worksheets & courses',
  ),
  ProductTypeData(
    type: ProductTypeOption.subscription,
    emoji: '🔄',
    name: 'Subscription',
    subtitle: 'Recurring billing',
  ),
];

// ── Controller ─────────────────────────────────────────────────────────────────

class AddSellerProductController extends GetxController {
  final Rx<AddProductStep> step = AddProductStep.type.obs;
  final Rx<ProductTypeOption?> selectedType = Rx(null);
  final RxBool isSaving = false.obs;

  // Form reactive values
  final RxString productName = ''.obs;
  final RxString description = ''.obs;
  final RxString price = ''.obs;
  final RxString stock = ''.obs;
  final RxBool unlimitedStock = false.obs;
  final RxBool saveAsDraft = false.obs;

  // TextEditingControllers
  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController stockCtrl;

  // ── Computed ─────────────────────────────────────────────────────────────────

  bool get isPhysical => selectedType.value == ProductTypeOption.physical;

  bool get needsStock => isPhysical && !unlimitedStock.value;

  bool get isOnLastStep => step.value == AddProductStep.details;

  bool get canProceed {
    switch (step.value) {
      case AddProductStep.type:
        return selectedType.value != null;
      case AddProductStep.details:
        return productName.value.trim().isNotEmpty &&
            price.value.trim().isNotEmpty;
    }
  }

  String get selectedTypeEmoji {
    final t = kProductTypes.firstWhereOrNull((t) => t.type == selectedType.value);
    return t?.emoji ?? '📦';
  }

  String get selectedTypeName {
    final t = kProductTypes.firstWhereOrNull((t) => t.type == selectedType.value);
    return t?.name ?? '';
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  void selectType(ProductTypeOption type) {
    selectedType.value = type;
    if (type != ProductTypeOption.physical) unlimitedStock.value = true;
  }

  void goNext() {
    if (step.value == AddProductStep.type) {
      step.value = AddProductStep.details;
    }
  }

  void goBack() {
    if (step.value == AddProductStep.details) {
      step.value = AddProductStep.type;
    } else {
      Get.back();
    }
  }

  Future<void> publish() async {
    if (isSaving.value || !canProceed) return;
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isSaving.value = false;
    Get.back();
    Get.snackbar(
      '',
      saveAsDraft.value ? 'Product saved as draft' : 'Product published successfully!',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController();
    descCtrl = TextEditingController();
    priceCtrl = TextEditingController();
    stockCtrl = TextEditingController();
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
