import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/notification/local_notification_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/app/routes/incoming_links.dart';
import 'package:book_store_app/app/services/notification_ask.dart';
import 'package:book_store_app/app/services/permission_rationale.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Owns the whole push-notification lifecycle: requesting the OS permission,
/// obtaining the FCM token, registering/refreshing/removing it with the
/// backend's device-token registry (`api/notifications/device-token`), and
/// showing a local notification for foreground pushes.
///
/// Call [init] once right after a successful login/register/OTP-verify (and
/// on app start for an already-logged-in user) — see call sites in
/// `AuthRepository` and `SplashScreenController`. Call [signOut] from
/// logout so a signed-out install stops receiving the previous user's pushes.
class FcmService {
  static final FcmService _instance = FcmService._();

  String? _fcmToken;
  bool _initialized = false;
  // True between signOut() and the next init(): a token refresh triggered by
  // deleteToken() must not re-register the device for the old user.
  bool _signedOut = false;
  static const _pushTimeout = Duration(seconds: 6);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationsRepository _notificationsRepository = NotificationsRepository();

  FcmService._();

  factory FcmService() => _instance;

  Future<void> setPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  /// Requests the OS permission, obtains the token, registers it with the
  /// backend, and wires up foreground/opened-app listeners. Safe to call
  /// more than once (e.g. once from the splash screen for a returning user,
  /// again after a fresh login) — only runs the one-time listener setup
  /// once, but always re-checks permission/token/subscription so a token
  /// rotated since the last call, or a permission granted after being
  /// previously denied, still gets picked up.
  ///
  /// Every call site invokes this with `unawaited(...)` so a slow/failing
  /// push setup never blocks login/navigation — which means nothing is
  /// there to catch a thrown error. It must never throw.
  Future<NotificationSettings?> init() async {
    _signedOut = false;
    try {
      // R7: explain first (English/Urdu) before the system prompt; "Not now"
      // skips the prompt and we ask again after a week at the earliest.
      final current = await _firebaseMessaging.getNotificationSettings();
      if (current.authorizationStatus == AuthorizationStatus.notDetermined) {
        if (!await NotificationAsk.shouldAsk()) {
          _setupListeners();
          return current;
        }
        await NotificationAsk.waitForStableScreen();
        final ok = await PermissionRationale.ask(PermissionKind.notifications);
        await NotificationAsk.markAsked();
        if (!ok) {
          _setupListeners();
          return current;
        }
      }
      final settings = await _firebaseMessaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        carPlay: false,
        provisional: false,
        announcement: false,
        criticalAlert: false,
      );

      await setPresentationOptions();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // On iOS, `getToken()` needs the native APNs token first — right
        // after `requestPermission()` resolves, APNs registration is still
        // in flight, so calling it immediately throws
        // `apns-token-not-set`. Poll briefly for it; on the iOS Simulator
        // (which never receives a real APNs token) this will simply time
        // out and skip token registration rather than crash.
        if (Platform.isIOS) {
          await _waitForApnsToken();
        }

        try {
          _fcmToken = await _firebaseMessaging.getToken();
          await registerDeviceToken();
          await subscribeToUserId();
        } catch (e) {
          debugPrint("⚠️ FCM getToken failed (ignored): $e");
        }
      }

      _setupListeners();
      return settings;
    } catch (e) {
      debugPrint("⚠️ FcmService.init failed (ignored): $e");
      return null;
    }
  }

  Future<void> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) return;
      await Future.delayed(const Duration(seconds: 1));
    }
    debugPrint("⚠️ No APNS token after retries (simulator, or APNs not yet ready)");
  }

  void _setupListeners() {
    if (!_initialized) {
      _initialized = true;

      // Token can rotate (app restore on new device, cleared app data,
      // token expiry) — without this the backend keeps sending to a dead
      // token and push silently stops working until reinstall.
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        if (_signedOut) return;
        _fcmToken = newToken;
        try {
          await registerDeviceToken();
        } catch (e) {
          debugPrint("⚠️ token refresh registration failed (ignored): $e");
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint("Push received (foreground): ${message.data}");
        final remoteNotification = message.notification;
        if (remoteNotification != null && Platform.isAndroid) {
          final channel = LocalNotificationService().channel;
          LocalNotificationService().flutterLocalNotificationsPlugin.show(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: remoteNotification.title,
            body: remoteNotification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: 'notif_icon',
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      });

      /// Called when a push notification is tapped from the background.
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        IncomingLinks.handle(message.data['link']?.toString());
      });
    }
  }

  /// Cold start from a notification tap: queue its link (opened after splash).
  static Future<void> handleLaunchMessage() async {
    try {
      final m = await FirebaseMessaging.instance.getInitialMessage();
      IncomingLinks.handle(m?.data['link']?.toString());
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getInitialMessage() async {
    final remote = await _firebaseMessaging.getInitialMessage();
    return remote?.data;
  }

  /// Real OS-level permission state — for surfacing in the notification
  /// preferences UI instead of only a backend `pushEnabled` toggle that
  /// has no bearing on whether push can actually reach the device.
  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Deep-links into the OS app-settings screen so a user who denied the
  /// permission can re-enable it without reinstalling.
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  Future<void> subscribeToUserId() async {
    final userId = await AppPreferences.getUserId();
    if (userId == null || userId.isEmpty) return;

    debugPrint("Subscribing to topic $userId");
    await _firebaseMessaging.subscribeToTopic(userId);
  }

  Future<void> unsubscribeToUserId() async {
    final userId = await AppPreferences.getUserId();
    if (userId != null && userId.isNotEmpty) {
      debugPrint("Unsubscribing from topic $userId");
      await _firebaseMessaging.unsubscribeFromTopic(userId);
    }
  }

  /// Registers this device's FCM token with the backend device-token registry
  /// (`api/notifications/device-token`) so push can target this install
  /// directly instead of relying on topic broadcast. No-ops for guests.
  Future<void> registerDeviceToken() async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;
    if (!await AppPreferences.isLoggedIn()) return;

    final platform = Platform.isIOS ? 'ios' : 'android';
    await _notificationsRepository.registerDeviceToken(token, platform);
  }

  /// Call on logout — de-registers this device so a signed-out install stops
  /// receiving pushes meant for the previous user.
  Future<void> removeDeviceToken() async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;
    await _notificationsRepository.removeDeviceToken(token);
  }

  /// Full push teardown for logout and account switch. Must run while the
  /// current session (access token + user id) is still stored. Every step is
  /// independent, time-boxed and swallows its own errors, so push problems
  /// can never block or fail the logout / switch:
  ///  1. backend DELETE of this device's token (fetching it first if needed),
  ///  2. unsubscribe the user-id topic,
  ///  3. delete the FCM token on the device, so the old user's pushes stop
  ///     even when step 1 failed.
  Future<void> signOut() async {
    _signedOut = true;

    try {
      var token = _fcmToken;
      if (token == null || token.isEmpty) {
        token = await _firebaseMessaging.getToken().timeout(_pushTimeout);
      }
      if (token != null && token.isNotEmpty) {
        await _notificationsRepository.removeDeviceToken(token).timeout(_pushTimeout);
      }
    } catch (e) {
      debugPrint("⚠️ FCM backend token removal failed (ignored): $e");
    }

    try {
      await unsubscribeToUserId().timeout(_pushTimeout);
    } catch (e) {
      debugPrint("⚠️ FCM topic unsubscribe failed (ignored): $e");
    }

    try {
      await _firebaseMessaging.deleteToken().timeout(_pushTimeout);
    } catch (e) {
      debugPrint("⚠️ FCM deleteToken failed (ignored): $e");
    }
    _fcmToken = null;
  }

  String? get fcmToken => _fcmToken;
}
