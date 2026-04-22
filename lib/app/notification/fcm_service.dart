import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:book_store_app/app/notification/local_notification_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  static final FcmService _instance = FcmService._();

  String? _fcmToken;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FcmService._();

  factory FcmService() {
    return _instance;
  }

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

  Future<void> init() async {
    _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      carPlay: false,
      provisional: false,
      announcement: false,
      criticalAlert: false,
    );

    await setPresentationOptions();

    await Future.delayed(const Duration(milliseconds: 1));

    // if (!Platform.isIOS) {
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint("FCM token: $_fcmToken");
    // } else {
    //   debugPrint("⚠️ Skipping FCM token generation on iOS simulator.");

    // var settings = await _firebaseMessaging.getNotificationSettings();
    // debugPrint("not settings: ${settings.sound}");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("Push received: ${message.data}");
      var remoteNotification = message.notification;
      if (remoteNotification != null) {
        if (Platform.isAndroid) {
          var channel = LocalNotificationService().channel;

          LocalNotificationService().flutterLocalNotificationsPlugin.show(
            id: int.parse(channel.id),
            title: remoteNotification.title,
            body: remoteNotification.body,
            notificationDetails: NotificationDetails(
              // iOS: const IOSNotificationDetails(),
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: 'notif_icon',
              ),
            ),
            payload: Platform.isAndroid ? jsonEncode(message.data) : null,
          );
        }
      }
    });

    ///This is called when notification is clicked on background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onMessageOpenedApp from bg ${message.data}");

      // var payload = NotificationItem.fromJson(message.data);

      // NavigationService.navigateFromNotification(payload);
    });
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  }

  Future<Map<String, dynamic>?> getInitialMessage() async {
    var remote = await _firebaseMessaging.getInitialMessage();
    return remote?.data;
  }

  static Future<void> _onBackgroundMessage(RemoteMessage event) async {
    log("fcm data background: ${event.data}");
    // DashboardController.onBackgroundTap(event.data);
  }

  Future<void> subscribeToUserId() async {
    var userId = AppPreferences.getUserId();

    log("Subscribing to my user ID $userId");
    await _firebaseMessaging.subscribeToTopic(userId.toString());
    log("Subscribed $userId");
  }

  Future<void> unsubscribeToUserId() async {
    var userId = AppPreferences.getUserId();

    log("UnSubscribing to my user ID $userId");
    await _firebaseMessaging.unsubscribeFromTopic(userId.toString());
    log("UnSubscribed $userId");
  }

  String? get fcmToken => _fcmToken ?? "";
}
