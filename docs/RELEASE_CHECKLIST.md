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
