import 'package:book_store_app/app/data/models/common_models/social_login_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

      await _googleSignIn.initialize(
        // iOS OAuth client (GoogleService-Info.plist CLIENT_ID). Only used on
        // iOS; Android resolves its client from google-services.json.
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? '644843992125-1smknlr1aus57ru9567fghejquuturm2.apps.googleusercontent.com'
            : null,
        // WEB client (google-services.json client_type 3); must match the
        // backend GOOGLE_CLIENT_ID.
        serverClientId:
            '644843992125-vuf9corbqceveiim2eg8ehidl8ft8n50.apps.googleusercontent.com',
      );

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

  Future<void> signOutAll() async {
    await signOutGoogle();
  }
}
