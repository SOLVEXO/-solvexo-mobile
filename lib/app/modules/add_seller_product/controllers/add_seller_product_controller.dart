import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
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

// ── Digital file entry (holds its own text controllers) ───────────────────────

class DigitalFileEntry {
  final TextEditingController urlCtrl;
  final TextEditingController nameCtrl;

  DigitalFileEntry()
      : urlCtrl = TextEditingController(),
        nameCtrl = TextEditingController();

  void dispose() {
    urlCtrl.dispose();
    nameCtrl.dispose();
  }

  Map<String, dynamic> toJson() => {
        'url': urlCtrl.text.trim(),
        'name': nameCtrl.text.trim(),
        'size': 0,
        'mimeType': _mimeFromName(nameCtrl.text.trim()),
      };

  static String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    const map = {
      'pdf': 'application/pdf',
      'zip': 'application/zip',
      'mp4': 'video/mp4',
      'mp3': 'audio/mpeg',
      'png': 'image/png',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    };
    return map[ext] ?? 'application/octet-stream';
  }
}

// ── Controller ─────────────────────────────────────────────────────────────────

class AddSellerProductController extends GetxController {
  final _repo = SellerProductRepository();

  final Rx<AddProductStep> step = AddProductStep.type.obs;
  final Rx<ProductTypeOption?> selectedType = Rx(null);
  final RxBool isSaving = false.obs;

  // ── Core form reactive values ─────────────────────────────────────────────
  final RxString productName = ''.obs;
  final RxString description = ''.obs;
  final RxString price = ''.obs;
  final RxString stock = ''.obs;
  final RxBool unlimitedStock = false.obs;
  final RxBool saveAsDraft = false.obs;

  // ── Shared (physical + digital) ───────────────────────────────────────────
  final RxString compareAtPrice = ''.obs;
  final RxString tags = ''.obs;
  final RxBool isListedOnSolvexo = false.obs;

  // ── Physical-only reactive values ─────────────────────────────────────────
  final RxString size = ''.obs;
  final RxString color = ''.obs;
  final RxString shippingWeight = ''.obs;

  // ── Digital-only reactive values ──────────────────────────────────────────
  final RxList<DigitalFileEntry> digitalFiles = <DigitalFileEntry>[].obs;
  final RxBool unlimitedDownload = true.obs;   // true = "unlimited"
  final RxString downloadLimitCount = ''.obs;  // used when unlimitedDownload=false
  final RxString linkExpiryDays = ''.obs;
  final RxBool pdfStampingEnabled = false.obs;
  final RxString licenseType = 'personal'.obs; // "personal" | "commercial"
  final RxString buyerDeliveryMessage = ''.obs;

  // ── TextEditingControllers ────────────────────────────────────────────────
  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController stockCtrl;
  late final TextEditingController compareAtPriceCtrl;
  late final TextEditingController tagsCtrl;
  // Physical
  late final TextEditingController sizeCtrl;
  late final TextEditingController colorCtrl;
  late final TextEditingController shippingWeightCtrl;
  // Digital
  late final TextEditingController downloadLimitCountCtrl;
  late final TextEditingController linkExpiryDaysCtrl;
  late final TextEditingController buyerDeliveryMsgCtrl;

  // ── Computed ─────────────────────────────────────────────────────────────────

  bool get isPhysical => selectedType.value == ProductTypeOption.physical;
  bool get isDigital => selectedType.value == ProductTypeOption.digital;

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
    final t =
        kProductTypes.firstWhereOrNull((t) => t.type == selectedType.value);
    return t?.emoji ?? '📦';
  }

  String get selectedTypeName {
    final t =
        kProductTypes.firstWhereOrNull((t) => t.type == selectedType.value);
    return t?.name ?? '';
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  void selectType(ProductTypeOption type) {
    selectedType.value = type;
    if (type != ProductTypeOption.physical) unlimitedStock.value = true;
  }

  // ── Digital file management ───────────────────────────────────────────────

  void addDigitalFile() => digitalFiles.add(DigitalFileEntry());

  void removeDigitalFile(int index) {
    if (index < digitalFiles.length) {
      digitalFiles[index].dispose();
      digitalFiles.removeAt(index);
    }
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

    final bool success;

    if (isPhysical) {
      success = await _publishPhysical();
    } else if (isDigital) {
      success = await _publishDigital();
    } else {
      // Other product types coming soon
      await Future.delayed(const Duration(milliseconds: 800));
      success = true;
    }

    isSaving.value = false;

    if (success) {
      Get.back();
      ToastUtil.showToast(
        saveAsDraft.value
            ? 'Product saved as draft'
            : 'Product published successfully!',
      );
    }
  }

  Future<bool> _publishDigital() async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      ToastUtil.showToast('No store found. Please set up your store first.');
      return false;
    }

    final parsedPrice = double.tryParse(priceCtrl.text.trim());
    if (parsedPrice == null) {
      ToastUtil.showToast('Please enter a valid price.');
      return false;
    }

    final parsedCompare = double.tryParse(compareAtPriceCtrl.text.trim());

    final tagList = tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final files = digitalFiles
        .map((e) => e.toJson())
        .where((f) => (f['url'] as String).isNotEmpty)
        .toList();

    final String downloadLimit;
    if (unlimitedDownload.value) {
      downloadLimit = 'unlimited';
    } else {
      downloadLimit = downloadLimitCountCtrl.text.trim().isEmpty
          ? 'unlimited'
          : downloadLimitCountCtrl.text.trim();
    }

    final expiryDaysRaw = linkExpiryDaysCtrl.text.trim();
    final int? parsedExpiry =
        expiryDaysRaw.isEmpty ? null : int.tryParse(expiryDaysRaw);

    final msg = buyerDeliveryMsgCtrl.text.trim();

    return _repo.addDigitalProduct(
      storeId: storeId,
      name: nameCtrl.text.trim(),
      price: parsedPrice,
      status: saveAsDraft.value ? 'draft' : 'active',
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      compareAtPrice: parsedCompare,
      tags: tagList,
      isListedOnSolvexo: isListedOnSolvexo.value,
      files: files,
      downloadLimit: downloadLimit,
      linkExpiryDays: parsedExpiry,
      pdfStampingEnabled: pdfStampingEnabled.value,
      licenseType: licenseType.value,
      buyerDeliveryMessage: msg.isEmpty ? null : msg,
    );
  }

  Future<bool> _publishPhysical() async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      ToastUtil.showToast('No store found. Please set up your store first.');
      return false;
    }

    final parsedPrice = double.tryParse(priceCtrl.text.trim());
    if (parsedPrice == null) {
      ToastUtil.showToast('Please enter a valid price.');
      return false;
    }

    final parsedCompare =
        double.tryParse(compareAtPriceCtrl.text.trim());
    final parsedStock = needsStock
        ? int.tryParse(stockCtrl.text.trim())
        : null;

    // Parse comma-separated tags
    final tagList = tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return _repo.addPhysicalProduct(
      storeId: storeId,
      name: nameCtrl.text.trim(),
      price: parsedPrice,
      status: saveAsDraft.value ? 'draft' : 'active',
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      compareAtPrice: parsedCompare,
      stock: parsedStock,
      size: sizeCtrl.text.trim().isEmpty ? null : sizeCtrl.text.trim(),
      color: colorCtrl.text.trim().isEmpty ? null : colorCtrl.text.trim(),
      shippingWeight: shippingWeightCtrl.text.trim().isEmpty
          ? null
          : shippingWeightCtrl.text.trim(),
      tags: tagList,
      isListedOnSolvexo: isListedOnSolvexo.value,
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
    compareAtPriceCtrl = TextEditingController();
    tagsCtrl = TextEditingController();
    // Physical
    sizeCtrl = TextEditingController();
    colorCtrl = TextEditingController();
    shippingWeightCtrl = TextEditingController();
    // Digital
    downloadLimitCountCtrl = TextEditingController();
    linkExpiryDaysCtrl = TextEditingController();
    buyerDeliveryMsgCtrl = TextEditingController();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    compareAtPriceCtrl.dispose();
    tagsCtrl.dispose();
    sizeCtrl.dispose();
    colorCtrl.dispose();
    shippingWeightCtrl.dispose();
    downloadLimitCountCtrl.dispose();
    linkExpiryDaysCtrl.dispose();
    buyerDeliveryMsgCtrl.dispose();
    for (final f in digitalFiles) {
      f.dispose();
    }
    super.onClose();
  }
}
