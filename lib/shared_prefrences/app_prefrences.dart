import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _accessTokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _intentRoleKey = 'intent_role';
  static const String _recentSearchesKey = 'recent_searches';
  static const String _recentlyViewedKey = 'recently_viewed_products';

  // Save access token
  static Future<void> setAccessToken(
    String accessToken,
    String refreshToken,
  ) async {
    await setTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  // Get access token
  static Future<String?> getAccessTokenAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Save refresh token
  static Future<void> setRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // ✅ Save both tokens at once
  static Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      debugPrint('💾 Saving tokens...');
      final accessSaved = await prefs.setString(_accessTokenKey, accessToken);
      final refreshSaved = await prefs.setString(
        _refreshTokenKey,
        refreshToken,
      );

      debugPrint('✅ Access token saved: $accessSaved');
      debugPrint('✅ Refresh token saved: $refreshSaved');

      // Verify
      final savedAccess = prefs.getString(_accessTokenKey);
      final savedRefresh = prefs.getString(_refreshTokenKey);
      debugPrint('✅ Verified access: ${savedAccess?.substring(0, 20)}...');
      debugPrint('✅ Verified refresh: ${savedRefresh?.substring(0, 20)}...');
    } catch (e) {
      debugPrint('❌ Error saving tokens: $e');
      rethrow;
    }
  }

  // Clear access token
  static Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  // Clear refresh token
  static Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  // Clear both tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Save user data
  static Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // ── Intent role (selected on Welcome screen before auth) ─────────────────────
  static Future<void> saveIntentRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_intentRoleKey, role);
  }

  static Future<String?> getIntentRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_intentRoleKey);
  }

  static Future<void> clearIntentRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_intentRoleKey);
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // Clear all preferences
  static Future<void> clearPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessTokenAsync();
    return token != null && token.isNotEmpty;
  }

  // Recent Searches
  static Future<void> saveRecentSearches(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  static Future<List<String>?> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey);
  }

  // Recently Viewed Products
  static Future<void> saveRecentlyViewedProductIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentlyViewedKey, ids);
  }

  static Future<List<String>?> getRecentlyViewedProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentlyViewedKey);
  }
}
