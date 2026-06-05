import 'package:book_store_app/app/data/models/common_models/auth_response_model.dart';
import 'package:book_store_app/app/data/models/common_models/social_login_model.dart';
import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final BaseClient _baseClient = BaseClient();

  // ─────────────────────────────────────────
  // SOCIAL LOGIN
  // ─────────────────────────────────────────

  Future<Map<String, dynamic>?> socialLogin(SocialLoginModel dto) async {
    try {
      debugPrint('🔄 Social login: ${dto.authProvider} - ${dto.email}');

      final response = await _baseClient.post(
        ApiConstants.socialLogin,
        data: dto.toJson(),
      );

      if (response.data['success'] == true) {
        debugPrint('✅ Social login successful');
        return response.data;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Social login error: $e');
      rethrow;
    }
  }

  // ================= VERIFY EMAIL OTP =================
  Future<AuthResponseModel?> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _baseClient.post(
        ApiConstants.verifyOtp,
        data: {"email": email, "otp": otp, 'role': 'user'},
      );

      if (response.data['success'] == true) {
        final auth = AuthResponseModel.fromJson(response.data);

        await AppPreferences.setTokens(
          accessToken: auth.token.accessToken,
          refreshToken: auth.token.refreshToken,
        );

        return auth;
      }

      return null;
    } catch (e) {
      debugPrint("Verify OTP error: $e");
      return null;
    }
  }

  Future<bool> resendVerificationOtp(String email) async {
    try {
      final res = await _baseClient.post(
        ApiConstants.resendOtp,
        data: {"email": email, 'role': 'user'},
      );

      if (res.data['success'] == true) {
        debugPrint("Otp has sent once again");
        return true;
      } else {
        debugPrint("Message = ${res.data['message']}");
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final res = await _baseClient.post(
        ApiConstants.forgotPassword,
        data: {"email": email, 'role': 'user'},
        requiresAuth: false,
      );

      return res.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final res = await _baseClient.post(
        ApiConstants.resetPassword,
        data: {
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
          'role': 'user',
        },
        requiresAuth: false,
      );

      return res.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _baseClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role, // ✅ REQUIRED
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
        },
        requiresAuth: false,
      );

      if (response.data['success'] == true) {
        return true;
      } else {
        debugPrint("MESSAGE: ${response.data['message']}");
        ToastUtil.showToast(response.data['message']);
        return false;
      }
    } on DioException catch (e) {
      debugPrint("❌ Status Code: ${e.response?.statusCode}");
      ToastUtil.showToast("${e.response?.data['message']}");
      debugPrint("❌ Response: ${e.response?.data}");
      debugPrint("Register error: $e");
      return false;
    }
  }

  /// Login user
  Future<AuthResponseModel?> login({
    required String email,
    required String password,
    required String role,
  }) async {
    // String fcmToken = "";

    // try {
    //   fcmToken = await FcmService().fcmToken ?? "";
    // } catch (e) {
    //   debugPrint("FCM not ready: $e");
    // }
    try {
      final response = await _baseClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password, 'role': role},
        requiresAuth: false,
      );

      debugPrint("Login Response --> ${response.data}");

      // ✅ ADD THESE DEBUG PRINTS
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Success field: ${response.data['success']}");
      debugPrint("Data keys: ${response.data.keys}");

      if (response.data['success'] == true) {
        debugPrint("✅ Conditions met, parsing response...");

        try {
          final authResponse = AuthResponseModel.fromJson(response.data);

          debugPrint("✅ Parsing successful!");
          debugPrint("User: ${authResponse.user.name}");
          debugPrint("Email: ${authResponse.user.email}");

          // Save tokens (you already have this)
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

          debugPrint("✅ Returning authResponse");
          return authResponse;
        } catch (parseError) {
          debugPrint("❌ PARSING ERROR: $parseError");
          debugPrint("Raw data: ${response.data}");
          rethrow; // This will be caught by outer catch
        }
      } else {
        debugPrint("❌ Conditions NOT met!");
        debugPrint("StatusCode is 200? ${response.statusCode == 200}");
        debugPrint("Success is true? ${response.data['success'] == true}");
      }

      return null;
    } on DioException catch (e) {
      debugPrint("❌ DioException: ${e.message}");
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("❌ Login error: $e");
      return null;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      // final token = await AppPreferences.getAccessTokenAsync();

      await _baseClient.post(ApiConstants.logout);
      await AppPreferences.clearAccessToken();
    } catch (e) {
      // Ignore API errors (401 is OK here)
      debugPrint('Logout API error (ignored): $e');
    } finally {
      // ALWAYS clear local data
      await AppPreferences.clearPreference();
    }
  }

  /// Get current user profile
  Future<UserModel?> getMe({required String token}) async {
    try {
      final response = await _baseClient.get(
        ApiConstants.getMe,
        requiresAuth: true,
      );

      debugPrint("========== GET ME DEBUG ==========");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Headers sent: Bearer $token");
      debugPrint("Raw response: ${response.data}");
      debugPrint("Success field: ${response.data['success']}");
      debugPrint("Data field: ${response.data['data']}");
      debugPrint("==================================");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      debugPrint("GetMe error: $e");
      return null;
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile({required String token}) async {
    try {
      final response = await _baseClient.get(
        ApiConstants.getUserProfile,
        requiresAuth: true,
      );

      debugPrint("Get Profile Response --> ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("Get Profile error --> $e");
      return null;
    }
  }

  /// Update user profile
  Future<UserModel?> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? address,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (profileImage != null) data['profileImage'] = profileImage;
      if (address != null) data['address'] = address;

      final response = await _baseClient.put(
        ApiConstants.updateUserProfile,

        data: data,
      );

      debugPrint("Update Profile Response --> ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("Update Profile error --> $e");
      return null;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _baseClient.put(
        ApiConstants.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      debugPrint("Change Password Response --> ${response.data}");

      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint("Change Password error --> $e");
      return false;
    }
  }

  /// Delete user account
  Future<bool> deleteAccount({required String token}) async {
    try {
      final response = await _baseClient.delete(ApiConstants.deleteUserAccount);

      debugPrint("Delete Account Response --> ${response.data}");

      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint("Delete Account error --> $e");
      return false;
    }
  }
}
