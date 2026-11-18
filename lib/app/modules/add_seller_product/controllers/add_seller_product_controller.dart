import 'dart:async';
import 'package:book_store_app/utils/price_rules.dart';
import 'dart:io';

import 'package:book_store_app/app/data/models/common_models/variant_entry.dart';
import 'package:book_store_app/app/data/repositories/category_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/seller/utils/plan_lapse.dart';
import 'package:book_store_app/app/modules/seller/utils/publish_rules.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:book_store_app/utils/upload_rules.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ── Enums ──────────────────────────────────────────────────────────────────────

// `educational` is retired (docs Part B 11; the API answers 400 "Educational
// products are no longer available. Choose digital.").
enum ProductTypeOption { physical, digital, subscription }

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
    // The API reads the stored file reference from `url` (it is the upload's
    // publicId); `publicId` alone is rejected with "A file reference is required".
    'url': publicId.value,
    'name': nameCtrl.text.trim().isEmpty
        ? fileName.value
        : nameCtrl.text.trim(),
    'size': fileSize.value,
    'mimeType': mimeType.value,
  };

  /// `digital.sampleFile` as the API stores it (verified 2026-11-17):
  /// `{url: <upload publicId>, name, size, mimeType}`.
  Map<String, dynamic> toSampleJson() => {
    'url': publicId.value,
    'name': fileName.value.isEmpty ? nameCtrl.text.trim() : fileName.value,
    'size': fileSize.value,
    'mimeType': mimeType.value,
  };

  /// Fill from a stored `{url, name, size, mimeType}` (sampleFile or files[]).
  void fillFromStored(Map<String, dynamic> f) {
    publicId.value = f['publicId'] as String? ?? f['url'] as String? ?? '';
    fileName.value = f['name'] as String? ?? '';
    mimeType.value = f['mimeType'] as String? ?? '';
    fileSize.value = (f['size'] as num?)?.toInt() ?? 0;
    nameCtrl.text = f['name'] as String? ?? '';
  }

  void clear() {
    publicId.value = '';
    fileName.value = '';
    fileSize.value = 0;
    mimeType.value = '';
    nameCtrl.clear();
  }

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
  // Legacy store type: educational was migrated to digital.
  'educational_resources': ProductTypeOption.digital,
  'subscriptions': ProductTypeOption.subscription,
};

class AddSellerProductController extends GetxController {
  AddSellerProductController({
    SellerProductRepository? repository,
    SellerRepository? sellerRepository,
    UploadRepository? uploadRepository,
    CategoryRepository? categoryRepository,
  }) : _repo = repository ?? SellerProductRepository(),
       _sellerRepo = sellerRepository ?? SellerRepository(),
       _uploadRepo = uploadRepository ?? UploadRepository(),
       _categoryRepo = categoryRepository ?? CategoryRepository();

  final SellerProductRepository _repo;
  final SellerRepository _sellerRepo;
  final UploadRepository _uploadRepo;
  final CategoryRepository _categoryRepo;

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

  /// Inline errors (ListingRules), checked before every save incl. drafts.
  final RxnString titleError = RxnString();
  final RxnString descriptionError = RxnString();

  /// Title, description and (physical) weights as the API checks them on
  /// create. Returns the first error (also set inline), or null.
  String? validateListing() {
    titleError.value = ListingRules.validateTitle(nameCtrl.text);
    descriptionError.value = ListingRules.validateDescription(descCtrl.text);
    String? weight;
    if (isPhysical) {
      for (var i = 0; i < variants.length; i++) {
        final e = ListingRules.validateWeight(variants[i].shippingWeightCtrl.text);
        variants[i].weightError.value = e;
        weight ??= e == null ? null : 'Variant ${i + 1}: $e';
      }
    }
    return titleError.value ?? descriptionError.value ?? weight;
  }
  final RxString price = ''.obs;
  final Rx<ProductPublishMode> publishMode = ProductPublishMode.now.obs;
  final Rxn<DateTime> scheduledAt = Rxn<DateTime>();

  // ── Publish fields (docs Part B 6.3; checklist #1) ────────────────────────
  // `coverStyle` is required to go live; digital also needs a class range.
  final Rxn<String> coverStyle = Rxn<String>();
  final Rxn<String> classFrom = Rxn<String>();
  final Rxn<String> classTo = Rxn<String>();
  final RxnString publishFieldsError = RxnString();

  void setCoverStyle(String v) {
    coverStyle.value = v;
    publishFieldsError.value = null;
  }

  void setClassFrom(String? v) {
    classFrom.value = v;
    // Keep the range in order: drop a "To" that is now before "From".
    if (v != null &&
        classTo.value != null &&
        PublishRules.classIndex(classTo.value) < PublishRules.classIndex(v)) {
      classTo.value = null;
    }
    publishFieldsError.value = null;
  }

  void setClassTo(String? v) {
    classTo.value = v;
    publishFieldsError.value = null;
  }

  /// Same rule the API enforces; shown inline + as a toast before any call.
  String? validatePublishFields() => PublishRules.validate(
        status: publishMode.value.apiStatus,
        isDigital: !isPhysical,
        coverStyle: coverStyle.value,
        classFrom: classFrom.value,
        classTo: classTo.value,
        hasSample: sample.isUploaded,
      );

  // ── Shared (physical + digital) ───────────────────────────────────────────
  final RxString compareAtPrice = ''.obs;
  final RxString tags = ''.obs;
  final RxBool isListedOnSolvexo = false.obs;

  // ── Product images (shared) ───────────────────────────────────────────────
  final RxList<String> productImages = <String>[].obs;
  final RxBool isUploadingImage = false.obs;

  // ── Physical-only: variants (each carries its own price/stock/options) ────
  final RxList<VariantEntry> variants = <VariantEntry>[
    VariantEntry()..isDefault.value = true,
  ].obs;

  // ── Digital-only reactive values ──────────────────────────────────────────
  final RxList<DigitalFileEntry> digitalFiles = <DigitalFileEntry>[].obs;
  // Free sample: required to publish digital (checklist #3).
  final DigitalFileEntry sample = DigitalFileEntry();
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

  // ── TextEditingControllers ────────────────────────────────────────────────
  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController compareAtPriceCtrl;
  late final TextEditingController tagsCtrl;
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

  bool get isOnLastStep => step.value == AddProductStep.details;

  bool get canProceed {
    switch (step.value) {
      case AddProductStep.type:
        return selectedType.value != null;
      case AddProductStep.details:
        final needsSchedule = publishMode.value == ProductPublishMode.scheduled;
        final hasValidPrice = isPhysical
            ? variants.isNotEmpty &&
                variants.every((v) => double.tryParse(v.priceCtrl.text.trim()) != null)
            : price.value.trim().isNotEmpty;
        return productName.value.trim().isNotEmpty &&
            hasValidPrice &&
            (!needsSchedule || scheduledAt.value != null);
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

  // ── Variant management (physical products) ─────────────────────────────────

  void addVariant() => variants.add(VariantEntry());

  void removeVariant(int index) {
    if (variants.length <= 1) {
      ToastUtil.showToast('A product needs at least one variant.');
      return;
    }
    final removed = variants.removeAt(index);
    if (!variants.any((v) => v.isDefault.value)) {
      variants.first.isDefault.value = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
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
    await _pickAndUploadInto(digitalFiles[index]);
    digitalFiles.refresh();
  }

  Future<void> pickAndUploadSample() async {
    await _pickAndUploadInto(sample);
    if (sample.isUploaded) publishFieldsError.value = null;
  }

  void removeSample() => sample.clear();

  Future<void> _pickAndUploadInto(DigitalFileEntry entry) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: UploadRules.privateExtensions,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.path == null) return;

    entry.isUploading.value = true;

    final data = await _uploadRepo.uploadPrivateFile(File(picked.path!));

    entry.isUploading.value = false;

    // uploadPrivateFile already told the user why (server message included).
    if (data == null) return;

    entry.publicId.value = data['publicId'] as String? ?? '';
    entry.fileName.value = data['fileName'] as String? ?? picked.name;
    entry.fileSize.value = data['fileSize'] as int? ?? 0;
    entry.mimeType.value = data['mimeType'] as String? ?? '';

    if (entry.nameCtrl.text.trim().isEmpty) {
      entry.nameCtrl.text = data['fileName'] as String? ?? picked.name;
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
    final listingError = validateListing();
    if (listingError != null) {
      ToastUtil.showToast(listingError);
      return;
    }
    final fieldsError = validatePublishFields();
    publishFieldsError.value = fieldsError;
    if (fieldsError != null) {
      ToastUtil.showToast(fieldsError);
      return;
    }
    if (publishMode.value != ProductPublishMode.draft && await _planBlocksPublishing()) {
      return;
    }
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
      ToastUtil.showToast(switch (publishMode.value) {
        ProductPublishMode.draft => 'Product saved as draft',
        ProductPublishMode.scheduled =>
          'Product scheduled — it will go live automatically.',
        ProductPublishMode.now => 'Product published successfully!',
      });
    }
  }

  /// Plan lapse (checklist #4): only drafts can be saved.
  Future<bool> _planBlocksPublishing() async {
    final plan = await PlanGate.check();
    if (!plan.lapsed) return false;
    ToastUtil.showToast('Your plan is not active. Save as draft or choose a plan.');
    Get.toNamed(Routes.sellerPlanExpired, arguments: {'status': plan.status});
    return true;
  }

  Future<bool> _publishDigital() async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      ToastUtil.showToast('No store found. Please set up your store first.');
      return false;
    }

    final parsedPrice = double.tryParse(priceCtrl.text.trim());
    final priceError = PriceRules.validate(parsedPrice);
    if (priceError != null) {
      ToastUtil.showToast(priceError);
      return false;
    }

    final parsedCompare = double.tryParse(compareAtPriceCtrl.text.trim());
    final compareError = PriceRules.validateOptional(parsedCompare);
    if (compareError != null) {
      ToastUtil.showToast(compareError);
      return false;
    }

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
      price: parsedPrice!,
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
      productType: 'digital',
      sampleFile: sample.isUploaded ? sample.toSampleJson() : null,
      coverStyle: coverStyle.value,
      classFrom: classFrom.value,
      classTo: classTo.value,
    );
  }

  Future<bool> _publishPhysical() async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      ToastUtil.showToast('No store found. Please set up your store first.');
      return false;
    }

    if (variants.isEmpty) {
      ToastUtil.showToast('Add at least one variant.');
      return false;
    }

    final variantJsonList = <Map<String, dynamic>>[];
    for (var i = 0; i < variants.length; i++) {
      final json = variants[i].toJson();
      if (json == null) {
        ToastUtil.showToast(
          'Variant ${i + 1}: ${PriceRules.validate(double.tryParse(variants[i].priceCtrl.text.trim()))}',
        );
        return false;
      }
      variantJsonList.add(json);
    }

    // Client-side duplicate/consistency check — mirrors the backend's rules,
    // fails fast before the network round-trip.
    String optionsKey(List options) => (options
            .map((o) => '${(o['name'] as String).trim().toLowerCase()}:${(o['value'] as String).trim().toLowerCase()}')
            .toList()
          ..sort())
        .join(',');
    String nameSetKey(List options) =>
        ((options).map((o) => (o['name'] as String).trim().toLowerCase()).toList()..sort()).join('|');

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

    // Parse comma-separated tags
    final tagList = tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return _repo.addPhysicalProduct(
      storeId: storeId,
      name: nameCtrl.text.trim(),
      status: publishMode.value.apiStatus,
      variants: variantJsonList,
      scheduledAt: scheduledAt.value?.toIso8601String(),
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      tags: tagList,
      images: productImages.toList(),
      isListedOnSolvexo: isListedOnSolvexo.value,
      subCategoryId: selectedSubCategoryId.value,
      coverStyle: coverStyle.value,
      classFrom: classFrom.value,
      classTo: classTo.value,
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
    compareAtPriceCtrl = TextEditingController();
    tagsCtrl = TextEditingController();
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
    compareAtPriceCtrl.dispose();
    tagsCtrl.dispose();
    downloadLimitCountCtrl.dispose();
    linkExpiryDaysCtrl.dispose();
    buyerDeliveryMsgCtrl.dispose();
    for (final f in digitalFiles) {
      f.dispose();
    }
    sample.dispose();
    for (final v in variants) {
      v.dispose();
    }
    super.onClose();
  }
}
