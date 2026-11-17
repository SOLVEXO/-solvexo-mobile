import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    '1',
    'SMV2',
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
    ///Requesting Android notification permission
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

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
            // var notificationPayload = NotificationItem.fromJson(jsonMapNotification);
            // debugPrint("onDidReceiveNotificationResponse: notificationPayload $notificationPayload");

            // NavigationService.navigateFromNotification(notificationPayload);
          } catch (e) {
            debugPrint("Error parsing notification --> $e");
          }
        }
      },
      settings: initializationSettings,
    );
  }

  void removeNotification(int id) {
    flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
