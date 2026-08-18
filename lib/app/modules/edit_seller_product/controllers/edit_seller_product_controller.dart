import 'dart:async';
import 'dart:io';

import 'package:book_store_app/app/data/models/common_models/variant_entry.dart';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart'
    show DigitalFileEntry, ProductPublishMode;
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/utils/custom_alert_dialog_util.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

const List<String> kProductEmojis = [
  '📐',
  '☕',
  '🖼️',
  '➗',
  '🔬',
  '🧩',
  '📚',
  '📋',
  '💾',
  '🎨',
  '🧴',
  '👜',
  '📦',
  '🕯️',
  '✏️',
  '📷',
  '🎀',
  '📔',
  '💧',
  '🗝️',
  '🍜',
  '🐝',
  '🧸',
  '🎯',
  '🏆',
  '💡',
  '🔮',
  '🌿',
  '📱',
  '🖥️',
];

class EditSellerProductController extends GetxController {
  EditSellerProductController({
    SellerProductRepository? repository,
    UploadRepository? uploadRepository,
    ProductRepository? productRepository,
    SellerProduct? initialProduct,
  }) : _repo = repository ?? SellerProductRepository(),
       _uploadRepo = uploadRepository ?? UploadRepository(),
       _productRepo = productRepository ?? ProductRepository(),
       _initialProduct = initialProduct;

  final SellerProductRepository _repo;
  final UploadRepository _uploadRepo;
  final ProductRepository _productRepo;
  // Testing seam: `Get.arguments` has no public setter and the previous
  // unchecked `as SellerProduct` cast throws immediately if this route is
  // ever pushed without arguments (or with the wrong type) — accepting an
  // optional override here both makes this controller unit-testable and
  // removes that crash risk.
  final SellerProduct? _initialProduct;

  late SellerProduct product;

  // ── Core text controllers ─────────────────────────────────────────────────
  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController compareAtPriceCtrl;
  late final TextEditingController tagsCtrl;
  // Digital-only
  late final TextEditingController downloadLimitCountCtrl;
  late final TextEditingController linkExpiryDaysCtrl;
  late final TextEditingController buyerDeliveryMsgCtrl;

  // ── Core reactive state ───────────────────────────────────────────────────
  final RxString name = ''.obs;
  final RxString description = ''.obs;
  final RxString price = ''.obs;
  final RxString compareAtPrice = ''.obs;
  final RxString selectedEmoji = '📦'.obs;
  final Rx<ProductPublishMode> publishMode = ProductPublishMode.now.obs;
  final Rxn<DateTime> scheduledAt = Rxn<DateTime>();
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  // Product images (shared)
  final RxList<String> productImages = <String>[].obs;
  final RxBool isUploadingImage = false.obs;
  final RxString tags = ''.obs;
  // Physical-only: variants (each carries its own price/stock/attributes/images)
  final RxList<VariantEntry> variants = <VariantEntry>[].obs;
  final RxBool isLoadingVariants = false.obs;
  final List<String> _pendingVariantDeletions = [];
  // Digital-only
  final RxList<DigitalFileEntry> digitalFiles = <DigitalFileEntry>[].obs;
  final RxBool unlimitedDownload = true.obs;
  final RxString downloadLimitCount = ''.obs;
  final RxString linkExpiryDays = ''.obs;
  final RxBool pdfStampingEnabled = false.obs;
  final RxString licenseType = 'personal'.obs;
  final RxString buyerDeliveryMessage = ''.obs;
  // Watermarked/trimmed pre-purchase preview, derived server-side from the
  // first uploaded file (see solvexo-api ProductsService.prepareDigitalPreview).
  final RxBool previewEnabled = false.obs;
  // Educational-only
  late final TextEditingController customLevelCtrl;
  final Rxn<String> educationLevel = Rxn<String>();
  final RxString customLevel = ''.obs;
  final RxList<String> customLevelSuggestions = <String>[].obs;
  final RxBool isLoadingSuggestions = false.obs;
  Timer? _suggestDebounce;

  // ── Computed ──────────────────────────────────────────────────────────────

  bool get isPhysical => product.type == 'Physical';
  bool get isDigital => product.type == 'Digital';
  bool get isEducational => product.type == 'Educational';
  bool get needsCustomLevel => isEducational && educationLevel.value == 'other';

  bool get canSave {
    final hasValidPrice = isPhysical
        ? variants.isNotEmpty &&
            variants.every((v) => double.tryParse(v.priceCtrl.text.trim()) != null)
        : price.value.trim().isNotEmpty;
    return name.value.trim().isNotEmpty &&
        hasValidPrice &&
        (publishMode.value != ProductPublishMode.scheduled ||
            scheduledAt.value != null) &&
        (!isEducational || educationLevel.value != null) &&
        (!needsCustomLevel || customLevel.value.trim().isNotEmpty);
  }

  void selectEducationLevel(String? level) {
    educationLevel.value = level;
    if (level != 'other') {
      customLevel.value = '';
      customLevelCtrl.clear();
      customLevelSuggestions.clear();
    }
  }

  void onCustomLevelChanged(String value) {
    customLevel.value = value;
    _suggestDebounce?.cancel();
    if (value.trim().isEmpty) {
      customLevelSuggestions.clear();
      return;
    }
    _suggestDebounce = Timer(const Duration(milliseconds: 350), () async {
      isLoadingSuggestions.value = true;
      final results = await _productRepo.getCustomLevelSuggestions(
        value.trim(),
      );
      isLoadingSuggestions.value = false;
      customLevelSuggestions.assignAll(results);
    });
  }

  void selectCustomLevelSuggestion(String value) {
    customLevel.value = value;
    customLevelCtrl.text = value;
    customLevelSuggestions.clear();
  }

  /// The product's publish mode as it was when the screen opened, derived
  /// from its list-level [ProductStatus] (active/lowStock/outOfStock all
  /// mean the product itself is live, just annotated with stock info).
  ProductPublishMode get _initialPublishMode => switch (product.status) {
    ProductStatus.draft => ProductPublishMode.draft,
    ProductStatus.scheduled => ProductPublishMode.scheduled,
    _ => ProductPublishMode.now,
  };

  bool get hasChanges =>
      name.value != product.name ||
      price.value != product.price.toStringAsFixed(2) ||
      selectedEmoji.value != product.emoji ||
      publishMode.value != _initialPublishMode ||
      scheduledAt.value != product.scheduledAt;

  // ── Product image management ──────────────────────────────────────────────

  Future<void> pickAndUploadImage() async {
    if (isUploadingImage.value || productImages.length >= 5) return;
    isUploadingImage.value = true;
    final url = await _uploadRepo.pickAndUpload(source: ImageSource.gallery);
    isUploadingImage.value = false;
    if (url != null) productImages.add(url);
  }

  void removeImage(int index) {
    if (index < productImages.length) productImages.removeAt(index);
  }

  // ── Variant management (physical products) ─────────────────────────────────

  Future<void> _loadVariants() async {
    isLoadingVariants.value = true;
    final result = await _repo.getMyProduct(product.id);
    isLoadingVariants.value = false;

    for (final v in result.variants) {
      final entry = VariantEntry(price: (v['price'] as num?)?.toString() ?? '');
      entry.compareAtPriceCtrl.text = v['compareAtPrice']?.toString() ?? '';
      entry.stockCtrl.text = v['stock']?.toString() ?? '';
      entry.unlimitedStock.value = v['unlimitedStock'] as bool? ?? false;
      entry.shippingWeightCtrl.text = v['shippingWeight'] as String? ?? '';
      entry.images.assignAll((v['images'] as List?)?.cast<String>() ?? const []);
      entry.isDefault.value = v['isDefault'] as bool? ?? false;
      for (final o in (v['options'] as List? ?? [])) {
        final opt = o as Map<String, dynamic>;
        entry.options.add(VariantOptionEntry(
          name: opt['name'] as String? ?? '',
          value: opt['value'] as String? ?? '',
        ));
      }
      entry.remoteId = v['_id'] as String?;
      variants.add(entry);
    }

    if (variants.isEmpty) variants.add(VariantEntry()..isDefault.value = true);
  }

  void addVariant() => variants.add(VariantEntry());

  void removeVariant(int index) {
    if (variants.length <= 1) {
      ToastUtil.showToast('A product needs at least one variant.');
      return;
    }
    final entry = variants[index];
    if (entry.remoteId == null) {
      variants.removeAt(index);
      if (!variants.any((v) => v.isDefault.value)) {
        variants.first.isDefault.value = true;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => entry.dispose());
      return;
    }

    showCustomDialog(
      title: 'Remove this variant?',
      content: 'This will delete the variant when you save changes.',
      rightButtonName: 'Remove',
      leftButtonName: 'Cancel',
      onLeftButtonTap: Get.back,
      onRightButtonTap: () {
        Get.back();
        _pendingVariantDeletions.add(entry.remoteId!);
        variants.removeAt(index);
        if (!variants.any((v) => v.isDefault.value)) {
          variants.first.isDefault.value = true;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => entry.dispose());
      },
    );
  }

  void setDefaultVariant(int index) {
    for (var i = 0; i < variants.length; i++) {
      variants[i].isDefault.value = i == index;
    }
  }

  Future<void> pickAndUploadVariantImage(int index) async {
    final v = variants[index];
    if (v.isUploadingImage.value || v.images.length >= 5) return;
    v.isUploadingImage.value = true;
    final url = await _uploadRepo.pickAndUpload(source: ImageSource.gallery);
    v.isUploadingImage.value = false;
    if (url != null) v.images.add(url);
  }

  void removeVariantImage(int variantIndex, int imageIndex) {
    final v = variants[variantIndex];
    if (imageIndex < v.images.length) v.images.removeAt(imageIndex);
  }

  // ── Digital file management ───────────────────────────────────────────────

  void addDigitalFile() => digitalFiles.add(DigitalFileEntry());

  void removeDigitalFile(int index) {
    if (index < digitalFiles.length) {
      final removed = digitalFiles.removeAt(index);
      WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
    }
  }

  Future<void> pickAndUploadDigitalFile(int index) async {
    if (index >= digitalFiles.length) return;

    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    final entry = digitalFiles[index];
    entry.isUploading.value = true;

    final data = await _uploadRepo.uploadPrivateFile(File(picked.path!));

    entry.isUploading.value = false;

    if (data == null) {
      ToastUtil.showToast('File upload failed. Please try again.');
      return;
    }

    entry.publicId.value = data['publicId'] as String? ?? '';
    entry.fileName.value = data['fileName'] as String? ?? picked.name;
    entry.fileSize.value = data['fileSize'] as int? ?? 0;
    entry.mimeType.value = data['mimeType'] as String? ?? '';

    if (entry.nameCtrl.text.trim().isEmpty) {
      entry.nameCtrl.text = data['fileName'] as String? ?? picked.name;
    }

    digitalFiles.refresh();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void pickEmoji(String emoji) {
    selectedEmoji.value = emoji;
    Get.back();
  }

  Future<void> saveChanges() async {
    if (!canSave || isSaving.value) return;
    isSaving.value = true;

    if (!isPhysical) {
      final parsedPrice = double.tryParse(priceCtrl.text.trim());
      if (parsedPrice == null) {
        ToastUtil.showToast('Please enter a valid price.');
        isSaving.value = false;
        return;
      }

      if (isEducational) {
        if (educationLevel.value == null) {
          ToastUtil.showToast('Please select an education level.');
          isSaving.value = false;
          return;
        }
        if (needsCustomLevel && customLevel.value.trim().isEmpty) {
          ToastUtil.showToast('Please enter a custom level.');
          isSaving.value = false;
          return;
        }
      }

      final success = await _saveDigital(parsedPrice);
      isSaving.value = false;
      if (success) {
        Get.back();
        ToastUtil.showToast('Product updated successfully!');
      }
      return;
    }

    final success = await _savePhysical();
    isSaving.value = false;
    if (success) {
      Get.back();
      ToastUtil.showToast('Product updated successfully!');
    }
  }

  Future<bool> _savePhysical() async {
    // Client-side duplicate/consistency check — mirrors the backend's rules.
    String optionsKey(List options) => (options
            .map((o) => '${(o['name'] as String).trim().toLowerCase()}:${(o['value'] as String).trim().toLowerCase()}')
            .toList()
          ..sort())
        .join(',');
    String nameSetKey(List options) =>
        ((options).map((o) => (o['name'] as String).trim().toLowerCase()).toList()..sort()).join('|');

    final variantJsonList = <Map<String, dynamic>>[];
    for (var i = 0; i < variants.length; i++) {
      final json = variants[i].toJson();
      if (json == null) {
        ToastUtil.showToast('Variant ${i + 1}: please enter a valid price.');
        return false;
      }
      variantJsonList.add(json);
    }
    final nameSets = variantJsonList.map((v) => nameSetKey(v['options'] as List)).toSet();
    if (nameSets.length > 1) {
      ToastUtil.showToast('All variants must use the same attributes.');
      return false;
    }
    final keys = variantJsonList.map((v) => optionsKey(v['options'] as List)).toList();
    if (keys.toSet().length != keys.length) {
      ToastUtil.showToast('Each variant must have a unique combination of attributes.');
      return false;
    }

    final tagList = tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final productOk = await _repo.editProductFields(
      productId: product.id,
      name: nameCtrl.text.trim(),
      status: publishMode.value.apiStatus,
      scheduledAt: scheduledAt.value?.toIso8601String(),
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      tags: tagList,
      images: productImages.toList(),
    );
    if (!productOk) return false;

    for (final id in _pendingVariantDeletions) {
      final ok = await _repo.deleteVariant(productId: product.id, variantId: id);
      if (!ok) return false;
    }
    _pendingVariantDeletions.clear();

    for (var i = 0; i < variants.length; i++) {
      final entry = variants[i];
      final json = variantJsonList[i];
      final ok = entry.remoteId == null
          ? await _repo.addVariant(productId: product.id, variant: json)
          : await _repo.updateVariant(
              productId: product.id,
              variantId: entry.remoteId!,
              variant: json,
            );
      if (!ok) return false;
    }

    return true;
  }

  Future<bool> _saveDigital(double parsedPrice) async {
    final parsedCompare = double.tryParse(compareAtPriceCtrl.text.trim());

    final files = digitalFiles
        .map((e) => e.toJson())
        .where((f) => (f['publicId'] as String).isNotEmpty)
        .toList();

    final String downloadLimit;
    if (unlimitedDownload.value) {
      downloadLimit = 'unlimited';
    } else {
      downloadLimit = downloadLimitCountCtrl.text.trim().isEmpty
          ? 'unlimited'
          : downloadLimitCountCtrl.text.trim();
    }

    final expiryRaw = linkExpiryDaysCtrl.text.trim();
    final int? parsedExpiry = expiryRaw.isEmpty
        ? null
        : int.tryParse(expiryRaw);

    final msg = buyerDeliveryMsgCtrl.text.trim();

    return _repo.editDigitalProduct(
      productId: product.id,
      variantId: product.variantId,
      name: nameCtrl.text.trim(),
      price: parsedPrice,
      status: publishMode.value.apiStatus,
      scheduledAt: scheduledAt.value?.toIso8601String(),
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      compareAtPrice: parsedCompare,
      files: files,
      downloadLimit: downloadLimit,
      linkExpiryDays: parsedExpiry,
      pdfStampingEnabled: pdfStampingEnabled.value,
      licenseType: licenseType.value,
      buyerDeliveryMessage: msg.isEmpty ? null : msg,
      previewEnabled: previewEnabled.value,
      images: productImages.toList(),
      educationLevel: isEducational ? educationLevel.value : null,
      customLevel: needsCustomLevel ? customLevel.value.trim() : null,
    );
  }

  Future<void> deleteProduct() async {
    isDeleting.value = true;
    final ok = await _repo.deleteProduct(product.id);
    isDeleting.value = false;
    if (ok) {
      Get.back(result: true);
      ToastUtil.showToast('${product.name} deleted.');
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    product = _initialProduct ?? Get.arguments as SellerProduct;

    // Core
    nameCtrl = TextEditingController(text: product.name);
    descCtrl = TextEditingController(text: product.description ?? '');
    priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));
    compareAtPriceCtrl = TextEditingController(
      text: product.compareAtPrice != null
          ? product.compareAtPrice!.toStringAsFixed(2)
          : '',
    );
    tagsCtrl = TextEditingController(text: product.tags.join(', '));
    // Digital
    final isUnlimitedDl = product.downloadLimit == 'unlimited';
    downloadLimitCountCtrl = TextEditingController(
      text: isUnlimitedDl ? '' : product.downloadLimit,
    );
    linkExpiryDaysCtrl = TextEditingController(
      text: product.linkExpiryDays?.toString() ?? '',
    );
    buyerDeliveryMsgCtrl = TextEditingController(
      text: product.buyerDeliveryMessage ?? '',
    );
    customLevelCtrl = TextEditingController(text: product.customLevel ?? '');

    // Reactive values
    name.value = product.name;
    price.value = product.price.toStringAsFixed(2);
    description.value = product.description ?? '';
    compareAtPrice.value = product.compareAtPrice?.toStringAsFixed(2) ?? '';
    tags.value = product.tags.join(', ');
    selectedEmoji.value = product.emoji;
    publishMode.value = _initialPublishMode;
    scheduledAt.value = product.scheduledAt;
    productImages.assignAll(product.images);
    unlimitedDownload.value = isUnlimitedDl;
    downloadLimitCount.value = isUnlimitedDl ? '' : product.downloadLimit;
    linkExpiryDays.value = product.linkExpiryDays?.toString() ?? '';
    pdfStampingEnabled.value = product.pdfStampingEnabled;
    licenseType.value = product.licenseType;
    buyerDeliveryMessage.value = product.buyerDeliveryMessage ?? '';
    previewEnabled.value = product.previewEnabled;
    educationLevel.value = product.educationLevel;
    customLevel.value = product.customLevel ?? '';

    // Pre-fill digital file entries from existing product data
    for (final f in product.digitalFiles) {
      final entry = DigitalFileEntry();
      // Accept both new 'publicId' and legacy 'url' field
      entry.publicId.value =
          f['publicId'] as String? ?? f['url'] as String? ?? '';
      entry.fileName.value = f['name'] as String? ?? '';
      entry.mimeType.value = f['mimeType'] as String? ?? '';
      entry.fileSize.value = f['size'] as int? ?? 0;
      entry.nameCtrl.text = f['name'] as String? ?? '';
      digitalFiles.add(entry);
    }

    if (isPhysical) unawaited(_loadVariants());
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    compareAtPriceCtrl.dispose();
    tagsCtrl.dispose();
    downloadLimitCountCtrl.dispose();
    linkExpiryDaysCtrl.dispose();
    buyerDeliveryMsgCtrl.dispose();
    customLevelCtrl.dispose();
    _suggestDebounce?.cancel();
    for (final f in digitalFiles) {
      f.dispose();
    }
    for (final v in variants) {
      v.dispose();
    }
    super.onClose();
  }
}
