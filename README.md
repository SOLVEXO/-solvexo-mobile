# Edudeen — Marketplace app (Flutter)

The full Edudeen marketplace app for the live Edudeen API
(`https://api.edudeen.com`): one app for **buyers and sellers**.

- **Buyers** (guest or signed in): Home | Browse | Cart | Library | Account.
  Buyer screens are translated (English / Urdu with RTL).
- **Sellers** sign in with a seller account and land on the seller panel:
  Dashboard | Orders | Products | Analytics | More. The seller panel is
  English only.
- The login role decides which side opens (login, OTP and splash route by
  role). "Sell on Edudeen" opens the seller Welcome landing.

## Run

```bash
cp config/example.json config/dev.json   # fill STRIPE_PUBLISHABLE_KEY if cards are needed
flutter pub get
flutter analyze
flutter test
flutter run --dart-define-from-file=config/dev.json
```

Config comes only from `--dart-define` / `--dart-define-from-file`
(`API_BASE_URL`, `WEB_BASE_URL`, `STRIPE_PUBLISHABLE_KEY`). No `.env` is
bundled into the app any more. Firebase still uses `firebase_options.dart`.

## Release build

```bash
flutter build appbundle --release --dart-define-from-file=config/prod.json
flutter build ipa --release --dart-define-from-file=config/prod.json
```

Release builds print no logs (API bodies contain personal data).

## Structure

- `lib/app/modules/*` — screens (GetX: binding / controller / view)
- `lib/app/modules/seller*`, `add_seller_product`, `edit_seller_product`,
  `welcome` — seller panel (dashboard, orders, returns, products, inventory,
  finance, analytics, coupons, promotions, SEO, store settings, plans)
- `lib/app/modules/library` — Files + Courses tab
- `lib/app/modules/support_chat` — Edudeen Help (backend chatbot)
- `lib/app/services` — maintenance, platform config, digital downloads
- `lib/app/routes/deep_link_router.dart` — web path → app route
- `lib/core/theme` — Material 3 design system
- `lib/core/i18n` — English / Urdu (RTL, Noto Nastaliq)

## Status

Done: buyer and seller apps on the new Material 3 theme and navigation,
maintenance 503 handling, platform config cache, Urdu/RTL infrastructure
(buyer), Library tab, support chat, in-app account deletion (buyer and
seller).

Retired and not in the app (docs §11): POS, the `educational` product type,
live classes, seller verification/KYC, seller direct bank transfer, the
marketplace page, services & bookings, the client-side Gemini assistant.

Seller ↔ backend gaps are tracked in `docs/SELLER_ALIGNMENT.md` (P0/P1/P2).

Not yet built (next phases, docs §14): native course player + certificates,
Premium, My children, referrals, wishlist share, structured returns form,
push deep links on cold start, Urdu strings for older screens (they show
English until moved to `.tr`).

Compiles and passes `flutter analyze` with no errors (Flutter 3.35).
Not yet verified against the live API: response shapes of
`/api/courses/mine`, `/api/chatbot/conversation`,
`/api/platform-config/maintenance`.

## Release checklist

App identity is now Edudeen (`com.edudeen.app`, Firebase `edudeen-f1a97`, Apple team
`B43H8KM3XZ`). Still to do before a store release (TODO: Google Sign-In client IDs,
release SHA-256 in `docs/deep-links/assetlinks.json`):

- **Bundle / application ids**: iOS `PRODUCT_BUNDLE_IDENTIFIER` is
  `com.edudeen.app` (ios/Runner.xcodeproj); check `applicationId` in
  android/app/build.gradle. 
- **Firebase**: register the new ids in the Firebase project, then replace
  `ios/Runner/GoogleService-Info.plist`, `android/app/google-services.json`
  and regenerate `lib/firebase_options.dart` (`flutterfire configure`).
  Push (FCM) needs the APNs key on the new iOS id.
- **Google sign-in**: new OAuth client IDs per platform (iOS client + reversed
  client id URL scheme in Info.plist; Android SHA-1/SHA-256 for release and
  Play signing keys).
- **Store records**: App Store Connect app + Play Console app for the new
  ids, privacy policy URL and the account-deletion URL (`/delete-account`),
  data-safety / privacy labels, screenshots.
- **Config**: `config/prod.json` with the production `API_BASE_URL`,
  `WEB_BASE_URL` and `STRIPE_PUBLISHABLE_KEY`; never commit it.
