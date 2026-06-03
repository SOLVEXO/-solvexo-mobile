import 'dart:io';
import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/custom_alert_dialog_util.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final List<Map<String, dynamic>> options = [
    {
      "title": "My Order",
      "subtitle": "Check the Order status and history",
      "icon": AppIcons.billsIcon,
      "ontap": Routes.myOrdersView,
    },
    {
      "title": "Payment",
      "subtitle": "Change Payment Option",
      "icon": AppIcons.duePayment,
      "ontap": Routes.paymentView,
    },
    {
      "title": "Address",
      "subtitle": "Delete, Update and add your address",
      "icon": AppIcons.locationIcon,
      "ontap": Routes.addressView,
    },
    {
      "title": "Help Center",
      "subtitle": "Have a problem? you can contact us",
      "icon": AppIcons.phoneIcon,
      "ontap": Routes.helpCenterView,
    },
    {
      "title": "Logout",
      "subtitle": "You can login Again",
      "icon": AppIcons.logoutIcon,
      "ontap": Routes.authTabView,
    },
  ];

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

  /// Load user profile from backend
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      final token = await AppPreferences.getAccessTokenAsync();

      if (token == null || token.isEmpty) {
        debugPrint('No token found, user not logged in');
        isLoading.value = false;

        // Delay navigation to avoid widget errors
        Future.delayed(Duration(milliseconds: 200), () {
          ToastUtil.showToast('Please login to view profile');
        });
        return;
      }

      debugPrint('Loading profile with token: ${token.substring(0, 20)}...');

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
    }
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
              title: Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Get.back();
                takePhoto();
              },
            ),
            if (user.value?.profileImage != null ||
                selectedImageFile.value != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.red),
                title: Text(
                  'Remove Photo',
                  style: TextStyle(color: AppColors.red),
                ),
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
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        profileImage: imageUrl ?? user.value?.profileImage,
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
      final token = AppPreferences.getAccessTokenAsync();

      if (token.isNull) {
        ToastUtil.showToast('Session expired. Please login again');
        return;
      }

      final success = await _authRepository.changePassword(
        token: token.toString(),
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
                Text(
                  'Change Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        child: Text('Cancel'),
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
                              : Text('Change'),
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

  /// Delete account
  Future<void> deleteAccount() async {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performDeleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Perform account deletion
  Future<void> _performDeleteAccount() async {
    try {
      final token = AppPreferences.getAccessTokenAsync();

      if (token.isNull) {
        ToastUtil.showToast('Session expired');
        return;
      }

      final success = await _authRepository.deleteAccount(
        token: token.toString(),
      );

      if (success) {
        ToastUtil.showToast('Account deleted successfully');
        await _authController.logout();
      } else {
        ToastUtil.showToast('Failed to delete account');
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      ToastUtil.showToast('Failed to delete account');
    }
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
