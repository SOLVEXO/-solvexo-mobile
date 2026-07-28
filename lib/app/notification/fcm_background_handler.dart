import 'package:book_store_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Must be a TOP-LEVEL function (not a class method) and annotated with this
/// pragma — the engine spawns a separate isolate to run it when a push
/// arrives while the app is fully terminated, and that isolate has none of
/// the current app's state, so Firebase has to be re-initialized here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📩 Background push received: ${message.messageId} — ${message.data}');
}
