import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Protects any route that requires authentication.
/// If token is missing or cleared → redirects to authTabView.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // This is called synchronously — we use a cached/sync check here.
    // The async token check happens in onPageCalled below.
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    _checkAuth();
    return page;
  }

  Future<void> _checkAuth() async {
    final token = await AppPreferences.getAccessTokenAsync();
    if (token == null || token.isEmpty) {
      await AppPreferences.clearTokens();
      Get.offAllNamed(Routes.authTabView);
    }
  }
}

/// Extends AuthMiddleware to also verify the user's role matches
/// the expected role for this section (seller / pos / user).
class RoleMiddleware extends GetMiddleware {
  final String expectedRole;

  RoleMiddleware(this.expectedRole);

  @override
  int? get priority => 1;

  @override
  GetPage? onPageCalled(GetPage? page) {
    _checkRoleAuth();
    return page;
  }

  Future<void> _checkRoleAuth() async {
    final token = await AppPreferences.getAccessTokenAsync();

    // No token → kick to auth
    if (token == null || token.isEmpty) {
      await AppPreferences.clearTokens();
      Get.offAllNamed(Routes.authTabView);
      return;
    }

    // Wrong role → redirect to correct home
    final role = await AppPreferences.getUserRole();
    if (role != expectedRole) {
      _navigateByRole(role);
    }
  }

  void _navigateByRole(String? role) {
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
}
