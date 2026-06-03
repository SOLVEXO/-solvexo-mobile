import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/services/social_auth_service.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final SocialAuthService _socialAuth = SocialAuthService();
  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSocialLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  // Text Controllers for Login
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  // Text Controllers for Register
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerFirstNameController =
      TextEditingController();
  final TextEditingController registerLastNameController =
      TextEditingController();
  final TextEditingController registerPhoneController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController registerConfirmPasswordController =
      TextEditingController();

  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  @override
  void onClose() {
    // Dispose controllers
    // loginEmailController.dispose();
    // loginPasswordController.dispose();
    // registerEmailController.dispose();
    // registerFirstNameController.dispose();
    // registerLastNameController.dispose();
    // registerPhoneController.dispose();
    // registerPasswordController.dispose();
    // registerConfirmPasswordController.dispose();
    super.onClose();
  }

  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    try {
      final token = await AppPreferences.getAccessTokenAsync();

      if (token == null || token.isEmpty) {
        return;
      }

      final user = await _authRepository.getMe(token: token);

      if (user != null) {
        currentUser.value = user;
      } else {
        // _authRepository.logout();
        ToastUtil.showToast("User not found please Login your Account");
      }
    } catch (e) {
      debugPrint('GetMe parsing/network error: $e');
      // _authRepository.logout();
      ToastUtil.showToast("User not found please Login your Account");
      return;
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Validate email
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

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != registerPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  /// Validate phone (optional but if filled must be valid)
  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      // Remove any spaces or dashes
      String cleanedValue = value.replaceAll(RegExp(r'[\s\-]'), '');
      if (cleanedValue.length < 10) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  Future<void> signInWithGoogle() async {
    try {
      isSocialLoading.value = true;

      // 1. Get Google credentials
      final dto = await _socialAuth.signInWithGoogle();
      if (dto == null) {
        // User cancelled
        return;
      }

      // 2. Send to backend
      final response = await _authRepository.socialLogin(dto);

      if (response == null || response['success'] != true) {
        _showError('Google sign in failed. Please try again.');
        return;
      }

      // 3. Save tokens
      final token = response['data']['token']['accessToken'];
      final refreshToken = response['data']['token']['refreshToken'];

      await AppPreferences.setTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );

      final userRole = response['data']['user']?['role'] as String? ?? 'user';
      await AppPreferences.saveUserData(
        userId: response['data']['user']?['_id'] as String? ?? '',
        name: dto.userName,
        email: dto.email,
        role: userRole,
      );

      _navigateByRole(userRole);
      _showSuccess('Welcome ${dto.userName}!');
    } catch (e) {
      debugPrint('❌ Google sign in error: $e');
      _showError('Google sign in failed: ${e.toString()}');
    } finally {
      isSocialLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      isSocialLoading.value = true;

      final dto = await _socialAuth.signInWithFacebook();
      if (dto == null) return;

      final response = await _authRepository.socialLogin(dto);

      if (response == null || response['success'] != true) {
        _showError('Facebook sign in failed. Please try again.');
        return;
      }

      final token = response['data']['token']['accessToken'];
      final refreshToken = response['data']['token']['refreshToken'];

      await AppPreferences.setTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );
      final fbRole = response['data']['user']?['role'] as String? ?? 'user';
      await AppPreferences.saveUserData(
        userId: response['data']['user']?['_id'] as String? ?? '',
        name: dto.userName,
        email: dto.email,
        role: fbRole,
      );
      _navigateByRole(fbRole);
      _showSuccess('Welcome ${dto.userName}!');
    } catch (e) {
      debugPrint('❌ Facebook sign in error: $e');
      _showError('Facebook sign in failed: ${e.toString()}');
    } finally {
      isSocialLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isSocialLoading.value = true;

      final dto = await _socialAuth.signInWithApple();
      if (dto == null) return;

      final response = await _authRepository.socialLogin(dto);

      if (response == null || response['success'] != true) {
        _showError('Apple sign in failed. Please try again.');
        return;
      }

      final token = response['data']['token']['accessToken'];
      final refreshToken = response['data']['token']['refreshToken'];

      await AppPreferences.setTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );
      final appleRole = response['data']['user']?['role'] as String? ?? 'user';
      await AppPreferences.saveUserData(
        userId: response['data']['user']?['_id'] as String? ?? '',
        name: dto.userName,
        email: dto.email,
        role: appleRole,
      );
      _navigateByRole(appleRole);
      _showSuccess('Welcome!');
    } catch (e) {
      debugPrint('❌ Apple sign in error: $e');
      _showError('Apple sign in failed: ${e.toString()}');
    } finally {
      isSocialLoading.value = false;
    }
  }

  /// Register new user
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // Combine first and last name
      final fullName =
          '${registerFirstNameController.text.trim()} ${registerLastNameController.text.trim()}';

      final success = await _authRepository.register(
        name: fullName,
        email: registerEmailController.text.trim().toLowerCase(),
        password: registerPasswordController.text,
        phone: registerPhoneController.text.trim().isNotEmpty
            ? registerPhoneController.text.trim()
            : null,
      );
      if (success) {
        ToastUtil.showToast("OTP sent to your email");

        Get.toNamed(
          Routes.otpView,
          arguments: {
            'email': registerEmailController.text.trim(),
            'type': 'verify_email',
          },
        );
      }
    } catch (e) {
      debugPrint('Register error: $e');
      ToastUtil.showToast('Registration failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Login user
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final authResponse = await _authRepository.login(
        email: loginEmailController.text.trim().toLowerCase(),
        password: loginPasswordController.text,
      );
      debugPrint("auth response: $authResponse");

      if (authResponse != null) {
        currentUser.value = authResponse.user;
        await AppPreferences.setTokens(
          accessToken: authResponse.token.accessToken,
          refreshToken: authResponse.token.refreshToken,
        );
        await AppPreferences.saveUserData(
          userId: authResponse.user.id,
          name: authResponse.user.name,
          email: authResponse.user.email,
          role: authResponse.user.role,
        );

        ToastUtil.showToast('Login successful!');
        clearLoginForm();
        _navigateByRole(authResponse.user.role);
        debugPrint('User logged in successfully: ${authResponse.user.email}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      ToastUtil.showToast('Login failed. Please check your credentials.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    // Clear user data
    currentUser.value = null;

    _authRepository.logout();
    Get.offAllNamed(Routes.authTabView);
    ToastUtil.showToast('Logged out successfully');
  }

  /// Clear login form
  void clearLoginForm() {
    loginEmailController.clear();
    loginPasswordController.clear();
    isPasswordVisible.value = false;
  }

  /// Clear register form
  void clearRegisterForm() {
    registerEmailController.clear();
    registerFirstNameController.clear();
    registerLastNameController.clear();
    registerPhoneController.clear();
    registerPasswordController.clear();
    registerConfirmPasswordController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  /// Get user profile
  Future<void> getUserProfile() async {
    final token = AppPreferences.getAccessTokenAsync();

    if (token.isNull) {
      return;
    }

    final user = await _authRepository.getUserProfile(token: token.toString());

    if (user != null) {
      currentUser.value = user;
    }
  }
  // ─────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────

  void _navigateByRole(String role) {
    switch (role) {
      case 'seller':
        Get.offAllNamed(Routes.sellerHome);
        break;
      case 'pos':
        Get.offAllNamed(Routes.posHome);
        break;
      default:
        Get.offAllNamed(Routes.mainHome);
    }
  }

  void _showSuccess(String message) {
    CustomAppSnackbar.success(message);
  }

  void _showError(String message) {
    CustomAppSnackbar.error(message);
  }

  /// Check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  /// Get user name
  String get userName => currentUser.value?.name ?? 'Guest';

  /// Get user email
  String get userEmail => currentUser.value?.email ?? '';
}
