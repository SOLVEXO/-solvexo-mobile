import 'package:book_store_app/config/app_config.dart';
import 'package:book_store_app/app/services/device_camera.dart';
import 'dart:io';
import 'package:book_store_app/core/i18n/locale_service.dart';
import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/modules/settings/controllers/settings_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/services/account_switch_prompt.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/custom_alert_dialog_util.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:book_store_app/app/services/legal_links.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  /// Guests get a stripped-down section list — anything that reads/writes
  /// account data is hidden rather than shown broken (no fake data).
  bool get isLoggedIn => user.value != null;

  // ── Sections for merged profile/settings UI ──────────────────────────────
  List<SettingsSection> get sections => [
    if (isLoggedIn)
      SettingsSection(
        header: 'MY ORDERS',
        tiles: [
          SettingsTile(
            icon: AppIcons.billsIcon,
            title: 'My Orders'.tr,
            onTap: () => Get.toNamed(Routes.myOrdersView),
          ),
          SettingsTile(
            icon: AppIcons.downloadIcon,
            title: 'My Library'.tr,
            onTap: () => Get.toNamed(Routes.library),
          ),
          SettingsTile(
            icon: AppIcons.profileIcon,
            title: 'My reviews'.tr,
            onTap: () => Get.toNamed(Routes.myReviews),
          ),
          SettingsTile(
            icon: AppIcons.coinIcon,
            title: 'Invite friends'.tr,
            onTap: () => Get.toNamed(Routes.referrals),
          ),
          SettingsTile(
            icon: AppIcons.profileIcon,
            title: 'My children'.tr,
            onTap: () => Get.toNamed(Routes.children),
          ),
          if (AppFeatures.digitalPurchases)
            SettingsTile(
              icon: AppIcons.coinIcon,
              title: 'Edudeen Premium'.tr,
              onTap: () => Get.toNamed(Routes.premium),
            ),
          SettingsTile(
            icon: AppIcons.heartIcon,
            title: 'Wishlist'.tr,
            onTap: () => Get.toNamed(Routes.WISHLIST),
          ),
        ],
      ),
    if (isLoggedIn)
      SettingsSection(
        header: 'ACCOUNT',
        tiles: [
          SettingsTile(
            icon: AppIcons.editIcon,
            title: 'Edit Profile'.tr,
            onTap: () => Get.toNamed(Routes.editProfileView),
          ),
          SettingsTile(
            icon: AppIcons.locationIcon,
            title: 'My Addresses'.tr,
            onTap: () => Get.toNamed(Routes.addressView),
          ),
          SettingsTile(
            icon: AppIcons.changePassword,
            title: 'Change Password'.tr,
            onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
          ),
          SettingsTile(
            icon: AppIcons.notificationIcon,
            title: 'Notification Preferences'.tr,
            onTap: () => Get.toNamed(Routes.notificationPreferences),
          ),
        ],
      ),
    SettingsSection(
      header: 'SELLING',
      tiles: [
        SettingsTile(
          icon: AppIcons.cashIcon,
          title: 'Sell on Edudeen'.tr,
          onTap: goToSellerLanding,
        ),
      ],
    ),
    SettingsSection(
      header: 'SUPPORT',
      tiles: [
        SettingsTile(
          icon: AppIcons.languageIcon,
          title: 'Language'.tr,
          trailing: LocaleService.isUrdu ? 'اردو' : 'English',
          onTap: chooseLanguage,
        ),
        SettingsTile(
          icon: AppIcons.messageIcon,
          title: 'Chat with Edudeen'.tr,
          onTap: () => Get.toNamed(Routes.supportChat),
        ),
        SettingsTile(
          icon: AppIcons.phoneIcon,
          title: 'Help Center'.tr,
          onTap: () => Get.toNamed(Routes.helpCenterView),
        ),
        SettingsTile(
          icon: AppIcons.emailIcon,
          title: 'Contact Us'.tr,
          onTap: () => Get.toNamed(Routes.contactUsView),
        ),
        // R7: the same web pages the store listings link to.
        SettingsTile(
          icon: AppIcons.privacy,
          title: 'Privacy Policy'.tr,
          onTap: () => LegalLinks.open(LegalLinks.privacyPolicy),
        ),
        SettingsTile(
          icon: AppIcons.privacy,
          title: 'Terms of Service'.tr,
          onTap: () => LegalLinks.open(LegalLinks.termsOfService),
        ),
        SettingsTile(
          icon: AppIcons.deleteIcon,
          title: 'Delete account on the website'.tr,
          onTap: () => LegalLinks.open(LegalLinks.deleteAccount),
        ),
        SettingsTile(
          icon: AppIcons.aboutIcon,
          title: 'About App'.tr,
          onTap: () => Get.toNamed(Routes.ABOUT),
        ),
      ],
    ),
    if (isLoggedIn)
      SettingsSection(
        header: 'DANGER ZONE',
        tiles: [
          SettingsTile(
            icon: AppIcons.logoutIcon,
            title: 'Logout'.tr,
            isDanger: true,
            onTap: logout,
          ),
          // Store compliance (docs §5.11): in-app deletion.
          SettingsTile(
            icon: AppIcons.deleteIcon,
            title: 'Delete Account'.tr,
            isDanger: true,
            onTap: deleteAccount,
          ),
        ],
      ),
  ];

  /// English / Urdu. Urdu flips the app to RTL and the Nastaliq font.
  void chooseLanguage() {
    Widget option(String label, bool urdu) => ListTile(
      title: Text(label),
      trailing: LocaleService.isUrdu == urdu
          ? Icon(Icons.check_rounded, color: Get.theme.colorScheme.primary)
          : null,
      onTap: () {
        Get.back();
        LocaleService.setUrdu(urdu);
      },
    );
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Language'.tr, style: Get.textTheme.titleMedium),
            option('English', false),
            option('اردو', true),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );
  }

  /// Entry into the in-app seller landing (Welcome). Works for guests and
  /// buyers; a buyer's seller account is created on the same email.
  /// Signed-in buyer: become-seller (or open the existing seller account);
  /// guest: the seller landing.
  Future<void> goToSellerLanding() => AccountSwitchPrompt.toSeller();

  /// Guest CTA — explicitly tags the intent as buyer so a stale 'seller'
  /// intent left over from a previous "Sell on EduDeen" visit never leaks
  /// into a plain buyer login/signup.
  Future<void> goToLogin() async {
    await AppPreferences.saveIntentRole('user');
    Get.toNamed(Routes.authTabView);
  }

  String get initials {
    final n = user.value?.name ?? '';
    final parts = n.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  final AuthRepository _authRepository = AuthRepository();
  final AuthController _authController = Get.put(AuthController());
  final UploadRepository _uploadRepository = UploadRepository();

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isUpdating = false.obs;
  RxBool isUploadingImage = false.obs;

  // User data
  Rx<UserModel?> user = Rx<UserModel?>(null);
  Rx<File?> selectedImageFile = Rx<File?>(null);

  // Edit mode
  RxBool isEditMode = true.obs;

  // Text controllers for editing
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final RxString currencyPreference = ''.obs; // 'PKR' | 'USD'

  // Password change controllers
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Password visibility
  RxBool showCurrentPassword = false.obs;
  RxBool showNewPassword = false.obs;
  RxBool showConfirmPassword = false.obs;

  // Form keys
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  @override
  void onInit() {
    super.onInit();
    // Load profile after a small delay to ensure widget tree is ready
    Future.delayed(Duration(milliseconds: 100), () {
      loadUserProfile();
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> refreshProfile() => loadUserProfile();

  /// After login or a buyer <-> seller switch: show the new account at once
  /// (Home greeting, Account header), then reload the full profile.
  static void onSessionChanged(UserModel? sessionUser) {
    if (!Get.isRegistered<ProfileController>()) return;
    final c = Get.find<ProfileController>();
    if (sessionUser != null) c.user.value = sessionUser;
    c.loadUserProfile();
  }

  /// Load user profile from backend
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      final token = await AppPreferences.getAccessTokenAsync();

      if (token == null || token.isEmpty) {
        debugPrint('No token found, user not logged in');
        user.value = null;
        isLoading.value = false;
        return;
      }

      final userData = await _authRepository.getUserProfile(token: token);

      if (userData != null) {
        user.value = userData;
        _updateControllers();
        debugPrint('Profile loaded successfully: ${userData.name}');
      } else {
        debugPrint('Failed to load profile - userData is null');
        ToastUtil.showToast('Failed to load profile');
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      ToastUtil.showToast('Error loading profile');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh profile data
  // Future<void> refreshProfile() async {
  //   await loadUserProfile();
  // }

  /// Update text controllers with user data
  void _updateControllers() {
    if (user.value != null) {
      nameController.text = user.value!.name;
      emailController.text = user.value!.email;
      phoneController.text = user.value!.phone ?? '';
      addressController.text = user.value!.address ?? '';
      currencyPreference.value = user.value!.currencyPreference ?? '';
    }
  }

  void pickCurrencyPreference(String currency) {
    currencyPreference.value = currency;
  }

  /// Toggle edit mode
  void toggleEditMode() {
    if (isEditMode.value) {
      // Cancel editing - restore original values
      _updateControllers();
      selectedImageFile.value = null;
    }
    isEditMode.value = !isEditMode.value;
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = File(image.path);
        debugPrint('Image selected: ${image.path}');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ToastUtil.showToast('Failed to pick image');
    }
  }

  /// Take photo with camera
  Future<void> takePhoto() async {
    if (!DeviceCamera.available) {
      ToastUtil.showToast('No camera available on this device');
      return;
    }
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = File(image.path);
        debugPrint('Photo taken: ${image.path}');
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      ToastUtil.showToast('Failed to take photo');
    }
  }

  /// Show image picker options
  void showImagePickerOptions() {
    Get.bottomSheet(
      CustomBottomSheet(
        title: 'Choose Profile Picture',
        widget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: CustomText(text: 'Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImage();
              },
            ),
            if (DeviceCamera.available)
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: CustomText(text: 'Take Photo'),
                onTap: () {
                  Get.back();
                  takePhoto();
                },
              ),
            if (user.value?.profileImage != null ||
                selectedImageFile.value != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.red),
                title: CustomText(text: 'Remove Photo', color: AppColors.red),
                onTap: () {
                  Get.back();
                  removeProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Remove profile image
  void removeProfileImage() {
    selectedImageFile.value = null;
    ToastUtil.showToast('Profile picture removed');
  }

  /// Upload profile image
  Future<String?> uploadProfileImage() async {
    if (selectedImageFile.value == null) return null;

    try {
      isUploadingImage.value = true;

      final url = await _uploadRepository.uploadImage(selectedImageFile.value!);

      if (url == null) {
        ToastUtil.showToast('Image upload failed');
        return null;
      }

      debugPrint("✅ Profile image uploaded: $url");
      return url;
    } catch (e) {
      debugPrint("❌ Upload error: $e");
      ToastUtil.showToast("Failed to upload image");
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Update user profile
  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    isUpdating.value = true;

    try {
      // ✅ MUST await
      final token = await AppPreferences.getAccessTokenAsync();

      if (token == null || token.isEmpty) {
        ToastUtil.showToast('Session expired. Please login again');
        return;
      }

      String? imageUrl;
      if (selectedImageFile.value != null) {
        imageUrl = await uploadProfileImage();
      }

      final updatedUser = await _authRepository.updateProfile(
        token: token,
        name: nameController.text.trim(),
        // email is never sent: it cannot be changed here (backend 400).
        phone: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        profileImage: imageUrl ?? user.value?.profileImage,
        currencyPreference: currencyPreference.value.isEmpty
            ? null
            : currencyPreference.value,
      );

      if (updatedUser != null) {
        user.value = updatedUser;
        _authController.currentUser.value = updatedUser;
        isEditMode.value = false;
        selectedImageFile.value = null;
        ToastUtil.showToast('Profile updated successfully');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      ToastUtil.showToast('Failed to update profile');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Change password
  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) {
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ToastUtil.showToast('Passwords do not match');
      return;
    }

    isUpdating.value = true;

    try {
      final token = await AppPreferences.getAccessTokenAsync();

      if (token == null || token.isEmpty) {
        ToastUtil.showToast('Session expired. Please login again');
        return;
      }

      final success = await _authRepository.changePassword(
        token: token,
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (success) {
        // Clear password fields
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        Get.back(); // Close password dialog

        ToastUtil.showToast('Password changed successfully');
      } else {
        ToastUtil.showToast('Failed to change password');
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      ToastUtil.showToast('Failed to change password');
    } finally {
      isUpdating.value = false;
    }
  }

  /// Show change password dialog
  void showChangePasswordDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'Change Password',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 20),

                // Current Password
                Obx(
                  () => TextFormField(
                    controller: currentPasswordController,
                    obscureText: !showCurrentPassword.value,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: showCurrentPassword.value
                            ? 'Hide password'.tr
                            : 'Show password'.tr,
                        icon: Icon(
                          showCurrentPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => showCurrentPassword.toggle(),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current password';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 16),

                // New Password
                Obx(
                  () => TextFormField(
                    controller: newPasswordController,
                    obscureText: !showNewPassword.value,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: showNewPassword.value
                            ? 'Hide password'.tr
                            : 'Show password'.tr,
                        icon: Icon(
                          showNewPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => showNewPassword.toggle(),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 16),

                // Confirm Password
                Obx(
                  () => TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword.value,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: showConfirmPassword.value
                            ? 'Hide password'.tr
                            : 'Show password'.tr,
                        icon: Icon(
                          showConfirmPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => showConfirmPassword.toggle(),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: CustomText(text: 'Cancel'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: isUpdating.value ? null : changePassword,
                          child: isUpdating.value
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : CustomText(text: 'Change'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logout
  Future<void> logout() async {
    showCustomDialog(
      title: "Logout",
      content: 'Are you sure you want to logout?',
      leftButtonName: "Cancel",
      rightButtonName: "Logout",
      onLeftButtonTap: () => Get.back(),
      onRightButtonTap: () async {
        await _authController.logout();
      },
    );
  }

  /// Delete account (docs §5.11): `DELETE /api/users/profile
  /// {confirm:'DELETE', password?}`. The server refuses with 409
  /// `ACCOUNT_DELETE_BLOCKED` while orders are open or Premium is active;
  /// its message is shown as-is.
  Future<void> deleteAccount() async {
    final confirmCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final busy = false.obs;
    final error = RxnString();
    await Get.dialog(
      AlertDialog(
        title: Text('Delete Account'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This permanently deletes your Edudeen account. Orders that are still open must be finished first.'
                    .tr,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmCtrl,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Type DELETE to confirm'.tr,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password (if your account has one)'.tr,
                ),
              ),
              Obx(
                () => error.value == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          error.value!,
                          style: TextStyle(color: Get.theme.colorScheme.error),
                        ),
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          Obx(
            () => FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.error,
              ),
              onPressed: busy.value
                  ? null
                  : () async {
                      if (confirmCtrl.text.trim() != 'DELETE') {
                        error.value = 'Type DELETE to confirm'.tr;
                        return;
                      }
                      busy.value = true;
                      error.value = null;
                      final result = await _authRepository.deleteAccount(
                        password: passwordCtrl.text,
                      );
                      busy.value = false;
                      if (result.ok) {
                        Get.back();
                        ToastUtil.showToast('Account deleted successfully');
                        await _authController.logout();
                      } else {
                        error.value = result.message;
                      }
                    },
              child: Text('Delete'.tr),
            ),
          ),
        ],
      ),
    );
    confirmCtrl.dispose();
    passwordCtrl.dispose();
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 10) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }
}
