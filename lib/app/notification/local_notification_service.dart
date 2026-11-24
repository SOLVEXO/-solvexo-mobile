import 'dart:convert';
import 'package:book_store_app/app/routes/incoming_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    '1',
    'Edudeen notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static final LocalNotificationService _instance =
      LocalNotificationService._();

  LocalNotificationService._();

  factory LocalNotificationService() {
    return _instance;
  }

  Future<void> init() async {
    // Android 13+ POST_NOTIFICATIONS is NOT requested here (it would prompt
    // over a blank launch). FcmService.init() asks once, after a rationale,
    // via FirebaseMessaging.requestPermission().

    ///Requesting iOS notification permission
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    //     ?.requestPermissions(alert: true, badge: true, sound: true);

    ///Creating Android notification channel
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    ///Android settings
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      'notif_icon',
    );

    ///iOS settings
    // Do NOT ask for iOS permission here: init() is awaited in main() before
    // runApp(), so the system prompt appeared over a blank launch and the
    // app waited for the answer. FcmService asks after sign-in instead.
    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    ///Init both platform settings
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      onDidReceiveNotificationResponse: (notificationResponse) {
        debugPrint(
          "onDidReceiveNotificationResponse: ${notificationResponse.payload}",
        );

        if (notificationResponse.payload != null) {
          Map<String, dynamic> jsonMapNotification = jsonDecode(
            notificationResponse.payload!,
          );
          debugPrint(
            "onDidReceiveNotificationResponse: jsonMapNotification $jsonMapNotification",
          );

          try {
            // Android foreground pushes are re-shown locally with the FCM
            // data as payload; a tap opens data.link.
            IncomingLinks.handle(jsonMapNotification['link']?.toString());
          } catch (e) {
            debugPrint("Error parsing notification --> $e");
          }
        }
      },
      settings: initializationSettings,
    );
    // Terminated app opened by tapping a local notification (Android).
    try {
      final launch = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      final payload = launch?.notificationResponse?.payload;
      if ((launch?.didNotificationLaunchApp ?? false) && payload != null) {
        IncomingLinks.handle((jsonDecode(payload) as Map)['link']?.toString());
      }
    } catch (_) {}
  }

  void removeNotification(int id) {
    flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
