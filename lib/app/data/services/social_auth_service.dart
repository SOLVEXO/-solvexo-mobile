import 'package:book_store_app/app/data/models/common_models/social_login_model.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ─────────────────────────────────────────
  // GET FCM TOKEN
  // ─────────────────────────────────────────

  Future<String?> _getFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('🔔 FCM Token: ${fcmToken?.substring(0, 20)}...');
      return fcmToken;
    } catch (e) {
      debugPrint('⚠️ FCM token error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────
  // GOOGLE SIGN IN
  // ─────────────────────────────────────────

  Future<SocialLoginModel?> signInWithGoogle() async {
    try {
      debugPrint('🔄 Starting Google Sign In...');

      await _googleSignIn.initialize();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      final auth = account.authentication;
      final fcmToken = await _getFcmToken();

      return SocialLoginModel(
        authProvider: 'google',
        socialId: account.id,
        userName: account.displayName ?? 'User',
        email: account.email,
        image: account.photoUrl,
        fcmToken: fcmToken,
        token: auth.idToken,
      );
    } catch (e) {
      debugPrint('❌ Google Sign In error: $e');
      return null;
    }
  }
  // ─────────────────────────────────────────
  // FACEBOOK SIGN IN
  // ─────────────────────────────────────────

  Future<SocialLoginModel?> signInWithFacebook() async {
    try {
      debugPrint('🔄 Starting Facebook Sign In...');

      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        debugPrint('❌ Facebook Sign In failed: ${result.status}');
        return null;
      }

      final userData = await FacebookAuth.instance.getUserData();
      final fcmToken = await _getFcmToken();

      debugPrint('✅ Facebook Sign In successful: ${userData['email']}');

      return SocialLoginModel(
        authProvider: 'facebook',
        socialId: userData['id'],
        userName: userData['name'] ?? 'User',
        email: userData['email'] ?? '',
        image: userData['picture']?['data']?['url'],
        fcmToken: fcmToken,
        token: result.accessToken?.tokenString,
      );
    } catch (e) {
      debugPrint('❌ Facebook Sign In error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────
  // APPLE SIGN IN
  // ─────────────────────────────────────────

  Future<SocialLoginModel?> signInWithApple() async {
    try {
      // Check if available (iOS 13+ or macOS 10.15+)
      if (!await SignInWithApple.isAvailable()) {
        debugPrint('❌ Sign in with Apple not available');
        return null;
      }

      debugPrint('🔄 Starting Apple Sign In...');

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final fcmToken = await _getFcmToken();

      // Apple only provides name on first sign-in
      final name = credential.givenName != null && credential.familyName != null
          ? '${credential.givenName} ${credential.familyName}'
          : 'User';

      debugPrint('✅ Apple Sign In successful');

      return SocialLoginModel(
        authProvider: 'apple',
        socialId: credential.userIdentifier ?? '',
        userName: name,
        email: credential.email ?? '',
        fcmToken: fcmToken,
        token: credential.identityToken,
      );
    } catch (e) {
      debugPrint('❌ Apple Sign In error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ Google signed out');
    } catch (e) {
      debugPrint('⚠️ Google sign out error: $e');
    }
  }

  Future<void> signOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
      debugPrint('✅ Facebook signed out');
    } catch (e) {
      debugPrint('⚠️ Facebook sign out error: $e');
    }
  }

  Future<void> signOutAll() async {
    await signOutGoogle();
    await signOutFacebook();
  }
}
