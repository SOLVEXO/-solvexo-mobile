# Buyer app ↔ backend alignment (Phase 3)

Checked against backend `edudeen_api` main **5adba44** (source + live calls
as the test buyer, 2026-11-20) and `docs/DOCS_ERRATA.md` (the errata win
over EDUDEEN_DOCS.md). Tick items off in the commit that builds them
(`feat(buyer): B<n>`). Buyer screens use `.tr` (EN/UR), RTL-safe layouts;
money only from the server.

## Items

1. [x] **B1 Course player** (docs §5.10, §7). Backend `src/classroom`
   (`classroom.controllers.ts` `api/courses`):
   - `GET /api/courses/learn/:idOrSlug` (auth) -> `{product{_id,name,slug,
     image,storeName,storeSlug}, sections[{_id,title,lessons[{_id,title,
     type,durationMinutes}]}], certificateEnabled, certificateDetails,
     certificateDetailsRequired, outcomes, instructor{name,bio},
     accessExpiresAt, progress{completedLessonIds, quizScores, lastLessonId,
     completedAt, certificateCode}}` (live).
   - `GET .../learn/:idOrSlug/lessons/:lessonId` -> `{_id,title,type,text,
     durationMinutes, subtitles, file?, media{kind: file|external, url}}`;
     uploaded files are signed URLs valid 3600 s (`LESSON_LINK_SECONDS`);
     YouTube/Vimeo come as `kind: external`. Reading a lesson sets
     `lastLessonId` (server-side resume point).
   - `POST .../lessons/:lessonId/complete`; quiz `POST .../quiz {answers}`
     (older lessons); public `GET /api/courses/outline/:idOrSlug`,
     `GET /api/courses/preview/:idOrSlug/:lessonId` (free previews).
   - Watch rules (no seek-ahead, Next locked, 60 s inactivity) are **client
     rules** (docs §7); the server does not enforce them.
   - App today: Library Courses opens the **web** page in a browser; no
     player, no `/course/:slug` route. `video_player` is installed; no
     web-view package for YouTube/Vimeo.
2. [x] **B2 Certificates** (docs §5.10):
   - `POST /api/courses/learn/:idOrSlug/certificate-details {fullName (2-80,
     required), guardianName (80), institute (120), city (60), country
     (60)}` -> `{certificateDetails, certificateCode, certificateDetailsRequired}`;
     409 once issued ("can no longer be changed"). The certificate issues
     on completion only after the details exist.
   - Public `GET /api/courses/certificates/:code` -> `{code, learnerName,
     courseName, teacher, storeName, instructorName, completedAt, issuedAt,
     guardianName, institute, city, country, config{watermarkText,
     watermarkImageUrl, stampImageUrl, signatureName, signatureTitle,
     issuerName, signatureImageUrl}, storeLogoUrl}` (live, code
     EDU-8C00AFD7).
   - App today: nothing. No PDF package.
3. [x] **B3 Premium** (docs §2.5, §5.12; `src/premium`, `api/premium`):
   `GET plans`, `GET terms`, `GET me`, `GET bank-details`, `GET payments`,
   `POST subscribe`, `POST payments/:paymentId/proof`, `POST cancel`,
   `POST resume` (buyer role `user`). Member prices: only where the API
   sends them; never computed on the device. App today: nothing.
4. [x] **B4 My children** (docs §5.11; `src/children`, `api/children`, role
   `user`): `GET`, `POST`, `PATCH :id`, `DELETE :id`. Limit from
   entitlements (Premium raises it). App today: nothing.
5. [x] **B5 Returns & refunds form** (docs §2.7): `POST /api/refund-request`,
   `GET /api/refund-request/order/:orderId` (+ the item-return route on
   orders). One reason list, note 20-1000, up to 4 photos, status +
   timeline, seller's reject reason. App today: refund form exists
   (`refund_request_repository.dart`), to be aligned.
6. [x] **B6 Wishlist share + referrals** (`src/retention`):
   `api/wishlist-share` (`GET public/:token`, `GET mine`, `POST`,
   `DELETE`), `api/referrals` (`GET me`, `POST apply`). Wishlist alerts are
   notification types `wishlist_back_in_stock` / `wishlist_price_drop` in
   the **`promotions`** preference category (`notification.types.ts:115-116`)
   - there is no separate alerts route; the toggle is that preference.
   App today: nothing for share / referrals.
7. [ ] **B7 Reviews** (docs §5.8; `api/rating`): `POST add-review`,
   `GET my-reviews`, `GET my-reviewed-ids`, `PATCH/DELETE :reviewId`,
   `POST :reviewId/helpful`, `GET product/:productId`. Note:
   `POST :reviewId/report` is **seller-only** (`@Roles('seller')`, line 180)
   - a buyer report route must be checked (`flag/:reviewId`). App today:
   add / my reviews constants exist.
8. [ ] **B8 Buyer extras + checkout check**: `GET /api/cart/buy-now`,
   `GET /api/checkout/delivery-info`, `GET /api/search/trending`, ZIP
   `GET /api/orders/download-zip-link/:orderId/:productId` ->
   `download-zip-file`; checkout: free + COD to success, bank proof with an
   Idempotency-Key, card hidden without `STRIPE_PUBLISHABLE_KEY`
   (`stripe_config.dart`) and only on USD checkouts, seller session ->
   "Switch to your buyer account" (`dio_exception_handler.dart:49-53`).
   Live shipping zones: `GET /api/checkout/getShippingZones` returned
   `data: []` on 2026-11-20 (the admin's zone is not visible yet).

Details per item (routes, DTO rules, live JSON) are in each item's commit.
