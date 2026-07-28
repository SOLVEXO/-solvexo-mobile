import 'package:book_store_app/app/notification/fcm_background_handler.dart';
import 'package:book_store_app/app/notification/local_notification_service.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_theme.dart';
import 'package:book_store_app/config/stripe_config.dart';
import 'package:book_store_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize SharedPreferences
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Must be registered before runApp() — see the handler's own doc comment
  // for why it has to be a top-level function.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Creates the Android notification channel + initializes the local-
  // notifications plugin so FcmService's foreground-message listener can
  // actually display something once it starts running.
  await LocalNotificationService().init();

  await SharedPreferences.getInstance();
  if (StripeConfig.isConfigured) {
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          // Pinned to light for now — flip to ThemeMode.system once every
          // screen has been verified against the dark palette.
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: "Solvexo",
          initialRoute: AppPages.initialRoute,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
