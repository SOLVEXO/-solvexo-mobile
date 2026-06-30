import 'dart:io';

import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/data/models/common_models/store_model.dart';
import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<String> kStoreCategories = [
  'Education & Learning',
  'Arts & Crafts',
  'Fashion & Apparel',
  'Electronics',
  'Food & Beverage',
  'Health & Beauty',
  'Home & Garden',
  'Sports & Outdoors',
  'Books & Media',
  'Services & Consulting',
  'Others',
];

class SellerStoreProfileController extends GetxController {
  final _repo       = SellerRepository();
  final _uploadRepo = UploadRepository();

  // ── Single source of truth ────────────────────────────────────────────────
  final Rx<StoreModel?> store = Rx<StoreModel?>(null);

  // ── State ─────────────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditing = false.obs;

  // ── Edit-only state ───────────────────────────────────────────────────────
  final Rx<File?> logoFile = Rx<File?>(null);
  final RxString editCategory = ''.obs; // drives the category dropdown

  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;

  // ── Computed ──────────────────────────────────────────────────────────────
  bool get canSave => nameCtrl.text.trim().isNotEmpty;

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

  // ── Edit actions ──────────────────────────────────────────────────────────
  void startEditing() {
    nameCtrl.text = store.value?.name ?? '';
    descCtrl.text = store.value?.description ?? '';
    editCategory.value = store.value?.categoryId ?? '';
    isEditing.value = true;
  }

  void cancelEditing() {
    logoFile.value = null;
    isEditing.value = false;
  }

  void pickCategory(String cat) => editCategory.value = cat;

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

    // Upload logo first if a new file was picked, then pass the URL
    String? logoUrl;
    if (logoFile.value != null) {
      logoUrl = await _uploadRepo.uploadFile(logoFile.value!);
      if (logoUrl == null) {
        ToastUtil.showToast('Logo upload failed. Please try again.');
        isSaving.value = false;
        return;
      }
    }

    final updated = await _repo.updateStore(
      storeId:      store.value?.id ?? '',
      name:         nameCtrl.text.trim(),
      logoUrl:      logoUrl,
      categoryId:   editCategory.value,
      description:  descCtrl.text.trim(),
      productTypes: store.value?.productTypes ?? [],
    );

    isSaving.value = false;
    if (updated == null) return;

    logoFile.value = null;
    store.value    = updated;
    await AppPreferences.saveStoreName(updated.name);
    isEditing.value = false;
    ToastUtil.showToast('Store profile updated!');
  }
}
