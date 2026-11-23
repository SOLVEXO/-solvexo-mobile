# Release checklist (Phase 7 hardening)

Tracks R1-R7 (docs §10, §13, §14 phase 7). `[x]` = done in the app;
"Owner" lines are things only the owner / web team / store accounts can do.

1. [x] **R1 Push notifications (FCM)**
   - Backend: `POST /api/notifications/device-token {fcmToken, platform: android|ios|web}`
     and `DELETE /api/notifications/device-token {fcmToken}` (JWT; max devices per user,
     stale tokens pruned on send). Live round trip 2026-11-20: 201 "Device token registered",
     200 "Device token removed".
   - App: registered after login / OTP / social login / account switch / splash with a
     session (`FcmService.init`); removed on logout (`AuthRepository.logout` ->
     `FcmService.signOut`); re-registered on token refresh.
   - Taps: background (`onMessageOpenedApp`), terminated (`getInitialMessage`, Android
     local-notification launch details) and Android foreground (local notification
     payload) all go to `IncomingLinks.handle(data.link)` -> `DeepLinkRouter`. Cold-start
     links wait until the splash has navigated. iOS foreground: the system banner; its tap
     is `onMessageOpenedApp`.
   - Router also covers every `link` the backend sends today: `/account/orders/:id`,
     `/account/premium`, `/account/reviews`, `/account/downloads`, `/account/dashboard`,
     `/cart`, `/product/:slug`, `/store/:storeId/<orders|returns|products|categories|
     inventory|marketing|plan-billing|ai|dashboard|reviews|questions>` (seller).
   - Owner: Firebase project keys (APNs key upload for iOS push) - see R6.

2. [x] **R2 Deep links (App Links / Universal Links)**
   - Paths: `/product`, `/shop`, `/course`, `/certificates`, `/account/orders`,
     `/wishlist/shared`, `/bundles`, `/picks`, `/learning-paths`, `/?category=`,
     `/?campaign=` on `edudeen.com` and `www.edudeen.com`.
   - Android: `autoVerify` intent filter on MainActivity (https, both hosts, path
     prefixes + `/`); Flutter's own deep linking off (`flutter_deeplinking_enabled=false`).
   - iOS: `Runner/Runner.entitlements` with `applinks:edudeen.com` and
     `applinks:www.edudeen.com` (all three build configs); `FlutterDeepLinkingEnabled=false`.
   - App: `app_links` -> `IncomingLinks` -> `DeepLinkRouter`; a cold-start link waits for
     the splash. New screens for links that had none: bundle, curated picks and learning
     path (`/shelf`), and the learning-paths list.
   - Live 2026-11-23: bundles/public, curated-collections/home and learning-paths all
     return `data: []`, so no real slug exists to open yet.
   - **Owner / web team:** host `docs/deep-links/assetlinks.json` and
     `docs/deep-links/apple-app-site-association` (see `docs/deep-links/README.md`),
     fill the Play signing SHA-256, enable "Associated Domains" on the App ID in the
     Apple developer portal (needed for device builds/provisioning), then verify on a
     device (simulator can't verify without the hosted files).

3. [x] **R3 Performance**
   - **Images**: `CommonImageView` (71 call sites) now decodes network images at the size shown
     (`memCacheWidth` from the widget/layout width x device pixel ratio, max 1600 px) and shows a
     flat placeholder instead of one spinner per tile; fixed-size thumbnails elsewhere also get
     `memCacheWidth` (`lib/utils/image_sizing.dart`). Disk cache = `cached_network_image`.
   - **Lazy lists**: Home is now a `CustomScrollView`; the product grid is a `SliverGrid`, so
     "Load more" pages no longer lay out every earlier card (it was a `shrinkWrap` grid inside
     a `ListView`). Other long lists already use `ListView.builder`/`separated`.
   - **Start-up requests** (guest cold start, iPhone 17 Pro simulator, 2026-11-23): 16 calls; the
     only duplicate was `GET /api/categories/category-tree` (Home and CategoryController each
     fetched it) - now one shared, de-duplicated request. The 3 `promotions/track/impression`
     calls are one per banner by design. Everything else is one call per section, in parallel.
   - **Release size (2026-11-23, `1.0.11+15`)**
     | Artifact | Size |
     |---|---|
     | `app-arm64-v8a-release.apk` | 43.3 MB |
     | `app-armeabi-v7a-release.apk` | 42.0 MB |
     | `app-x86_64-release.apk` | 44.7 MB |
     | `app-release.aab` (all ABIs; Play serves ~43 MB per device) | 76.0 MB |
     | iOS `Runner.app` (release, no codesign) | 106.6 MB uncompressed |
     | IPA estimate (zip of Runner.app) | 34.2 MB |
     Biggest parts: Dart code `libapp.so` 15.8 MB, Flutter engine 10.5 MB, Java/Kotlin dex
     ~25 MB uncompressed (Stripe, Firebase, Google Maps, Facebook SDKs; R8 minify + resource
     shrinking already on); iOS: App.framework 22 MB, Stripe frameworks ~25 MB, Flutter 9 MB.
     Assets are only 4.9 MB (fonts). Biggest possible saving: drop `flutter_facebook_auth`
     if Facebook login is not used (it has no App ID configured, see R6).
   - **Jank on a low-end Android emulator: NOT measured.** This Mac has the Android SDK but no
     emulator/system image (`emulator -list-avds` empty) and no device. Owner: run
     `flutter run --profile` on a low-end device (2-3 GB RAM) and check Home scroll and the
     product page in DevTools.

4. [x] **R4 Accessibility**
   - **Labels**: 60 `IconButton`s audited, 25 had no label; all buyer ones now have
     `tooltip` (= screen-reader label, `.tr`), seller ones English. Shared widgets gained a
     label: `CustomIconButton(semanticLabel:)`, `AppIconButton(semanticLabel:)`, storefront and
     product-gallery round buttons. Password eye buttons say Show/Hide by state.
   - **Tap targets**: `CustomIconButton` (bare SVG + GestureDetector) now has a 44x44 minimum;
     storefront back/share and product-page back went 36-40 px -> 44 px (test uses Flutter's
     `iOSTapTargetGuideline`).
   - **Text scaling**: the app capped text at 1.2x; now 0.9-1.3x. Device check (iPhone 17 Pro,
     Urdu, 1.3x): Home, Library, Course player, Certificate, Premium, My children, Wishlist,
     Referrals, My reviews, Product page, Search, Cart, My orders, Profile, Notifications,
     Addresses, Returns & refunds - **no overflow, RTL on every screen**.
   - **Contrast** (WCAG AA 4.5:1 on white): `gray600` 4.2 -> 4.7, `grey` 4.1 -> 4.6,
     `lightGrey7` 2.2 -> 4.5, `green2` 2.4 -> 5.0; primary blue 4.8 (ok). Small visual change.
   - **Raw keys**: `cannot_be_empty`, `is_too_short`, `lbl_delete_validation`, ... showed as raw
     snake_case text (no English map); now real English + Urdu.
   - Not covered: strings that are still hard-coded English in older buyer widgets (no `.tr`)
     stay English in Urdu mode; layout is RTL-correct but those labels need wrapping.

5. [x] **R5 Error monitoring (optional Sentry)**
   - `sentry_flutter` 8.14; `lib/app/services/error_monitoring.dart`. **Off by default**: without
     `--dart-define=SENTRY_DSN=...` the SDK is never started (no network, no native init).
     Optional `--dart-define=APP_ENV=staging` (default `production`).
   - No personal data: `sendDefaultPii=false`, no user set, no screenshots / view hierarchy,
     **print breadcrumbs off** (the app's debug logs include profile email/phone), **UI-interaction
     breadcrumbs off**, http breadcrumbs keep only method / status / URL **without query string**
     (download tokens live there), every message/exception text is scrubbed of emails, phone
     numbers, JWT/Bearer tokens and `token|code|password|otp|key=` params; `extra` cleared.
   - Errors only (`tracesSampleRate=0`).
   - Owner: create the Sentry project (separate DSN per app/env), set it in the release build
     command / CI secret; optional: upload debug symbols (`--split-debug-info` + `sentry-dart-plugin`).

6. [x] **R6 App identity (prepared only - no id changed)**
   Today: Android `com.solvexo.app`, iOS `com.solvexo.ios`, Firebase project `solvexo-cec1a`,
   Apple team `B43H8KM3XZ`, Dart package `book_store_app` (internal only, keep it).

   **Every place an id / name / icon / splash is set**
   | What | Where |
   |---|---|
   | Android applicationId + namespace | `android/app/build.gradle.kts` (`namespace`, `applicationId`) |
   | Android Kotlin package | `android/app/src/main/kotlin/com/solvexo/app/MainActivity.kt` (`package com.solvexo.app`) - folder path too |
   | Android app name | `android/app/src/main/AndroidManifest.xml` `android:label="EduDeen"` |
   | Android icon | `android/app/src/main/res/mipmap-*/ic_launcher.png` (generated by `flutter_launcher_icons`, `pubspec.yaml` -> `image_path: assets/images/Logo-transparent.png`) |
   | Android notification icon | `android/app/src/main/res/drawable-*/notif_icon.png` (used by `fcm_service.dart`) |
   | Android splash | `res/drawable*/launch_background.xml`, `res/values*/styles.xml` (`LaunchTheme`) + the Flutter splash screen `lib/app/modules/splash_screen` |
   | Android Firebase | `android/app/google-services.json` (`package_name` x3, `bundle_id`) |
   | Android signing | `android/key.properties` + keystore (not in git) |
   | App Links | `AndroidManifest.xml` intent filter; `docs/deep-links/assetlinks.json` (`package_name`) |
   | iOS bundle id | `ios/Runner.xcodeproj/project.pbxproj` `PRODUCT_BUNDLE_IDENTIFIER` (Debug/Release/Profile = `com.solvexo.ios`; RunnerTests = `com.example.ios.RunnerTests`) |
   | iOS app name | `ios/Runner/Info.plist` `CFBundleDisplayName`, `CFBundleName` = `EduDeen` |
   | iOS icon / launch | `ios/Runner/Assets.xcassets/AppIcon.appiconset`, `LaunchImage.imageset`, `Base.lproj/LaunchScreen.storyboard` |
   | iOS Firebase | `ios/Runner/GoogleService-Info.plist` (`BUNDLE_ID`, `REVERSED_CLIENT_ID`, `GOOGLE_APP_ID`) |
   | iOS Google Sign-In | `Info.plist` `GIDClientID` + URL scheme `com.googleusercontent.apps.707145385701-8fq4...` |
   | iOS Universal Links | `ios/Runner/Runner.entitlements`; `docs/deep-links/apple-app-site-association` (`appIDs`) |
   | Dart Firebase options | `lib/firebase_options.dart` (`appId`, `projectId`, `iosBundleId`) - generated by `flutterfire configure` |
   | Dart Google Sign-In ids | `lib/app/data/services/social_auth_service.dart` `clientId` (iOS) / `serverClientId` (web, backend `GOOGLE_CLIENT_ID`) |
   | Facebook login | `social_auth_service.dart` uses `flutter_facebook_auth`, but **no Facebook App ID / client token is set** in `AndroidManifest.xml` / `strings.xml` / `Info.plist` -> Facebook login cannot work yet |
   | macOS / Linux / Windows (not shipped) | `macos/Runner/Configs/AppInfo.xcconfig` (`com.example.bookStoreApp`), `linux/CMakeLists.txt`, `windows/runner/Runner.rc` |
   | Version | `pubspec.yaml` `version:` (see R7) |

   **Steps to switch to the Edudeen ids** (do in one branch, test on devices, then upload):
   1. Pick the ids (suggested `com.edudeen.app` for both platforms) and the display name `Edudeen`.
   2. Firebase: in the Edudeen Firebase project add an Android app (`com.edudeen.app`, add the
      release + upload SHA-1/SHA-256) and an iOS app (`com.edudeen.app`); upload the APNs auth key
      (Apple developer -> Keys) for push. Download the new `google-services.json` and
      `GoogleService-Info.plist`; run `flutterfire configure --project=<edudeen-project>`
      to regenerate `lib/firebase_options.dart`. Backend `firebase-admin` must use the same project.
   3. Google Sign-In (Google Cloud console, same project): new **iOS** OAuth client for the new
      bundle id -> update `GIDClientID`, the reversed-client-id URL scheme in `Info.plist`, and
      `clientId` in `social_auth_service.dart`; new **Android** OAuth client with package name +
      SHA-1 of release, upload and debug keys; keep the **web** client as `serverClientId` (it must
      match the backend's `GOOGLE_CLIENT_ID`).
   4. Android: change `namespace` + `applicationId` in `build.gradle.kts`, move
      `kotlin/com/solvexo/app/MainActivity.kt` to `kotlin/com/edudeen/app/` with the new package line,
      replace `google-services.json`. A new applicationId is a **new Play listing**; to keep the
      existing listing, keep `com.solvexo.app` on Play.
   5. iOS: change `PRODUCT_BUNDLE_IDENTIFIER` (3 configs; RunnerTests to `<id>.RunnerTests`), create
      the App ID in the Apple portal with Push Notifications + Associated Domains + Sign in with Apple,
      replace `GoogleService-Info.plist`, re-create provisioning profiles.
   6. Names/icons: `android:label`, `CFBundleDisplayName`/`CFBundleName`; replace
      `assets/images/Logo-transparent.png` with a 1024x1024 square source (and an adaptive-icon
      foreground) and run `dart run flutter_launcher_icons`; update `LaunchImage` + `launch_background`.
   7. Facebook (if kept): create the Meta app, add `facebook_app_id` + `facebook_client_token` to
      `res/values/strings.xml` and the `<meta-data>` entries in the manifest, and `FacebookAppID`,
      `FacebookClientToken`, `FacebookDisplayName` + `fb<appid>` URL scheme in `Info.plist`.
   8. Deep links: update `docs/deep-links/assetlinks.json` (`package_name`, new SHA-256) and the
      AASA `appIDs` (`<TeamID>.<new id>`; list old + new during the overlap) and re-host them.
   9. Backend/web: Stripe / PK gateway return URLs and any `com.solvexo.*` allow-lists; Play/App
      Store links in Admin -> Homepage content.
   10. Smoke test login (email, Google, Apple), push (register token, tap), deep links, payments.

7. [x] **R7 Store compliance**
   - **In-app links** (buyer Account and seller Settings): Privacy Policy
     `https://www.edudeen.com/privacy-policy`, Terms of Service
     `https://www.edudeen.com/terms-of-service`, Delete account on the web
     `https://www.edudeen.com/delete-account` (all 200 on 2026-11-23), plus the existing in-app
     Delete Account (`DELETE /api/users/profile`). Use these URLs in Play Console and App Store
     Connect. (The apex `edudeen.com/...` 308-redirects to `www`.)
   - **Permission texts (English + Urdu)**: iOS `NSCameraUsageDescription`,
     `NSPhotoLibraryUsageDescription`,
     `NSLocationWhenInUseUsageDescription` in `Info.plist` (English) and
     `ios/Runner/ur.lproj/InfoPlist.strings` (Urdu, `CFBundleLocalizations` = en, ur). iOS has no
     usage string for notifications; the app shows its own explanation first. Android system
     dialogs cannot be customised, so the app explains camera / photos / notifications in its own
     dialog (`.tr`, English + Urdu) before the system prompt.
   - **Version / build scheme**: `pubspec.yaml` `version: MAJOR.MINOR.PATCH+BUILD`
     (today `1.0.11+15`). `BUILD` = Android `versionCode` = iOS `CFBundleVersion`; it must go up by
     1 for **every** store upload (both stores, even a re-upload of the same version).
     `MAJOR.MINOR.PATCH` = `versionName` / `CFBundleShortVersionString`: PATCH for fixes, MINOR for
     features, MAJOR for breaking changes. Build with
     `flutter build appbundle --build-name=1.1.0 --build-number=16` or bump `pubspec.yaml` in the
     release commit; tag `v1.1.0+16`.

   **Draft - Google Play Data safety** (from what the app actually sends)
   | Data type | Collected | Shared | Purpose | Optional? |
   |---|---|---|---|---|
   | Name, email, phone | Yes (account, orders) | With the seller of an order (name, phone, address for delivery) | Account management, app functionality | Required for an account; browsing works as a guest |
   | Physical address | Yes (delivery addresses) | With the seller of a physical order | App functionality | Only for physical orders |
   | Approximate/precise location | Yes, only when the user taps "Pick on map" (geolocator); not stored as location, only the chosen address | No | App functionality | Optional |
   | Payment info | Card data goes to Stripe directly (not to Edudeen); bank-transfer proof images are uploaded | Stripe (processor) | Payments | Optional (COD/bank) |
   | Purchase history | Yes (orders, library) | Seller sees their own orders | App functionality | - |
   | Photos | Yes, only images the user uploads (profile, reviews, return evidence, payment proof, seller products) | Public where the user publishes them (reviews, products) | App functionality | Optional |
   | Audio | Not collected. No microphone permission: `RECORD_AUDIO` is removed (`tools:node="remove"`, also against plugin manifests) and `NSMicrophoneUsageDescription` / `NSSpeechRecognitionUsageDescription` are gone. `permission_handler` keeps `PERMISSION_MICROPHONE=0` (its default) | - | - | - |
   | Messages | Yes (buyer-seller chat, support chat) | With the other party of the chat | App functionality | Optional |
   | App activity | Searches (recent searches), recently viewed, banner impressions/clicks, product page visits | No | Personalisation, analytics (first-party) | - |
   | Device or other IDs | FCM push token | Google (FCM) as processor | Notifications | Optional (notification permission) |
   | Crash logs / diagnostics | Only if built with `SENTRY_DSN` (R5); no personal data | Sentry (processor) | App stability | - |
   Data is encrypted in transit (HTTPS). Users can request deletion in-app and at `/delete-account`.
   No advertising ID (AD_ID removed in the manifest), no data sold.

   **Draft - App Store privacy ("nutrition label")**
   - Data linked to the user: Contact Info (name, email, phone, address), Purchases, User Content
     (photos, reviews, messages, customer support), Identifiers (user ID), Usage Data (product
     interaction, search history) - all for App Functionality; Usage Data also Analytics.
   - Data not linked to the user: Diagnostics (crash data) only when Sentry is on.
   - Tracking: **No** (no third-party advertising/tracking; no ATT prompt needed).
   - Location: Precise location only at "Pick on map", App Functionality, not stored as location.
   - Owner to confirm with legal before submitting; keep in sync with the web privacy policy.
