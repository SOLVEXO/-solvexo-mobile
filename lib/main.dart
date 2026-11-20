import 'dart:async';

import 'package:book_store_app/app/notification/fcm_service.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/notification/fcm_background_handler.dart';
import 'package:book_store_app/app/notification/local_notification_service.dart';
import 'package:book_store_app/app/modules/maintenance/views/maintenance_view.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/services/maintenance_service.dart';
import 'package:book_store_app/app/services/platform_config_service.dart';
import 'package:book_store_app/config/resources/app_theme.dart';
import 'package:book_store_app/core/i18n/app_translations.dart';
import 'package:book_store_app/core/i18n/locale_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/config/stripe_config.dart';
import 'package:book_store_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Release builds print nothing: many legacy call sites log API bodies.
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  ApiConstants.warnIfDebugBuildUsesProduction();
  // Initialize SharedPreferences
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Must be registered before runApp() — see the handler's own doc comment
  // for why it has to be a top-level function.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Cold start from a notification tap: its data.link opens after splash.
  unawaited(FcmService.handleLaunchMessage());
  // Creates the Android notification channel + initializes the local-
  // notifications plugin so FcmService's foreground-message listener can
  // actually display something once it starts running.
  await LocalNotificationService().init();
  await SharedPreferences.getInstance();
  await AppPreferences.initSecureStorage();
  await LocaleService.init();
  if (StripeConfig.isConfigured) {
    Stripe.publishableKey = StripeConfig.publishableKey;
    await Stripe.instance.applySettings();
  }
  // App-wide services: maintenance state (fed by every 503) and the public
  // platform config (cached, refreshed quietly). Neither blocks startup.
  Get.put(MaintenanceService(), permanent: true).check();
  Get.put(PlatformConfigService(), permanent: true).load();
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
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: "Edudeen",
          // English + Urdu (RTL). Material widgets mirror automatically.
          translations: AppTranslations(),
          locale: LocaleService.current,
          fallbackLocale: LocaleService.english,
          supportedLocales: LocaleService.supported,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppPages.initialRoute,
          getPages: AppPages.routes,
          // Clamp OS accessibility text scaling so extreme settings can't
          // compound with CustomText's device-pixel-ratio-driven `.sp` and
          // blow out hand-fit layouts (icon buttons, search bar, badges).
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(
                  mq.textScaler.scale(1).clamp(0.9, 1.2),
                ),
              ),
              child: MaintenanceGate(child: child!),
            );
          },
        );
      },
    );
  }
}
