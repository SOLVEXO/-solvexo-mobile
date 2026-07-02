import 'dart:io';

import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/seller_settings/controllers/seller_settings_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/field_validation_util.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SellerEditProfileController extends GetxController {
  final _authRepo = AuthRepository();
  final _uploadRepo = UploadRepository();

  // Form
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isUploadingImage = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  String get initials {
    final n = user.value?.name ?? nameController.text;
    final parts = n.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'S';
  }

  void _loadUser() {
    // Prefer already-loaded data from ProfileController to avoid an extra API call
    try {
      final u = Get.find<ProfileController>().user.value;
      if (u != null) {
        user.value = u;
        _fillControllers();
        return;
      }
    } catch (_) {}
    try {
      final u = Get.find<AuthController>().currentUser.value;
      if (u != null) {
        user.value = u;
        _fillControllers();
        return;
      }
    } catch (_) {}
    _fetchFromApi();
  }

  void _fillControllers() {
    final u = user.value;
    if (u == null) return;
    nameController.text = u.name;
    emailController.text = u.email;
    phoneController.text = u.phone ?? '';
  }

  Future<void> _fetchFromApi() async {
    isLoading.value = true;
    try {
      final token = await AppPreferences.getAccessTokenAsync();
      if (token == null) return;
      final u = await _authRepo.getUserProfile(token: token);
      if (u != null) {
        user.value = u;
        _fillControllers();
      }
    } catch (e) {
      debugPrint('SellerEditProfileController._fetchFromApi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showImagePickerSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Get.back();
                final f = await _uploadRepo.pickImage(source: ImageSource.gallery);
                if (f != null) selectedImage.value = f;
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () async {
                Get.back();
                final f = await _uploadRepo.pickImage(source: ImageSource.camera);
                if (f != null) selectedImage.value = f;
              },
            ),
            if (user.value?.profileImage != null || selectedImage.value != null)
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  selectedImage.value = null;
                },
              ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;
    isUpdating.value = true;
    try {
      String? imageUrl;
      if (selectedImage.value != null) {
        isUploadingImage.value = true;
        imageUrl = await _uploadRepo.uploadFile(selectedImage.value!);
        isUploadingImage.value = false;
        if (imageUrl == null) {
          ToastUtil.showToast('Image upload failed');
          return;
        }
      }

      final updated = await _authRepo.editProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        profileImage: imageUrl ?? user.value?.profileImage,
      );

      if (updated != null) {
        user.value = updated;
        selectedImage.value = null;
        _syncToOtherControllers(updated);
        ToastUtil.showToast('Profile updated successfully');
        Get.back();
      }
    } catch (e) {
      debugPrint('saveProfile error: $e');
      ToastUtil.showToast('Failed to update profile');
    } finally {
      isUpdating.value = false;
      isUploadingImage.value = false;
    }
  }

  void _syncToOtherControllers(UserModel updated) {
    try { Get.find<AuthController>().currentUser.value = updated; } catch (_) {}
    try { Get.find<ProfileController>().user.value = updated; } catch (_) {}
    try {
      final sc = Get.find<SellerSettingsController>();
      sc.name.value = updated.name;
      sc.email.value = updated.email;
    } catch (_) {}
  }

  // ── Validators ──────────────────────────────────────────────────────────────

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateEmail(String? v) =>
      FieldValidationUtil.emailValidate(v ?? '');

  String? validatePhone(String? v) {
    if (v != null && v.isNotEmpty && v.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
