# Edudeen — Buyer app (Flutter)

Buyer-only mobile client for the live Edudeen API (`https://api.edudeen.com`).
Sellers use the web dashboard; "Sell on Edudeen" opens edudeen.com.

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

- `lib/app/modules/*` — buyer screens (GetX: binding / controller / view)
- `lib/app/modules/library` — Files + Courses tab
- `lib/app/modules/support_chat` — Edudeen Help (backend chatbot)
- `lib/app/services` — maintenance, platform config, digital downloads
- `lib/app/routes/deep_link_router.dart` — web path → app route
- `lib/core/theme` — Material 3 design system
- `lib/core/i18n` — English / Urdu (RTL, Noto Nastaliq)

## Status

Done: buyer-only cleanup, maintenance 503 handling, platform config cache,
new theme + navigation, Urdu/RTL infrastructure, Library tab, support chat,
in-app account deletion.

Not yet built (next phases, docs §14): native course player + certificates,
Premium, My children, referrals, wishlist share, structured returns form,
push deep links on cold start, Urdu strings for older screens (they show
English until moved to `.tr`).

Unverified (no Flutter SDK / no API access where this was written):
compile + analyze, response shapes of `/api/courses/mine`,
`/api/chatbot/conversation`, `/api/platform-config/maintenance`.
