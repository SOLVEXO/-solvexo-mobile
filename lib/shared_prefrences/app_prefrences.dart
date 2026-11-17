import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _accessTokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _userEmailKey = 'user_email';
  static const String _intentRoleKey = 'intent_role';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _guestCartKey = 'guest_cart_items';
  static const String _recentSearchesKey = 'recent_searches';
  static const String _recentlyViewedKey = 'recently_viewed_products';
  static const String _storeIdKey   = 'store_id';
  static const String _storeNameKey = 'store_name';
  static const String _displayCurrencyKey = 'display_currency';

  // ── Tokens (flutter_secure_storage) ───────────────────────────────────────
  // Access + refresh tokens live in the platform keystore/keychain, never in
  // SharedPreferences. The in-memory copy avoids a keystore round-trip on every
  // request and is the single source for the refresh interceptor.
  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  static const String _secureInitKey = 'secure_tokens_initialised';
  static String? _accessCache;
  static String? _refreshCache;
  static bool _tokensLoaded = false;

  /// Call once from `main()` before `runApp`.
  ///
  /// * Upgrade from a build that kept tokens in SharedPreferences: move them
  ///   into secure storage and delete the plaintext copies.
  /// * Fresh install: iOS Keychain entries survive uninstall, so wipe any
  ///   stale tokens on the first run of a new install.
  static Future<void> initSecureStorage() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final legacyAccess = prefs.getString(_accessTokenKey);
      final legacyRefresh = prefs.getString(_refreshTokenKey);

      if (legacyAccess != null && legacyAccess.isNotEmpty) {
        await _secure.write(key: _accessTokenKey, value: legacyAccess);
        if (legacyRefresh != null && legacyRefresh.isNotEmpty) {
          await _secure.write(key: _refreshTokenKey, value: legacyRefresh);
        }
      } else if (!(prefs.getBool(_secureInitKey) ?? false)) {
        await _secure.delete(key: _accessTokenKey);
        await _secure.delete(key: _refreshTokenKey);
      }
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.setBool(_secureInitKey, true);
    } catch (e) {
      debugPrint('❌ Secure storage init failed: $e');
    }
    await _loadTokens();
  }

  static Future<void> _loadTokens() async {
    if (_tokensLoaded) return;
    try {
      _accessCache = await _secure.read(key: _accessTokenKey);
      _refreshCache = await _secure.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('❌ Secure storage read failed: $e');
    }
    _tokensLoaded = true;
  }

  // Save access token
  static Future<void> setAccessToken(
    String accessToken,
    String refreshToken,
  ) async {
    await setTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  // Get access token
  static Future<String?> getAccessTokenAsync() async {
    await _loadTokens();
    return _accessCache;
  }

  // Save refresh token
  static Future<void> setRefreshToken(String token) async {
    await _secure.write(key: _refreshTokenKey, value: token);
    _refreshCache = token;
    _tokensLoaded = true;
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    await _loadTokens();
    return _refreshCache;
  }

  // Save both tokens at once
  static Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _secure.write(key: _accessTokenKey, value: accessToken);
      await _secure.write(key: _refreshTokenKey, value: refreshToken);
      _accessCache = accessToken;
      _refreshCache = refreshToken;
      _tokensLoaded = true;
    } catch (e) {
      debugPrint('❌ Error saving tokens: $e');
      rethrow;
    }
  }

  // Clear access token
  static Future<void> clearAccessToken() async {
    await _secure.delete(key: _accessTokenKey);
    _accessCache = null;
  }

  // Clear refresh token
  static Future<void> clearRefreshToken() async {
    await _secure.delete(key: _refreshTokenKey);
    _refreshCache = null;
  }

  // Clear both tokens
  static Future<void> clearTokens() async {
    await _secure.delete(key: _accessTokenKey);
    await _secure.delete(key: _refreshTokenKey);
    _accessCache = null;
    _refreshCache = null;
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

  // ── Intent role (Buyer | Seller, chosen before auth) ──────────────────────
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

  // ── First-launch onboarding carousel flag ─────────────────────────────────
  static Future<void> setHasSeenOnboarding(bool seen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, seen);
  }

  static Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  // ── Guest cart (local-only until login merges it into the account cart) ────
  static Future<void> saveGuestCartItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestCartKey, jsonEncode(items));
  }

  static Future<List<Map<String, dynamic>>> getGuestCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_guestCartKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ Error decoding guest cart: $e');
      return [];
    }
  }

  static Future<void> clearGuestCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestCartKey);
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
    await clearTokens();
    // `clear()` also dropped the "already initialised" flag; without it the
    // next launch would treat this as a fresh install and wipe a new login.
    await prefs.setBool(_secureInitKey, true);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessTokenAsync();
    return token != null && token.isNotEmpty;
  }

  // ── Store ID ──────────────────────────────────────────────────────────────────
  static Future<void> saveStoreId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeIdKey, id);
  }

  static Future<String?> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storeIdKey);
  }

  static Future<void> clearStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storeIdKey);
  }

  // ── Store Name ────────────────────────────────────────────────────────────────
  static Future<void> saveStoreName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeNameKey, name);
  }

  static Future<String?> getStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storeNameKey);
  }

  static Future<void> clearStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storeNameKey);
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

  // ── Buyer display currency (device-local; source of truth is the backend
  // `currencyPreference` for logged-in users once loaded — see
  // CurrencyController) ────────────────────────────────────────────────────
  static Future<void> saveDisplayCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayCurrencyKey, currency);
  }

  static Future<String?> getDisplayCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_displayCurrencyKey);
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
