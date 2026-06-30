import 'dart:io';

import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart'
    show DigitalFileEntry;
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

const List<String> kProductEmojis = [
  '📐', '☕', '🖼️', '➗', '🔬', '🧩', '📚', '📋', '💾', '🎨',
  '🧴', '👜', '📦', '🕯️', '✏️', '📷', '🎀', '📔', '💧', '🗝️',
  '🍜', '🐝', '🧸', '🎯', '🏆', '💡', '🔮', '🌿', '📱', '🖥️',
];

class EditSellerProductController extends GetxController {
  final _repo       = SellerProductRepository();
  final _uploadRepo = UploadRepository();

  late SellerProduct product;

  // ── Core text controllers ─────────────────────────────────────────────────
  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController compareAtPriceCtrl;
  // Physical-only
  late final TextEditingController stockCtrl;
  late final TextEditingController sizeCtrl;
  late final TextEditingController colorCtrl;
  late final TextEditingController shippingWeightCtrl;
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
  final RxBool isActive = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  // Product images (shared)
  final RxList<String> productImages = <String>[].obs;
  final RxBool isUploadingImage = false.obs;
  // Physical-only
  final RxString stock = ''.obs;
  final RxString size = ''.obs;
  final RxString color = ''.obs;
  final RxString shippingWeight = ''.obs;
  final RxString tags = ''.obs;
  final RxBool unlimitedStock = false.obs;
  // Digital-only
  final RxList<DigitalFileEntry> digitalFiles = <DigitalFileEntry>[].obs;
  final RxBool unlimitedDownload = true.obs;
  final RxString downloadLimitCount = ''.obs;
  final RxString linkExpiryDays = ''.obs;
  final RxBool pdfStampingEnabled = false.obs;
  final RxString licenseType = 'personal'.obs;
  final RxString buyerDeliveryMessage = ''.obs;

  // ── Computed ──────────────────────────────────────────────────────────────

  bool get isPhysical => product.type == 'Physical';
  bool get isDigital => product.type == 'Digital';

  bool get canSave =>
      name.value.trim().isNotEmpty && price.value.trim().isNotEmpty;

  bool get hasChanges =>
      name.value != product.name ||
      price.value != product.price.toStringAsFixed(2) ||
      selectedEmoji.value != product.emoji ||
      isActive.value != (product.status == ProductStatus.active);

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

  // ── Actions ───────────────────────────────────────────────────────────────

  void pickEmoji(String emoji) {
    selectedEmoji.value = emoji;
    Get.back();
  }

  Future<void> saveChanges() async {
    if (!canSave || isSaving.value) return;
    isSaving.value = true;

    final parsedPrice = double.tryParse(priceCtrl.text.trim());
    if (parsedPrice == null) {
      ToastUtil.showToast('Please enter a valid price.');
      isSaving.value = false;
      return;
    }

    final bool success;
    if (isPhysical) {
      success = await _savePhysical(parsedPrice);
    } else if (isDigital) {
      success = await _saveDigital(parsedPrice);
    } else {
      isSaving.value = false;
      return;
    }

    isSaving.value = false;
    if (success) {
      Get.back();
      ToastUtil.showToast('Product updated successfully!');
    }
  }

  Future<bool> _savePhysical(double parsedPrice) async {
    final parsedCompare = double.tryParse(compareAtPriceCtrl.text.trim());
    final parsedStock =
        (!unlimitedStock.value && stockCtrl.text.trim().isNotEmpty)
            ? int.tryParse(stockCtrl.text.trim())
            : null;
    final tagList = tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return _repo.editPhysicalProduct(
      productId: product.id,
      variantId: product.variantId,
      name: nameCtrl.text.trim(),
      price: parsedPrice,
      status: isActive.value ? 'active' : 'draft',
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      compareAtPrice: parsedCompare,
      stock: parsedStock,
      size: sizeCtrl.text.trim().isEmpty ? null : sizeCtrl.text.trim(),
      color: colorCtrl.text.trim().isEmpty ? null : colorCtrl.text.trim(),
      shippingWeight: shippingWeightCtrl.text.trim().isEmpty
          ? null
          : shippingWeightCtrl.text.trim(),
      tags: tagList,
      images: productImages.toList(),
    );
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
    final int? parsedExpiry =
        expiryRaw.isEmpty ? null : int.tryParse(expiryRaw);

    final msg = buyerDeliveryMsgCtrl.text.trim();

    return _repo.editDigitalProduct(
      productId: product.id,
      variantId: product.variantId,
      name: nameCtrl.text.trim(),
      price: parsedPrice,
      status: isActive.value ? 'active' : 'draft',
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      compareAtPrice: parsedCompare,
      files: files,
      downloadLimit: downloadLimit,
      linkExpiryDays: parsedExpiry,
      pdfStampingEnabled: pdfStampingEnabled.value,
      licenseType: licenseType.value,
      buyerDeliveryMessage: msg.isEmpty ? null : msg,
      images: productImages.toList(),
    );
  }

  Future<void> deleteProduct() async {
    isDeleting.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    isDeleting.value = false;
    Get.back();
    ToastUtil.showToast('${product.name} deleted.');
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as SellerProduct;

    // Core
    nameCtrl = TextEditingController(text: product.name);
    descCtrl = TextEditingController(text: product.description ?? '');
    priceCtrl = TextEditingController(text: product.price.toStringAsFixed(2));
    compareAtPriceCtrl = TextEditingController(
      text: product.compareAtPrice != null
          ? product.compareAtPrice!.toStringAsFixed(2)
          : '',
    );
    // Physical
    stockCtrl = TextEditingController(text: product.stock?.toString() ?? '');
    sizeCtrl = TextEditingController(text: product.size ?? '');
    colorCtrl = TextEditingController(text: product.color ?? '');
    shippingWeightCtrl = TextEditingController(text: product.shippingWeight ?? '');
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

    // Reactive values
    name.value = product.name;
    price.value = product.price.toStringAsFixed(2);
    description.value = product.description ?? '';
    compareAtPrice.value = product.compareAtPrice?.toStringAsFixed(2) ?? '';
    stock.value = product.stock?.toString() ?? '';
    size.value = product.size ?? '';
    color.value = product.color ?? '';
    shippingWeight.value = product.shippingWeight ?? '';
    tags.value = product.tags.join(', ');
    selectedEmoji.value = product.emoji;
    unlimitedStock.value = product.isUnlimitedStock;
    isActive.value = product.status == ProductStatus.active;
    productImages.assignAll(product.images);
    unlimitedDownload.value = isUnlimitedDl;
    downloadLimitCount.value = isUnlimitedDl ? '' : product.downloadLimit;
    linkExpiryDays.value = product.linkExpiryDays?.toString() ?? '';
    pdfStampingEnabled.value = product.pdfStampingEnabled;
    licenseType.value = product.licenseType;
    buyerDeliveryMessage.value = product.buyerDeliveryMessage ?? '';

    // Pre-fill digital file entries from existing product data
    for (final f in product.digitalFiles) {
      final entry = DigitalFileEntry();
      // Accept both new 'publicId' and legacy 'url' field
      entry.publicId.value = f['publicId'] as String? ?? f['url'] as String? ?? '';
      entry.fileName.value = f['name'] as String? ?? '';
      entry.mimeType.value = f['mimeType'] as String? ?? '';
      entry.fileSize.value = f['size'] as int? ?? 0;
      entry.nameCtrl.text  = f['name'] as String? ?? '';
      digitalFiles.add(entry);
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    compareAtPriceCtrl.dispose();
    stockCtrl.dispose();
    sizeCtrl.dispose();
    colorCtrl.dispose();
    shippingWeightCtrl.dispose();
    tagsCtrl.dispose();
    downloadLimitCountCtrl.dispose();
    linkExpiryDaysCtrl.dispose();
    buyerDeliveryMsgCtrl.dispose();
    for (final f in digitalFiles) {
      f.dispose();
    }
    super.onClose();
  }
}
