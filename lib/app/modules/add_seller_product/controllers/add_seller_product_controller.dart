import 'dart:async';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/category_repository.dart';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ── Enums ──────────────────────────────────────────────────────────────────────

enum ProductTypeOption { physical, digital, educational, subscription }

enum AddProductStep { type, details }

/// How a product should go live. Mirrors the backend's `status` field
/// ('active' | 'draft' | 'scheduled') — `scheduled` additionally requires
/// a `scheduledAt` date, enforced both here and server-side.
enum ProductPublishMode {
  now,
  scheduled,
  draft;

  String get apiStatus => switch (this) {
    ProductPublishMode.now => 'active',
    ProductPublishMode.scheduled => 'scheduled',
    ProductPublishMode.draft => 'draft',
  };

  static ProductPublishMode fromApiStatus(String? status) => switch (status) {
    'scheduled' => ProductPublishMode.scheduled,
    'draft' => ProductPublishMode.draft,
    _ => ProductPublishMode.now,
  };
}

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

// ── Digital file entry ─────────────────────────────────────────────────────────

class DigitalFileEntry {
  final RxString publicId = ''.obs;
  final RxString fileName = ''.obs;
  final RxInt fileSize = 0.obs; // bytes
  final RxString mimeType = ''.obs;
  final RxBool isUploading = false.obs;

  // Optional display name override; auto-filled from fileName after upload
  final TextEditingController nameCtrl;

  DigitalFileEntry() : nameCtrl = TextEditingController();

  bool get isUploaded => publicId.value.isNotEmpty;

  void dispose() => nameCtrl.dispose();

  Map<String, dynamic> toJson() => {
    'publicId': publicId.value,
    'name': nameCtrl.text.trim().isEmpty
        ? fileName.value
        : nameCtrl.text.trim(),
    'size': fileSize.value,
    'mimeType': mimeType.value,
  };

  String get displaySize {
    final b = fileSize.value;
    if (b <= 0) return '';
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ── Controller ─────────────────────────────────────────────────────────────────

// Maps the store's API product type strings to our local enum.
const _kApiToProductType = {
  'physical_products': ProductTypeOption.physical,
  'digital_downloads': ProductTypeOption.digital,
  'educational_resources': ProductTypeOption.educational,
  'subscriptions': ProductTypeOption.subscription,
};

class AddSellerProductController extends GetxController {
  AddSellerProductController({
    SellerProductRepository? repository,
    SellerRepository? sellerRepository,
    UploadRepository? uploadRepository,
    CategoryRepository? categoryRepository,
    ProductRepository? productRepository,
  }) : _repo = repository ?? SellerProductRepository(),
       _sellerRepo = sellerRepository ?? SellerRepository(),
       _uploadRepo = uploadRepository ?? UploadRepository(),
       _categoryRepo = categoryRepository ?? CategoryRepository(),
       _productRepo = productRepository ?? ProductRepository();

  final SellerProductRepository _repo;
  final SellerRepository _sellerRepo;
  final UploadRepository _uploadRepo;
  final CategoryRepository _categoryRepo;
  final ProductRepository _productRepo;

  final Rx<AddProductStep> step = AddProductStep.type.obs;
  final Rx<ProductTypeOption?> selectedType = Rx(null);
  final RxBool isSaving = false.obs;

  // Allowed types fetched from the store's registered product types.
  final RxList<ProductTypeOption> _allowedTypes = <ProductTypeOption>[].obs;
  final RxBool isLoadingTypes = true.obs;

  // ── Subcategory (optional) ────────────────────────────────────────────────
  // The store's own main category (admin-curated, fixed at store creation).
  // Subcategories are optional — a seller may pick one of the existing
  // subcategories under it, add a new one on the fly, or leave it unset.
  String? _mainCategoryId;
  final RxList<CategoryModel> subcategories = <CategoryModel>[].obs;
  final RxBool isLoadingSubcategories = false.obs;
  final Rxn<String> selectedSubCategoryId = Rxn<String>();
  final RxString selectedSubCategoryName = ''.obs;

  // ── Core form reactive values ─────────────────────────────────────────────
  final RxString productName = ''.obs;
  final RxString description = ''.obs;
  final RxString price = ''.obs;
  final RxString stock = ''.obs;
  final RxBool unlimitedStock = false.obs;
  final Rx<ProductPublishMode> publishMode = ProductPublishMode.now.obs;
  final Rxn<DateTime> scheduledAt = Rxn<DateTime>();

  // ── Shared (physical + digital) ───────────────────────────────────────────
  final RxString compareAtPrice = ''.obs;
  final RxString tags = ''.obs;
  final RxBool isListedOnSolvexo = false.obs;

  // ── Physical-only reactive values ─────────────────────────────────────────
  final RxString size = ''.obs;
  final RxString color = ''.obs;
  final RxString shippingWeight = ''.obs;

  // ── Product images (shared) ───────────────────────────────────────────────
  final RxList<String> productImages = <String>[].obs;
  final RxBool isUploadingImage = false.obs;

  // ── Digital-only reactive values ──────────────────────────────────────────
  final RxList<DigitalFileEntry> digitalFiles = <DigitalFileEntry>[].obs;
  final RxBool unlimitedDownload = true.obs; // true = "unlimited"
  final RxString downloadLimitCount =
      ''.obs; // used when unlimitedDownload=false
  final RxString linkExpiryDays = ''.obs;
  final RxBool pdfStampingEnabled = false.obs;
  final RxString licenseType = 'personal'.obs; // "personal" | "commercial"
  final RxString buyerDeliveryMessage = ''.obs;
  // Watermarked/trimmed pre-purchase preview, derived server-side from the
  // first uploaded file (see solvexo-api ProductsService.prepareDigitalPreview).
  final RxBool previewEnabled = false.obs;

  // ── Educational-only reactive values ──────────────────────────────────────
  // Educational products are published through the digital endpoint (see
  // `_publishDigital`), tagged with `productType: 'educational'` plus these.
  final Rxn<String> educationLevel = Rxn<String>();
  final RxString customLevel = ''.obs;
  final RxList<String> customLevelSuggestions = <String>[].obs;
  final RxBool isLoadingSuggestions = false.obs;
  Timer? _suggestDebounce;
  late final TextEditingController customLevelCtrl;

  bool get needsCustomLevel => isEducational && educationLevel.value == 'other';

  void selectEducationLevel(String? level) {
    educationLevel.value = level;
    if (level != 'other') {
      customLevel.value = '';
      customLevelCtrl.clear();
      customLevelSuggestions.clear();
    }
  }

  /// Debounced autocomplete while the seller types a custom level.
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

  /// Product types the seller's store supports.
  /// Falls back to the full list while loading or if the fetch fails.
  List<ProductTypeData> get availableTypes {
    if (_allowedTypes.isEmpty) return kProductTypes;
    return kProductTypes.where((t) => _allowedTypes.contains(t.type)).toList();
  }

  bool get isPhysical => selectedType.value == ProductTypeOption.physical;
  bool get isDigital => selectedType.value == ProductTypeOption.digital;
  bool get isEducational => selectedType.value == ProductTypeOption.educational;

  bool get needsStock => isPhysical && !unlimitedStock.value;

  bool get isOnLastStep => step.value == AddProductStep.details;

  bool get canProceed {
    switch (step.value) {
      case AddProductStep.type:
        return selectedType.value != null;
      case AddProductStep.details:
        final needsSchedule = publishMode.value == ProductPublishMode.scheduled;
        return productName.value.trim().isNotEmpty &&
            price.value.trim().isNotEmpty &&
            (!needsSchedule || scheduledAt.value != null) &&
            (!isEducational || educationLevel.value != null) &&
            (!needsCustomLevel || customLevel.value.trim().isNotEmpty);
    }
  }

  String get selectedTypeEmoji {
    final t = kProductTypes.firstWhereOrNull(
      (t) => t.type == selectedType.value,
    );
    return t?.emoji ?? '📦';
  }

  String get selectedTypeName {
    final t = kProductTypes.firstWhereOrNull(
      (t) => t.type == selectedType.value,
    );
    return t?.name ?? '';
  }

  // ── Store type loading ────────────────────────────────────────────────────────

  Future<void> _loadStoreTypes() async {
    isLoadingTypes.value = true;
    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) return;

      final store = await _sellerRepo.getStoreById(storeId);
      if (store == null) return;

      final mapped = store.productTypes
          .map((s) => _kApiToProductType[s])
          .whereType<ProductTypeOption>()
          .toList();

      if (mapped.isNotEmpty) _allowedTypes.assignAll(mapped);

      _mainCategoryId = store.categoryId;
      if (_mainCategoryId != null && _mainCategoryId!.isNotEmpty) {
        unawaited(_loadSubcategories());
      }
    } finally {
      isLoadingTypes.value = false;
    }
  }

  // ── Subcategory (optional) ────────────────────────────────────────────────

  Future<void> _loadSubcategories() async {
    final mainId = _mainCategoryId;
    if (mainId == null || mainId.isEmpty) return;

    isLoadingSubcategories.value = true;
    final tree = await _categoryRepo.getCategoryTreeById(mainId);
    subcategories.assignAll(tree?.children ?? const []);
    isLoadingSubcategories.value = false;
  }

  void selectSubCategory(String? categoryId) {
    selectedSubCategoryId.value = categoryId;
    selectedSubCategoryName.value = categoryId == null
        ? ''
        : (subcategories.firstWhereOrNull((c) => c.id == categoryId)?.name ??
              '');
  }

  /// Lets a seller optionally add a new subcategory under their store's main
  /// category — main categories stay admin-only, this only ever nests one
  /// level under an existing one (enforced server-side too).
  Future<CategoryModel?> createSubcategory(String name) async {
    final mainId = _mainCategoryId;
    if (mainId == null || mainId.isEmpty) {
      ToastUtil.showToast('Your store has no main category set.');
      return null;
    }
    if (name.trim().isEmpty) return null;

    final created = await _categoryRepo.createCategory(
      name: name.trim(),
      parentId: mainId,
    );
    if (created != null) {
      subcategories.add(created);
      selectSubCategory(created.id);
      ToastUtil.showToast('Subcategory added');
    }
    return created;
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  void selectType(ProductTypeOption type) {
    selectedType.value = type;
    if (type != ProductTypeOption.physical) unlimitedStock.value = true;
    if (type != ProductTypeOption.educational) selectEducationLevel(null);
  }

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

  // ── Digital file management ───────────────────────────────────────────────

  void addDigitalFile() => digitalFiles.add(DigitalFileEntry());

  void removeDigitalFile(int index) {
    if (index < digitalFiles.length) {
      digitalFiles[index].dispose();
      digitalFiles.removeAt(index);
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
    } else if (isDigital || isEducational) {
      success = await _publishDigital();
    } else {
      // Other product types coming soon
      await Future.delayed(const Duration(milliseconds: 800));
      success = true;
    }

    isSaving.value = false;

    if (success) {
      Get.back();
      ToastUtil.showToast(switch (publishMode.value) {
        ProductPublishMode.draft => 'Product saved as draft',
        ProductPublishMode.scheduled =>
          'Product scheduled — it will go live automatically.',
        ProductPublishMode.now => 'Product published successfully!',
      });
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

    if (isEducational) {
      if (educationLevel.value == null) {
        ToastUtil.showToast('Please select an education level.');
        return false;
      }
      if (needsCustomLevel && customLevel.value.trim().isEmpty) {
        ToastUtil.showToast('Please enter a custom level.');
        return false;
      }
    }

    final parsedCompare = double.tryParse(compareAtPriceCtrl.text.trim());

    final tagList = tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

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

    final expiryDaysRaw = linkExpiryDaysCtrl.text.trim();
    final int? parsedExpiry = expiryDaysRaw.isEmpty
        ? null
        : int.tryParse(expiryDaysRaw);

    final msg = buyerDeliveryMsgCtrl.text.trim();

    return _repo.addDigitalProduct(
      storeId: storeId,
      name: nameCtrl.text.trim(),
      price: parsedPrice,
      status: publishMode.value.apiStatus,
      scheduledAt: scheduledAt.value?.toIso8601String(),
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      compareAtPrice: parsedCompare,
      tags: tagList,
      images: productImages.toList(),
      isListedOnSolvexo: isListedOnSolvexo.value,
      subCategoryId: selectedSubCategoryId.value,
      files: files,
      downloadLimit: downloadLimit,
      linkExpiryDays: parsedExpiry,
      pdfStampingEnabled: pdfStampingEnabled.value,
      licenseType: licenseType.value,
      buyerDeliveryMessage: msg.isEmpty ? null : msg,
      previewEnabled: previewEnabled.value,
      productType: isEducational ? 'educational' : 'digital',
      educationLevel: isEducational ? educationLevel.value : null,
      customLevel: needsCustomLevel ? customLevel.value.trim() : null,
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

    final parsedCompare = double.tryParse(compareAtPriceCtrl.text.trim());
    final parsedStock = needsStock ? int.tryParse(stockCtrl.text.trim()) : null;

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
      status: publishMode.value.apiStatus,
      scheduledAt: scheduledAt.value?.toIso8601String(),
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      compareAtPrice: parsedCompare,
      stock: parsedStock,
      unlimitedStock: unlimitedStock.value,
      size: sizeCtrl.text.trim().isEmpty ? null : sizeCtrl.text.trim(),
      color: colorCtrl.text.trim().isEmpty ? null : colorCtrl.text.trim(),
      shippingWeight: shippingWeightCtrl.text.trim().isEmpty
          ? null
          : shippingWeightCtrl.text.trim(),
      tags: tagList,
      images: productImages.toList(),
      isListedOnSolvexo: isListedOnSolvexo.value,
      subCategoryId: selectedSubCategoryId.value,
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadStoreTypes();
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
    customLevelCtrl = TextEditingController();
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
    customLevelCtrl.dispose();
    _suggestDebounce?.cancel();
    for (final f in digitalFiles) {
      f.dispose();
    }
    super.onClose();
  }
}
