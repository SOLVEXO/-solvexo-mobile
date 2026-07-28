import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/notification/local_notification_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
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
    try {
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
          debugPrint("FCM token: $_fcmToken");
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
        _fcmToken = newToken;
        debugPrint("FCM token refreshed: $newToken");
        await registerDeviceToken();
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
        debugPrint("onMessageOpenedApp: ${message.data}");
      });
    }
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
    await removeDeviceToken();
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

  /// Full teardown for logout: unsubscribe from the topic and remove the
  /// device token, so the very next push after sign-out never reaches this
  /// install.
  Future<void> signOut() => unsubscribeToUserId();

  String? get fcmToken => _fcmToken;
}
