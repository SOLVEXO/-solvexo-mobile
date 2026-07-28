import 'dart:io';

import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/data/models/common_models/store_model.dart';
import 'package:book_store_app/app/data/repositories/category_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/seller_onboarding/controllers/seller_onboarding_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerStoreProfileController extends GetxController {
  final _repo = SellerRepository();
  final _uploadRepo = UploadRepository();
  final _categoryRepo = CategoryRepository();

  // Admin-curated main categories a seller picks from.
  final RxList<CategoryModel> mainCategories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  // ── Single source of truth ────────────────────────────────────────────────
  final Rx<StoreModel?> store = Rx<StoreModel?>(null);

  // ── State ─────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;

  // ── Edit-only state ───────────────────────────────────────────────────────
  final Rx<File?> logoFile = Rx<File?>(null);
  final Rx<File?> coverFile = Rx<File?>(null);
  final RxString editCategory = ''.obs; // display name shown in the dropdown
  final RxString editCategoryId =
      ''.obs; // real category _id sent to the backend

  // What the store sells (multi-select) — drives which tools (incl. POS)
  // get enabled server-side via `resolveTools()`.
  final RxSet<WhatYouSellOption> editProductTypes = <WhatYouSellOption>{}.obs;

  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;

  // ── Computed ──────────────────────────────────────────────────────────────
  bool get canSave =>
      nameCtrl.text.trim().isNotEmpty && editProductTypes.isNotEmpty;

  /// The current store's category name, resolved from its `categoryId` —
  /// used for read-only display (the raw id is meaningless to a user).
  String get categoryName {
    final id = store.value?.categoryId;
    if (id == null || id.isEmpty) return '—';
    return mainCategories.firstWhereOrNull((c) => c.id == id)?.name ?? '—';
  }

  // Stats — placeholder values until a dedicated stats API is integrated
  int get productCount => 0;
  int get orderCount => 0;
  double get rating => 0.0;
  int get reviewCount => 0;

  String get initials {
    final name = store.value?.name.trim() ?? '';
    if (name.isEmpty) return 'S';
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController();
    descCtrl = TextEditingController();
    _loadStore();
    _fetchMainCategories();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> _loadStore() async {
    isLoading.value = true;
    final id = await AppPreferences.getStoreId();
    if (id == null || id.isEmpty) {
      isLoading.value = false;
      return;
    }
    final result = await _repo.getStoreById(id);
    if (result != null) store.value = result;
    isLoading.value = false;
  }

  Future<void> refreshData() => _loadStore();

  Future<void> _fetchMainCategories() async {
    isLoadingCategories.value = true;
    final trees = await _categoryRepo.getAllCategoryTrees();
    mainCategories.assignAll(trees.where((c) => c.isParent));
    isLoadingCategories.value = false;
  }

  // ── Edit actions ──────────────────────────────────────────────────────────
  Future<void> startEditing() async {
    nameCtrl.text = store.value?.name ?? '';
    descCtrl.text = store.value?.description ?? '';

    if (mainCategories.isEmpty && !isLoadingCategories.value) {
      await _fetchMainCategories();
    }
    editCategoryId.value = store.value?.categoryId ?? '';
    editCategory.value =
        mainCategories
            .firstWhereOrNull((c) => c.id == editCategoryId.value)
            ?.name ??
        '';

    editProductTypes.assignAll(
      (store.value?.productTypes ?? [])
          .map((v) => v.asWhatYouSellOption)
          .whereType<WhatYouSellOption>(),
    );

    isEditing.value = true;
  }

  void cancelEditing() {
    logoFile.value = null;
    coverFile.value = null;
    isEditing.value = false;
  }

  void pickCategory(String name) {
    editCategory.value = name;
    editCategoryId.value =
        mainCategories.firstWhereOrNull((c) => c.name == name)?.id ?? '';
  }

  void toggleProductType(WhatYouSellOption option) {
    if (editProductTypes.contains(option)) {
      editProductTypes.remove(option);
    } else {
      editProductTypes.add(option);
    }
  }

  void pickLogo() {
    AppImagePicker.show(
      title: 'Store Logo',
      canRemove:
          (logoFile.value != null || (store.value?.logo.isNotEmpty ?? false)),
      onPicked: (file) => logoFile.value = file,
      onRemove: () {
        logoFile.value = null;
        store.value = store.value == null
            ? null
            : StoreModel(
                id: store.value!.id,
                sellerId: store.value!.sellerId,
                name: store.value!.name,
                slug: store.value!.slug,
                logo: '',
                coverImage: store.value!.coverImage,
                categoryId: store.value!.categoryId,
                description: store.value!.description,
                sellerType: store.value!.sellerType,
                productTypes: store.value!.productTypes,
                enabledTools: store.value!.enabledTools,
                plan: store.value!.plan,
                aiCredits: store.value!.aiCredits,
                status: store.value!.status,
                isDelete: store.value!.isDelete,
                registers: store.value!.registers,
                shifts: store.value!.shifts,
                sellerName: store.value!.sellerName,
                sellerEmail: store.value!.sellerEmail,
                createdAt: store.value!.createdAt,
                updatedAt: store.value!.updatedAt,
              );
      },
    );
  }

  void pickCoverImage() {
    AppImagePicker.show(
      title: 'Store Cover Image',
      canRemove:
          (coverFile.value != null ||
          (store.value?.coverImage.isNotEmpty ?? false)),
      onPicked: (file) => coverFile.value = file,
      onRemove: () {
        coverFile.value = null;
        store.value = store.value == null
            ? null
            : StoreModel(
                id: store.value!.id,
                sellerId: store.value!.sellerId,
                name: store.value!.name,
                slug: store.value!.slug,
                logo: store.value!.logo,
                coverImage: '',
                categoryId: store.value!.categoryId,
                description: store.value!.description,
                sellerType: store.value!.sellerType,
                productTypes: store.value!.productTypes,
                enabledTools: store.value!.enabledTools,
                plan: store.value!.plan,
                aiCredits: store.value!.aiCredits,
                status: store.value!.status,
                isDelete: store.value!.isDelete,
                registers: store.value!.registers,
                shifts: store.value!.shifts,
                sellerName: store.value!.sellerName,
                sellerEmail: store.value!.sellerEmail,
                createdAt: store.value!.createdAt,
                updatedAt: store.value!.updatedAt,
              );
      },
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> save() async {
    if (!canSave || isSaving.value) return;
    isSaving.value = true;

    // Upload logo/cover first if new files were picked, then pass the URLs
    String? logoUrl;
    if (logoFile.value != null) {
      logoUrl = await _uploadRepo.uploadFile(logoFile.value!);
      if (logoUrl == null) {
        ToastUtil.showToast('Logo upload failed. Please try again.');
        isSaving.value = false;
        return;
      }
    }

    String? coverImageUrl;
    if (coverFile.value != null) {
      coverImageUrl = await _uploadRepo.uploadFile(coverFile.value!);
      if (coverImageUrl == null) {
        ToastUtil.showToast('Cover image upload failed. Please try again.');
        isSaving.value = false;
        return;
      }
    }

    final updated = await _repo.updateStore(
      storeId: store.value?.id ?? '',
      name: nameCtrl.text.trim(),
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      categoryId: editCategoryId.value,
      description: descCtrl.text.trim(),
      productTypes: editProductTypes.map((o) => o.apiValue).toList(),
    );

    isSaving.value = false;
    if (updated == null) return;

    logoFile.value = null;
    coverFile.value = null;
    store.value = updated;
    await AppPreferences.saveStoreName(updated.name);
    isEditing.value = false;
    ToastUtil.showToast('Store profile updated!');
  }
}
