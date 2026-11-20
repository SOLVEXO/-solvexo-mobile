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
