# Backend diff report: edudeen_api a5cba9f → 5adba44

For: the edudeen-app team (Flutter, branch `full-app`). Written 2026-11-18.
Read-only: no backend code was changed and no app code was changed. Nothing
is committed or pushed.

## Contents
1. Step 1: the pull
2. Step 2: what changed in the backend (summary)
3. Step 3: impact on the app
   - 3.1 BREAKING items (all modules, one table)
   - 3.2 Known backend issues 1–8 (SELLER_ALIGNMENT.md)
   - 3.3 New backend features the app does not use yet
   - 3.4 docs/EDUDEEN_DOCS.md: out-of-date lines
4. Appendices: per-module detail (core, commerce, seller/platform) and the
   full route diff

---

## 1. Step 1: the pull

| | commit | date | note |
|---|---|---|---|
| OLD | `a5cba9f1444d680cd9636f4c3598fba4a57623ff` | 2026-10-01 18:37 +0500 | was checked out on branch `jami-branch` (clean, up to date with origin) |
| NEW | `5adba44fe5208f4eb73df625a45f7b82a58addde` | 2026-11-17 14:11 +0500 | `main`, "Orders list: return variantId on each item" |

- Working tree was clean; nothing stashed, reset or deleted.
- OLD hash saved in `/tmp/edudeen_api_old_head.txt`.
- `git checkout main` (local main was at 006ff4a, 2026-09-28), then
  `git pull --ff-only origin main` fast-forwarded with no conflicts. OLD is
  an ancestor of the new main.
- **212 commits** between OLD and NEW (2026-09-29 → 2026-11-17).
  Authors: **ahad siddiqui (206)**, Claude (6).
- 782 files changed, +61,816 / −10,931 lines.
- The repo is now on `main`. Your old branch `jami-branch` is untouched.

The live API (api.edudeen.com) already behaves like this main. Every route
the app was aligned to in P0–P2 (bulk-offers, low-stock-threshold,
stock-history, courses/seller/…/roster, dashboard-summary, …) exists in
HEAD and did not exist in OLD.

## 2. Step 2: what changed (summary)

### a) Modules in `src/`

- **Added (19):** admin-exports, admin-orders, admin-pending, admin-reauth,
  analytics-visits, chatbot, children, classroom (courses, students roster,
  bundles, product Q&A, curated collections, learning paths), couriers,
  home-cards, phone-verification, premium, realtime (socket.io), retention,
  staff, store-dashboard, stripe-billing.
- **Removed (1):** `subscriptions`. This is the buyer store-membership
  feature (seller "Subscription Plans" and buyer "My memberships"). It was
  retired on purpose in commit `eee3d8a` (2026-11-03, "Remove buyer
  store-membership subscriptions"). Nothing replaces it as a feature.
  `stripe-billing` is only the shared Stripe code for seller platform plans,
  and the Stripe webhook still answers at
  `POST /api/subscriptions/webhooks/stripe`. The nearest buyer-side
  equivalent is the platform-run Premium program.
- Most changed: products (54 files), ai-studio (44), checkout (27),
  orders (26), common (26), store (24), seo (23), classroom (23),
  admin-config (21), messaging (20), payment (19), marketing (19).

### b) Endpoints

Every `@Controller` and route decorator was compared between OLD and HEAD.
The full list is in Appendix D.

- **641 → 919 routes.** 335 added, 57 removed, 61 with changed guards.
- **Removed:**
  - all 46 `/api/subscriptions/*` routes (store memberships)
  - `GET /api/products/education/facets` and
    `/education/custom-level-suggestions` (the retired educational type)
  - store KYC verification: `GET|PATCH /api/store/:storeId/verification`,
    `/verification/requirements`, `/verification/documents`,
    `/verification/submit`, and `/api/store/verification/requirements-preview`
  - `PATCH /api/store/:storeId/customers/:customerId`
  - `GET /api/refund-request/admin/pending`
  - `PATCH /api/admin/marketplace/leads/:id/under-review`
  - `POST /api/auth/admin/create-admin`
- **Guard changes:**
  - Almost all are admin routes that gained `AdminReauthGuard` (the admin
    must re-enter their password for inline edits and sensitive admin data).
  - One affects the app: `DELETE /api/rating/admin/:reviewId` is now
    admin-only (it was seller+admin).
- **Added:** see 3.3 and Appendix D.

### c–e) DTOs, response shapes and business rules

The per-module detail is in Appendices A–C. These are the rule changes that
matter most:

- **COD:**
  - Now allowed across several sellers in one checkout.
  - Limit and fee are per package, from the admin COD config
    (`maxPerPackagePKR`, `feePerPackagePKR`).
  - `codCollector` is `platform` or `seller`; only `seller` may mark a
    package paid.
- **Checkout:**
  - Physical checkout needs `shippingZoneId` once any active shipping zone
    exists.
  - Digital items are limited to one per order.
  - Bank-transfer details need `?checkoutId=`.
  - The new seller manual-payments routes return **410 Gone** (seller
    direct bank transfer is retired).
- **Publishing:**
  - First publish goes to `pending_review` unless the store is on a paid
    plan.
  - Going live needs `coverStyle`; digital listings also need
    `classFrom`/`classTo`.
  - `educational` and `live_class` types return 400.
  - Product title must be at least 10 characters and the description at
    least 20, drafts included.
  - Physical variants need `shippingWeight`.
  - Edit-review is **disabled**: `splitEditForReview` has
    `hold = false && …`, so edits to live listings apply immediately.
  - A free sample is **not** required by the server (it only adds to the
    quality score).
- **Stores:** one store per seller (409 on a second `create-store`).
- **Store banners:**
  - A link must be the id of one of the seller's own products or
    collections.
  - Maximum 4 active or scheduled slides.
- **Accounts:**
  - Account deletion needs `{confirm:'DELETE', password}` when the account
    has a password. It returns 409 while there are open orders, pending
    payouts or a wallet balance.
  - Email can no longer be changed through `PUT /users/profile`.
  - OTPs expire after 5 minutes.
  - Profile images must be https.
- **Addresses:**
  - Pakistani mobile numbers only.
  - 5-digit zip.
  - Letters-only city.
  - Line 1 at least 5 characters.
  - `state` must be one of the 7 exact province names (case-sensitive).
- **Plans:**
  - Lapse statuses are `expired`, `past_due` and `canceled`.
  - Advanced analytics returns 403 with the "Pro" plan message.
  - Seller analytics change percentages come only with
    `compareToPreviousPeriod=true`, and `totalRevenueChangePercent` was
    removed.
- **Returns:**
  - A seller reject needs notes of at least 10 characters.
  - New optional reason codes, notes and evidence photos.
  - `seller-returns-all` rows are keyed by `requestId`.
- **Reviews:** a seller can edit a review reply only within 24 hours.
- **Upload:** public uploads are capped at 20 MB (was 100 MB) and the file
  contents are checked.
- **Maintenance:** any call can return 503
  `{maintenanceMode, scope, title, message, endsAt}`. This is unchanged
  since the app's P0 work.

### f) Backend docs / change log

- The repo has no `docs/` folder and no `CLAUDE.md`.
- The root Markdown files (`README.md`, `QA_REPORT.md`,
  `DEPLOY_CHECKLIST.md`) did not change between OLD and NEW.
- The only Markdown changes are in `src/ai-studio/` (README +12 lines,
  `prompts/edudeen-guidelines.md` +29 lines, the AI Studio prompt rules).
- There are no change-log entries to summarise. The commit messages are
  short and free-form; the module appendices give the intent where it
  matters.

---

## 3. Step 3: impact on the app

How this was checked:
- Every endpoint in `lib/app/network/api_constaints.dart` (280) was matched
  against the HEAD route table.
- Then three module-by-module reviews of DTOs, schemas, responses and rules
  were run against the app code, and I re-checked their main claims in the
  backend source.
- One reviewer claim was **wrong and is corrected here**: "price edits on
  live listings are held for review". Edit-review is disabled in
  `product-edit-review.util.ts:29`.

### 3.1 BREAKING items

"Fails" means the call now returns 4xx. "Wrong" means it succeeds but sends
or reads the wrong thing.

| # | Area | App call | App file:line | What breaks | Fix |
|---|---|---|---|---|---|
| 1 | Storefront (buyer) | `GET /api/subscriptions/public/:storeId/plans` | `lib/app/data/repositories/buyer_memberships_repository.dart:21`, shown by `modules/storefront/widgets/storefront_plans_teaser.dart:40` | **Fails** (404) on every store page, with an error toast | Remove the plans teaser and the buyer membership code |
| 2 | Buyer memberships | `/api/subscriptions/my*`, `/subscribe`, `/my/benefits`, `/my/credits` | `buyer_memberships_repository.dart:47,76,106,126,148,201,223`; route from `notifications_controller.dart:132` | **Fails** (404): the feature is retired | Remove the `my_memberships` module, route and notification link |
| 3 | Seller subscription plans | `/api/subscriptions/:storeId/plans`, `/dashboard`, `/subscribers…` | `subscription_plans_repository.dart:19,45,84,114,136,162,190,205`; tile at `seller_settings_controller.dart:105-108` | **Fails** (404) | Remove the "Subscription Plans" tile and the `seller_subscriptions` module |
| 4 | Physical checkout | `POST /api/checkout/create-checkout` | `modules/cart/controllers/cart_controller.dart:400` → `data/repositories/checkout_repository.dart:30-38` | **Fails** (400 "Choose a delivery option…") when any active zone exists: no `shippingZoneId` is sent. `addressId` isn't sent either | Choose the address and zone before creating the checkout, and send both |
| 5 | Bank transfer | `GET /api/payment/manual-transfer/bank-details` | `data/repositories/manual_transfer_repository.dart:21` | **Fails** (400): `checkoutId` is now required | Send `?checkoutId=`; read the new `payeeName` |
| 6 | Seller returns (P1 #8) | `PATCH /api/refund-request/:id/approve|reject` | `modules/seller_returns/models/seller_return_item.dart:106` (also `:103`, `:111`) | **Fails** (404): rows carry `requestId`, but the app falls back to `orderId`. Product name (`item`) and photos (`evidenceImages`) are not read | Read `requestId`, `item` and `evidenceImages` |
| 7 | Add product | `POST add-physical-product`, `POST /products/:id/variants` | `data/models/common_models/variant_entry.dart:76`; `add_seller_product/widgets/variant_card.dart:137-147` | **Fails** (400 "Shipping weight is required") when the weight is empty, drafts included | Make weight required (up to 50 kg) |
| 8 | Add product | `POST add-physical-product` / `add-digital-product` | `add_seller_product/controllers/add_seller_product_controller.dart:297-309,621,700` | **Fails** (400): description under 20 characters or title under 10 | Add both checks on the device |
| 9 | Cart | `POST /api/cart/update-cart-quantity` (increase on a digital line) | `cart_controller.dart:167` | **Fails** (400 "Digital items are limited to one per order") | Hide or disable + for digital lines |
| 10 | Seller account delete | `DELETE /api/users/profile` | `seller_settings_controller.dart:361` → `auth_repository.dart:514-525` | **Fails** (400): no password is sent | Ask for the password, as the buyer flow does |
| 11 | Addresses | `POST /address/add-address`, `/update-address` | `modules/address/controllers/address_controller.dart:277-300` (checks), `:174` (generic toast); `views/add_address_view.dart:33,43-45` | **Fails** (400) for many free-text inputs and on edits to old addresses; the server's reason is hidden | Province dropdown with the 7 names, matching checks, show the server message |
| 12 | Support chat (guest) | `POST /api/chatbot/message` | `modules/support_chat/controllers/support_chat_controller.dart:140-147,180-183` | **Wrong**: `guestToken` is not sent, so follow-ups start new threads and replies on the first thread are lost | Send `guestToken`, or use `/chatbot/conversation/message` |
| 13 | Edit profile (buyer) | `PUT /api/users/profile` with a changed email | `profile_controller.dart:464`; `edit_profile_view.dart:72` | **Fails** (400) if the email is edited | Make email read-only, or drop it from the body |
| 14 | Store banners | `POST|PATCH /api/store-banner/:storeId…` | `seller_store_banners/widgets/store_banner_form_sheet.dart:19,50,68,234`; `store_banner_repository.dart:45,55,109` | **Fails** (400) for external/category links and slugs; also 400 beyond 4 slides | Link only to own products or collections by id (picker); handle the 4-slide cap |
| 15 | Seller analytics | `GET /api/seller/analytics/overview` | `analytics_overview_model.dart:57`; `seller_analytics_repository.dart:102`; `analytics_kpi_grid.dart:29-41` | **Wrong**: change % cards always show "No prior data"/"+0" | Send `compareToPreviousPeriod=true`; read `bookedValueChangePercent` |
| 16 | Create store | `POST /api/store/create-store` | `seller_stores_view.dart:31-33` → `seller_repository.dart:197` | **Fails** (409) at the end of onboarding for a seller who already has a store | Hide "Create New Store" when a store exists |
| 17 | Payout method edit (old bug) | `PATCH /api/finance/:storeId/payout-methods/:id` | `seller_finance_repository.dart:245-253` | **Fails** (400): `type` is required but not sent | Send `type` |
| 18 | Education filter | `GET products-by-category` `educationLevel` | `api_constaints.dart:142-147`; `components/product_filter_bottom_sheet.dart` | **Wrong**: the parameter is ignored, so the filter does nothing | Use `class=<slug>` and `curriculum` |
| 19 | Minor | plan status `expired`; OTP text | `platform_plan_widgets.dart:37-42`; `otp_view.dart:130` | "Expired" shows as "Canceled"; the OTP text says 10 min (it's 5) | Label and copy fixes |
| 20 | Minor (my #15) | `update-store` shipFrom with province but no city | `seller_store_settings_repository.dart:95-97` | Server stores `null`, so the province is lost | Require a city when a province is chosen |

Not breaking but stale:
- Dead `subscription_*` and `verification_under_review` notification cases
  (`notifications_controller.dart:129-132`).
- The dead `isPriority` chat badge (`conversation_tile.dart:90`).
- Type-ahead search should send `suggest=1` (`search_repository.dart:27`).
- The COD amount the app shows can be lower than charged, because it
  ignores the per-package COD fee and per-store shipping.
- The app requires a free sample to publish digital products (P0 #3); the
  server doesn't. That is stricter than needed but harmless; see 3.4.

Backend cosmetic: `src/orders/orders.service.ts` has 49 "—" saved as
"â€”", so some order error toasts show mojibake.

### 3.2 Backend issues 1–8 (docs/SELLER_ALIGNMENT.md)

| # | Issue | Status in HEAD | Evidence |
|---|---|---|---|
| 1 | Refund-request "502" | Not a backend issue (retracted: harness bug) | n/a |
| 2 | GET payout-schedule creates a record (default USD) | **Still open** | `finance.service.ts:209-224` find → create; `finance.controller.ts:190` defaults the currency to USD. The default frequency is now monthly |
| 3 | Empty enum list in "type must be one of the following values: " | **Still open** | `add-payout-method.dto.ts:7` passes an array to `@IsEnum`. Same pattern in the coupon, plan, loyalty and discount DTOs; `@IsIn` fixes it |
| 4 | Docs gap: earnings-summary and seller-returns-all missing from EDUDEEN_DOCS Part C | **Still open** (docs, not code) | Both routes are in HEAD; the doc is unchanged |
| 5 | fee-estimate ignores Premium input | **Still open** | `finance.controller.ts:52-64`, `finance.service.ts:1363-1384` |
| 6 | update-store accepts empty `productTypes` | **Still open** | `store.service.ts:690-698, 844-847` (a non-array value also skips the check) |
| 7 | update-store coerces `codEnabled` and loose `shipFrom` | **Still open** | `store.service.ts:720` (`!!value`); `:813-821` drops unknown keys and turns a numeric province into a string |
| 8 | 500 on bad ids in course routes; silent title cutting | **Partly fixed** | The roster routes now return 400 "Invalid id". The course builder, students and PUT routes still return 500 for a bad `storeId` (`classroom.controllers.ts:281-298` → `store-ownership.util.ts:27`). Titles are still cut at 120/150 (`course.util.ts:6,187,191`) |

### 3.3 New backend features the app does not use yet

Buyer:
- **Premium** (`/api/premium/*`: plans, subscribe by bank transfer with
  proof, status, coupon).
- **Children** (`/api/children`, up to 8, drives the shopping-for bar).
- **Phone verification** (`/api/auth/phone/*`).
- **logout-others.**
- **Wishlist sharing** (`/wishlist-share`, `/wishlist/shared/:token`).
- **Search:** `suggest=1`, `exact=1`, `GET /search/trending`;
  `didYouMean`/`correctedQuery` in responses.
- **Cart and checkout:** cart buy-now; `GET /checkout/delivery-info`;
  `GET /checkout/gift-options`.
- **Library:** my-library and the ZIP download of all files.
- **Wallets:** JazzCash/Easypaisa hosted payments.
- **Product shelves:** home shelves (free downloads and samples, etc.) and
  curated collections.
- **Learning:** bundles, learning paths, product Q&A.
- **Realtime socket** `/realtime` (topic pings so screens re-read quietly).
- **Notifications:** `clear-read`; WhatsApp/SMS preferences; about 35 new
  notification types (`premium_*`, return/refund, review…). They route
  through `data.link`.

Seller:
- **Orders:** seller order detail and print; seller-cancel.
- **Products:** `bulk-price`; `products/visibility/:id`;
  `upload/product-video` (product page video).
- **Messaging:** quick replies; buyer-details panel.
- **Reviews:** rating seller tools (reply edit window, report).
- **Categories:** category requests.
- **Home cards:** admin-driven home cards (read side for the home screen).

Admin-only additions (staff, reauth, exports, admin-orders/pending,
couriers) are out of scope for the mobile app.

The full per-module lists are in Appendices A–C.

### 3.4 docs/EDUDEEN_DOCS.md: lines that are now out of date

| Line | Doc says | HEAD does |
|---|---|---|
| 102 | Bank details from `GET /api/payment/manual-transfer/bank-details` | It now needs `?checkoutId=`; the response adds `payeeName` |
| 106 | Plan features include "subscriptions" | Store subscriptions are retired (commit `eee3d8a`) |
| 129, 134 | "no stacking with sale/subscriber/campaign"; "Lines with a store-subscriber price keep 'only if cheaper'" | No store-subscriber prices any more |
| 153 | "Free sample is **required for sellers to publish** digital products" | The server does not require one; it only adds to the quality score |
| 327 (6.12 Marketing) | "subscriptions" among the seller marketing tools | Removed |
| 2.3 COD | Per-package limit and fee; no mention of multi-seller COD | COD is allowed across several sellers, each package with its own limit and fee |
| 2.4 / 5.6 Checkout | The Delivery step comes after the checkout is created | `create-checkout` needs `shippingZoneId` once any active zone exists, so the zone must be chosen first |
| 5.6 Address | "validation, cap 20" | Strict PK rules: mobile, 5-digit zip, letters-only city, line 1 ≥ 5, exact province names |
| 5.11 Account / delete | Delete needs `{confirm:'DELETE', password?}` | Same body. The doc doesn't say the email can no longer be changed through `PUT /users/profile`, or that OTPs expire in 5 minutes |
| Part C (appendix) | Cut off before the finance and orders modules | Still missing earnings-summary, seller-returns-all and the classroom routes |

Lines 154 ("edits to live listings apply immediately") and 91 ("one store
per seller") still match HEAD.

---

## Appendices

- **A:** core modules (auth, users, address, otp, phone, categories,
  search, wishlist, notifications, messaging, chatbot, children, premium,
  upload, realtime)
- **B:** commerce modules (products, variants, inventory, cart, checkout,
  payment, manual-payments, orders, refund-request, rating, couriers,
  collections, exchange-rate)
- **C:** seller/platform modules (store, store-dashboard, finance,
  platform-plans, stripe-billing, subscriptions, analytics, marketing,
  promotions, store-banner, loyalty, classroom, admin-config, common)
- **D:** the full route diff (added, removed, guards changed)

Appendices A–C were written by the three reviews and checked against the
source by me where they feed the table above. Line numbers refer to
backend HEAD 5adba44 and app `full-app` @ f1d48c1e.

---

## Appendix A — core modules

## Backend diff a5cba9f..HEAD: core modules (auth, users, address, otp, phone-verification, categories, search, wishlist, notifications, messaging, chatbot, children, premium, upload, realtime, faqs/contact)

Backend: `/Users/mac/Documents/develop/flutterprojects/edudeen/edudeen_api` (HEAD 5adba44)
App: `/Users/mac/Documents/develop/flutterprojects/edudeen/edudeen-app` (branch full-app)

Global context checked: `GLOBAL_VALIDATION_OPTIONS = { transform: true, whitelist: true }` (src/common/validation.config.ts, unchanged). Unknown body fields are **stripped silently, not rejected** (no `forbidNonWhitelisted`).

Note: the app was evidently written against a newer backend than a5cba9f. It already calls `auth/become-seller`, `switch-to-buyer`, `create-buyer-account`, `chatbot/*`, `messaging/seller/start` and sends the new `DELETE /users/profile` body. Several "new" routes are therefore already in use. Below, "regression" means the old backend accepted something that HEAD now rejects.

---

### 1. auth (`src/auth`)

Commits: c88038f (admin hardening), 7abe9de/8cfcc55 (buyer/seller switch), df98f6a, b4abbaf, 53c877e, 09fee64, eea72df.

#### c) DTO changes
- `LoginDto`: `password` gets `@MaxLength(200)`; new optional `totp` (max 16), used only by admin/staff.
- `RegisterDto`: max lengths `name` 120, `phone` 40, `address` 500, `profileImage` 2048.
- `AuthUpdateProfileDto` (PATCH `/auth/edit-profile`):
  - `name`: now `@IsNotEmpty` and max 120.
  - `phone`: max 40. `address`: max 500. `fcmToken`: max 1024.
  - `profileImage`: max 2048 and **must match `^https://`**. An empty string or an `http://` URL now gives a 400.
  - New optional `displayCurrency` (`^[A-Z]{3}$`) and `detectedCountry` (`^[A-Z]{2}$`).
- `CreateAdminDto` deleted.

#### d) Response shape
- `GET /auth/getprofile`: `data` is now `{...user.toJSON(), hasPassword: boolean}` (additive).
- `become-seller`, `switch-to-buyer` and `create-buyer-account` return `{success, message, data:{user:{id,name,email,role,image}, token:{accessToken,refreshToken}}}`, which is the same shape as login.
- `POST /auth/refresh`: shape unchanged (`data.token`).

#### e) Business rules
- **Removed:** `POST /api/auth/admin/create-admin`. Admin accounts are now created through staff invites.
- Admin only: access TTL is 2 h. Refresh tokens are single-use (jti in Redis), and reusing one revokes all sessions. After 5 failed logins the account is locked for 15 min (429). Staff must pass TOTP. `forgot-password` and `reset-password` with `role:'admin'` now return 400 (no e-mail reset). Buyer and seller tokens are unchanged (24 h access, 7 d refresh, no rotation).
- Register: an existing **unverified** account with the same email is now taken over by the new sign-up. Before, this returned "User already exists". If the OTP e-mail fails, the response is **503** with a readable message. Before, the account was saved and the failure was silent.
- Resend-OTP expiry dropped from 10 min to **5 min**. Sign-up was already 5 min.
- Seller login with the email of a buyer-only account, when the password is correct, now returns 401 "This account doesn't have a seller store - sign in as Buyer or create a store".
- Password login on a social-only account (no hash) now returns a clean 401. Before, it returned a 500.
- Facebook social login now fails closed unless `FACEBOOK_APP_ID` and `FACEBOOK_APP_SECRET` are set and `debug_token` confirms the app id and user id. Apple accepts several audiences (`APPLE_CLIENT_IDS`) and fails closed if none are configured.
- Social login that verifies an unverified email clears the old password and OTP and bumps `tokenVersion` (pre-hijack guard).
- `edit-profile`: changing `phone` resets `phoneVerified` and `phoneE164`. `detectedCountry` is written once only (buyer).

#### APP IMPACT
- `lib/app/modules/otp/views/otp_view.dart:130` says "expires in 10 minutes", but every OTP now lasts 5 minutes. This is a copy fix only.
- Seller edit profile (`lib/app/modules/seller_edit_profile/controllers/seller_edit_profile_controller.dart:171-176`) sends `email`. The DTO has no `email`, so the field is silently stripped, the same as before. It is not a regression, but the editable seller email field (`seller_edit_profile_view.dart:221`) never saves.
- `profileImage: imageUrl ?? user.value?.profileImage` (same controller, line 175) re-sends the stored image. That is fine for Cloudinary `secure_url` and Google/Apple avatars (https). It fails with a 400 only if an account has a legacy `http://` URL stored (unverified, data-dependent).
- Login, register, verifyOtp, refresh and the account switch: the request and response shapes the app uses are unchanged.

### 2. users (`src/users`)

#### c) DTO
- New `DeleteAccountDto` for `DELETE /users/profile`: `confirm` is **required** and must be "DELETE" (max 20 chars). `password` is optional (max 200) but **required in practice for any account that has a password**.
- `UpdateProfileDto` (PUT `/users/profile`): `phone` max 40, `address` max 500, `profileImage` must be https and at most 2048 chars, plus new `displayCurrency` and `detectedCountry`.

#### d) Response
- `getProfile` and `updateProfile` no longer return `otpAttempts` or `tokenVersion`.
- New `PUT /users/logout-others` returns `{data:{token:{accessToken,refreshToken}}}`.

#### e) Business rules
- **Account deletion** needs:
  - the typed confirmation;
  - the password (when the account has one): missing gives 400 "Enter your password to delete your account.", wrong gives 401;
  - no blockers. Blockers return **409** `{code:'ACCOUNT_DELETE_BLOCKED', message, blockers[]}`:
    - buyer: open orders (pending/processing/partially_shipped) or active Premium;
    - seller: open customer orders, pending payouts, or a non-zero wallet balance.

  The route is throttled to 5 per minute.
- **Email can no longer be changed** through PUT `/users/profile`. A different email (compared case-insensitively) returns 400 "Email cannot be changed from here. Contact support...". Before, the email was changed and `isVerified` was set to false.
- A phone change resets phone verification.

#### APP IMPACT
- **BREAKING (seller):** `lib/app/modules/seller_settings/controllers/seller_settings_controller.dart:361` calls `_authRepository.deleteAccount()` with **no password**. The repository (`lib/app/data/repositories/auth_repository.dart:514-525`) sends only `{confirm:'DELETE'}`. Every seller with a password now gets 400 "Enter your password to delete your account." Only social-only sellers can delete.
- Buyer deletion (`lib/app/modules/profile/controllers/profile_controller.dart:702-760`) already asks for an optional password and shows the server message. This works.
- **Behaviour change (buyer):** the email field in `lib/app/modules/edit_profile/views/edit_profile_view.dart:72` is editable, and `profile_controller.dart:464` always sends it. If the user edits the email, the whole profile save now fails with 400. If the email is unchanged, the save succeeds.
- `profile_controller.dart:470` and `upload_repository.dart:174` send `profileImage` from Cloudinary, which is https and passes. Same legacy-`http` caveat as above.

### 3. address (`src/address`, routes `address/*` and `api/address/*`)

#### c) Validation (all new)
`pickAddressUpdate(body, requireAll)` now validates field formats:

| Field | Rule (old rule was "string, at most 200 chars") |
|---|---|
| `phoneNumber` | Pakistani mobile only: `03XXXXXXXXX`, `+923XXXXXXXXX` or `923XXXXXXXXX`; spaces and dashes ignored. Stored normalised as `+923XXXXXXXXX`. |
| `zipCode` | exactly 5 digits |
| `city` | letters and spaces only, at least 2 chars |
| `addressLine1` | at least 5 chars |
| `state` | must equal one of `Sindh`, `Punjab`, `Khyber Pakhtunkhwa`, `Balochistan`, `Islamabad Capital Territory`, `Gilgit-Baltistan`, `Azad Kashmir` (case-sensitive) |

- On **add**, `phoneNumber`, `zipCode`, `city`, `addressLine1` and `state` are **required**. On **update**, only the fields sent are validated, and the app sends all of them.
- A failure returns 400 `{message: <first error>, errors: {field: msg}}`.
- At most 20 addresses per user. The first address is always the default. If `addressLine2` repeats line 1, it is dropped.

#### d) Response
- Errors used to come back as **HTTP 200/201 `{message}`** (no `success`). They are now real 4xx exceptions.
- A seller session with no buyer record now gets 404 "No buyer account found for this sign-in...".

#### APP IMPACT
- **BREAKING (data-dependent):** `lib/app/modules/address/controllers/address_controller.dart:277-300` (`_validateForm`) only checks that fields are non-empty. The free-text inputs in `lib/app/modules/address/views/add_address_view.dart:33,43-45` (state, city, zip, phone) can easily violate the new rules: "sindh" in lowercase, "Islamabad", "Karachi.", a 6-digit zip, a non-PK or landline number, or a short line 1. Each of these is now rejected with a 400. The save path (`address_controller.dart:131-176`, which calls `address_repository.dart:74` and `:103`) catches every error and shows the generic toast **"Failed to save address"** (line 174). The server's per-field `message` and `errors` never reach the user. Editing an old address that was saved under the old rules fails the same way.
- The fix: make state a dropdown of the 7 provinces, validate zip, phone, city and line 1 on the client with the same rules, and show `ApiError.fromDio(e)` and `errors[field]` instead of the fixed toast.
- Reads (`getMyAddresses`, `get-address-by-id`) are unchanged. `phoneNumber` comes back normalised as `+923…`.

### 4. otp (`src/otp`)
- Internal only. Mail goes through the shared `common/mailer.util` (Brevo API or SMTP). The subject and body text changed. `sendOtp` now **throws** on failure, which auth maps to 503. There is no HTTP contract change beyond the 503 noted under auth.

### 5. phone-verification (`src/phone-verification`, new module)
- New routes under `api/auth/phone`:
  - `GET availability` (public): whether a WhatsApp/SMS channel is configured.
  - `GET status` (user/seller).
  - `POST send` with `{phone (max 25), lang?: 'en'|'ur'}`.
  - `POST verify` with `{phone, otp (max 10)}`.
- Sets `phoneVerified`, `phoneE164` and `phoneVerifiedAt` on users and sellers. A verified number is unique across accounts.
- Verification is **not enforced** anywhere: nothing outside the module and the reset logic reads `phoneVerified`. The app does not use these routes. Not breaking.

### 6. categories (`src/categories`)

#### c) and e)
- Nesting depth goes from 2 levels to **4** (`MAX_CATEGORY_DEPTH`).
- `add-category` gained `AdminReauthGuard`. The guard returns early for any non-admin role, so **sellers are unaffected**. Seller rules in `addCategory` are unchanged.
- Admin delete gets `?deleteChildren=true`, and reassignment is depth-aware. The admin routes PATCH `category/:id`, `reorder` and DELETE now need reauth; the app does not use them.

#### d) Response
`GET /categories/category-tree[?id=]`:
- Nodes are nested to any depth and sorted by `sortOrder`.
- New fields on every node: `coverImages: string[]` (up to 4 product photos) and `coverImage: string|null`.
- `productCount` semantics: a root counts all its products; a subcategory counts its own products plus its descendants'. Products from test products or inactive stores are excluded.
- With `?id=`, the matching subtree comes from the cached full tree. An unknown or inactive id still returns 404.
- Top-level shape `{success, message, data}` is unchanged.

#### APP IMPACT
- Not breaking. `lib/app/data/repositories/category_repository.dart:18-54` parses `data` as a list of `CategoryModel` with `children`, so the new fields are ignored.
- 3rd and 4th level nodes show up only if the UI recurses (`category_with_children_response.dart:25` reads direct children only). This is a UI limitation, unverified.

#### New
- `POST /categories/requests`, `GET /categories/requests?storeId=`, `GET /categories/store-usage/:storeId`: a seller asks Edudeen for a new category. The pending count is capped per store.
- Admin: `GET /categories/admin/tree`, `GET /categories/admin/requests`, `PATCH /categories/admin/requests/:id/decision`.

### 7. search (`src/search`)

#### c) Query params (all optional, additive)
- `suggest=1`: search-as-you-type mode. The term is not recorded in history.
- `exact=1`: disables typo correction.

#### d) Response (additive)
`GET /search/products` can now return:
- `correctedQuery` and `originalQuery`: zero hits, so the results are for the corrected spelling;
- `didYouMean`: two or fewer hits;
- `aiAssisted: true` with message "Showing smart-search matches": AI fallback on page 1 when there are zero hits and `limit >= 8`.

`data.{total,page,limit,products}` is unchanged.

#### New
- `GET /search/trending?limit=` (public): `{success, data:[{query, searches}]}`. These are terms searched by at least 2 distinct users in the last 14 days, cached for 10 min.

#### APP IMPACT
- Not breaking.
- `lib/app/modules/search/controllers/search_controller.dart:96-100` searches every 400 ms while the user types, without `suggest=1`, so half-typed terms still land in the buyer's recent searches. Adding `suggest: '1'` in `lib/app/data/repositories/search_repository.dart:27` for debounced calls fixes this.
- `loadPopularSearches()` (`search_controller.dart:380`) is a stub that waits for an endpoint. `GET /search/trending` is that endpoint.
- The app ignores `correctedQuery` and `didYouMean`. The user may see results for a corrected term with no hint.

### 8. wishlist (lives in `src/cart`: `cart.controller.ts` and `cart.service.ts`)
- `remove-from-wishlist` and `clear-wishlist`: `storeId` is now **optional** (`OptionalParseObjectIdPipe`). Before, it was required. `get-wishlist` and `get-wishlist-item` without `storeId` return the wishlist across all stores.
- `get-wishlist` response is unchanged: `[{product, variants[]}]`. The product goes through `sanitizeDigitalForPublicView` as before, but is now batched.
- Wishlist sharing is new under `src/retention`: `POST/DELETE /api/wishlist-share`, `GET /api/wishlist-share/mine`, `GET /api/wishlist-share/public/:token`.

#### APP IMPACT
This is a **fix** for the app. `lib/app/data/repositories/wishlist_repository.dart:107` (clear) and `:118-125` (remove) send no `storeId`. These calls returned 400 under the old backend and now work. The share routes are unused.

### 9. notifications (`src/notifications`)

#### c) DTO
`PATCH /notifications/preferences` accepts these new optional fields:
- `whatsappEnabled`, `smsEnabled`, `retentionChannelsEnabled` (booleans);
- `language` (`'en'|'ur'`).

`retentionChannelsEnabled: true` without WhatsApp or SMS on returns 400. Switching both channels off forces it to false.

#### d) Response
- `GET preferences` returns the new fields (defaults false and `'en'`). Get-or-create is now atomic, which fixes the E11000 500 error on parallel first calls.
- Other list and count shapes are unchanged.

#### e) Types
- **Removed:** `subscription_renewal_reminder`, `subscription_payment_failed`, `subscription_cancelled`, `verification_under_review`.
- **Added:**
  - Returns and refunds: `return_requested`, `return_approved`, `return_rejected`, `refund_requested`, `refund_approved`, `refund_rejected`.
  - Listings and products: `listing_approved`, `listing_rejected`, `listing_in_review`, `listing_fix_requested`, `product_scheduled`, `product_published`, `product_question`, `question_answered`, `out_of_stock`.
  - Reviews: `review_received`, `review_replied`, `review_requested`, `review_report_decided`.
  - Retention and wishlist: `cart_reminder`, `wishlist_back_in_stock`, `wishlist_price_drop`, `referral_reward`, `download_link_resent`.
  - Premium: `premium_payment_submitted`, `premium_activated`, `premium_payment_rejected`, `premium_expiring_soon`, `premium_expired`, `premium_coupon`.
  - Store and other: `platform_campaign_live`, `support_reply`, `store_deleted`, `store_holiday_ended`, `category_request_approved`, `category_request_rejected`.
- Order notifications now carry `data.link` (commit 8dff1ad).
- Optional WhatsApp/SMS fan-out goes to opted-in buyers only.
- Each notification also emits a `changed` signal on the new `/realtime` socket.

#### New
- `DELETE /notifications/clear-read`: deletes all read notifications and returns `{data:{deleted}}`.

#### APP IMPACT
- Not breaking. `lib/app/modules/notifications/controllers/notifications_controller.dart:129-132` (subscription_* to `Routes.myMemberships`) and `lib/app/data/models/common_models/notification_model.dart:30` (`verification_under_review`) are dead code.
- Buyer taps on the new types (premium_*, return_*/refund_* for buyers, review_*, wishlist_*, question_answered, download_link_resent, cart_reminder) work only if `DeepLinkRouter.open(data.link)` (`notifications_controller.dart:94`) maps the link. Otherwise the tap does nothing.
- `_mapBackendType` files all new types under the "system" tab.
- The preferences screen does not expose the WhatsApp/SMS/language options.

### 10. messaging (`src/messaging`)

#### c) DTO
- `StartConversationDto` gets optional `productId` and `orderId` (MongoId), stored as the thread's context. An invalid or foreign id is silently ignored.
- New `SellerStartConversationDto` `{storeId, buyerId}`.
- New `CreateQuickReplyDto` / `UpdateQuickReplyDto`: `storeId`, `title` (1-60), `body` (1-1000), `category` in [download_help, order_status, refund_policy, course_access, general].
- New admin `AdminUpdateMessagingReportDto`.

#### d) Response
- Conversation documents gain `startedBySeller`, `contextProductId`, `contextOrderId`.
- Product-share snapshots gain `currency`.
- Admin lists gain names.
- `POST /messaging/seller/start` returns the bare object `{conversationId, _id}` with no `success` wrapper.

#### e) Rules
- `isPriority` is **no longer computed**: the subscriptions "priority_support" benefit was removed. New conversations default to false. Old ones keep their stored value. The seller inbox still sorts by it.
- A seller can open a thread only with a "student" of their store: someone with a paid or free-claimed, non-cancelled digital item that is not a test product. Blocks are checked.
- Seller-opened threads with no message are hidden from the buyer inbox.
- Search regexes are escaped and capped at 100 chars.
- Mark-seen compares ids as strings.

#### APP IMPACT
- Not breaking. `seller_students_repository.dart:201-206` already parses `{conversationId|_id}`.
- `lib/app/modules/seller_messages/widgets/conversation_tile.dart:90` (`isPriority` badge) is effectively dead, or stale on old threads.
- `messaging_repository.dart:22-27` does not pass `productId` or `orderId` context, so that feature is unused.

#### New (unused by the app)
- `GET/POST/PATCH/DELETE /messaging/seller/quick-replies[/:id]`: canned seller replies.
- `GET /messaging/seller/conversations/:id/context`: buyer-details panel with product, order, recent orders and stats.
- `PATCH /messaging/admin/reports/:id`: admin.

### 11. chatbot (`src/chatbot`, entirely new since a5cba9f)
- `POST /api/chatbot/message` (optional JWT, 20/min) takes:
  - `audience` ('buyer'|'seller'), required;
  - `text` (1-1000), required;
  - `lang` ('en'|'ur'), optional;
  - `langNoticeShown`, optional;
  - `guestToken` (max 100), optional;
  - `guest {name, email, phone}`, optional.

  It returns `{success, data:{reply, quickReplies, actions, source, lang, conversationId?, escalation?{conversationId, shortCode, status, messageId, guestToken?, notice}}}`. `source` is one of faq, greeting, ai, fallback, escalated, needs_contact, rate_limited.
- `GET /api/chatbot/conversation?since=&guestToken=&markRead=` returns `{data:{conversation, serverTime}}`.
- `POST /api/chatbot/conversation/message {text, guestToken?}` adds a follow-up to the active conversation. It returns 404 if there is none.
- **guestToken rule:**
  - A guest's active conversation is found **only** through `guestToken`.
  - When a guest question is escalated with no token, the backend requires `guest` contact details (otherwise `needs_contact`). It then creates a **new** conversation and issues a **new** token.
- Admin inbox: `/api/admin/chat/conversations`, `/:id`, `/:id/reply`, `/:id/close`, `/stats`.

#### APP IMPACT
- **Contract gap (guest only):** `lib/app/modules/support_chat/controllers/support_chat_controller.dart:140-147` posts to `/chatbot/message` without `guestToken`, even when it holds one (`_guestToken`, line 66/89). Polling (line 206) sends it correctly.
- Result: each unanswered question from a signed-out user after the first escalation either asks for contact details again (`needs_contact`), or opens a second conversation with a new token. The app then overwrites the stored token at line 181-183, so team replies on the first thread are lost.
- Fix: add `if (!signedIn.value && _guestToken != null) 'guestToken': _guestToken` to that body. Better still, send follow-ups through `ApiConstants.chatbotConversationMessage`, which is defined but never used.
- Signed-in users are unaffected, because the conversation is looked up by userId.
- `lang` is `LocaleService.current.languageCode`, which is only 'en' or 'ur' (`lib/core/i18n/locale_service.dart:12-13`), so it passes the `IsIn` check.

### 12. children (`src/children`, new)
- `GET/POST /api/children`, `PATCH/DELETE /api/children/:id` (role `user`). The body is `{name, educationLevel, gradeLabel (class value), age, subjects[]}`. The number of children is capped by the Premium `childrenLimit`.
- The app does not use these routes. Not breaking.

### 13. premium (`src/premium`, new buyer Premium program, replaces part of the removed subscriptions module)
- Buyer routes:
  - `GET /premium/plans`, `GET /premium/terms` (public).
  - `GET /premium/me` (entitlements), `GET /premium/bank-details`, `GET /premium/payments`.
  - `POST /premium/subscribe {planId, interval:'monthly'|'yearly'}`.
  - `POST /premium/payments/:paymentId/proof {transactionReference?, senderName?}` (bank-transfer proof).
  - `POST /premium/cancel`, `POST /premium/resume`.
- Seller route: `GET /premium/seller/conflicts`.
- Admin routes are under `/admin/premium/*`.
- Side effects in my modules:
  - Account deletion is blocked while Premium is active.
  - The contact form flags Premium members as priority.
  - The children limit comes from Premium.
  - Premium notification types are listed under §9.
- The app does not use these routes. Its old `buyer_memberships_repository` points at the removed subscriptions module, which is covered elsewhere.

### 14. upload (`src/upload`)

#### c) Limits and validation
- `POST /upload/file`: max size **100 MB down to 20 MB**. The content is byte-sniffed (`assertFileContent`), so the declared MIME is overridden or rejected. An optional `purpose` adds store-logo or cover rules; an unknown purpose returns 400.
- `POST /upload/private-file`: still 500 MB. Content is now sniffed. Storage may be R2, with `publicId` prefixed `r2/`, which the app treats as opaque. Response shape is unchanged.
- `POST /upload` (admin) now needs reauth.

#### New
- `POST /upload/product-video` (seller): mp4, mov or webm, max 60 MB. Returns `{url, publicId, ..., posterUrl}`.

#### APP IMPACT
- Not breaking. `lib/app/data/repositories/upload_repository.dart:51` caps public uploads at 5 MB on the client. Course videos use `private-file` (`seller_course_repository.dart:225-250`, 500 MB cap), and that limit is unchanged.

### 15. realtime (`src/realtime`, new)
- New socket.io namespace `/realtime`. It sends `changed` events carrying topic names only. Guests get public topics; signed-in users join `user:<id>`, and sellers also join `store:<id>` rooms.
- The existing `/notifications` socket still emits `notification:new`, and now also triggers a realtime `changed` event.
- The app does not connect to `/realtime`. Its messaging and notifications sockets are unchanged. Not breaking.

### 16. faqs / contact (testimonials: no change in `src/testimonials`; the app uses `store/public/testimonials`, which is outside this scope)
- FAQs: admin writes need reauth. `search` with an empty query returns an empty list instead of a 500. Public routes are unchanged.
- Contact: `POST /contact` now uses an optional JWT. Only a **signed-in** active Premium buyer is flagged `priority`. The body is unchanged.
- APP IMPACT: `lib/app/data/repositories/contact_repository.dart:27` uses `requiresAuth: false`, so Premium priority is never applied (minor). Otherwise this is not breaking.

---

### New backend features in scope that the app does not use yet

| Route | Purpose |
|---|---|
| `PUT /api/users/logout-others` | Sign out of all other devices and return a fresh token pair |
| `GET /api/auth/phone/availability`, `GET status`, `POST send`, `POST verify` | Phone verification by WhatsApp/SMS OTP |
| `GET /api/search/trending` | Popular search terms; fills the stub at `search_controller.dart:380` |
| `?suggest=1` / `?exact=1` on `/search/products` | Type-ahead without saving history, and no spell-fix |
| `POST/GET /api/categories/requests`, `GET /api/categories/store-usage/:storeId` | Seller requests a new category, and sees per-store category usage |
| `DELETE /api/notifications/clear-read` | Delete all read notifications |
| Preference fields `whatsappEnabled`, `smsEnabled`, `retentionChannelsEnabled`, `language` | Opt-in WhatsApp/SMS channels |
| `GET/POST/PATCH/DELETE /api/messaging/seller/quick-replies` | Seller canned replies |
| `GET /api/messaging/seller/conversations/:id/context` | Buyer-details side panel in seller chat |
| `productId` / `orderId` on `POST /messaging/conversations` | "Asking about this product/order" context |
| `POST /api/chatbot/conversation/message` | Follow-up inside an escalated support chat (constant defined, never called) |
| `GET/POST/PATCH/DELETE /api/children` | Child profiles (class or grade, subjects) for recommendations |
| `/api/premium/*` (plans, terms, me, bank-details, payments, subscribe, proof, cancel, resume, seller/conflicts) | Edudeen Premium buyer membership |
| `POST /api/upload/product-video` | Seller product video upload with a poster |
| `wishlist-share` (POST, DELETE, `mine`, `public/:token`) | Shareable wishlist link |
| socket namespace `/realtime` | Live "something changed" refresh signals |

---

### BREAKING for the app

| Call | App file:line | What breaks | Fix needed |
|---|---|---|---|
| `DELETE /api/users/profile` (seller) | `lib/app/modules/seller_settings/controllers/seller_settings_controller.dart:361` (repo `lib/app/data/repositories/auth_repository.dart:514-525`) | Seller deletion sends no `password`. Any seller with a password gets 400 "Enter your password to delete your account." Open orders, payouts or wallet balance give a 409 blocker message (that message is already shown). | Add a password field to the seller delete dialog, as the buyer flow does in `profile_controller.dart:702-760`, and pass `password:` to `deleteAccount` |
| `POST /address/add-address`, `POST /address/update-address` | `lib/app/modules/address/controllers/address_controller.dart:131-176` (validation `:277-300`, generic toast `:174`), view `add_address_view.dart:33,43-45`, repo `address_repository.dart:74,103` | New server validation: PK mobile only, 5-digit zip, letters-only city, line 1 at least 5 chars, `state` exactly one of 7 province names (case-sensitive). Free-text input is often rejected with a 400, including when editing old addresses. The app hides the reason behind "Failed to save address". | State dropdown with the 7 exact names. Client-side rules that match the server. Show `ApiError.fromDio(e)` and the per-field `errors` |
| `POST /api/chatbot/message` (guest) | `lib/app/modules/support_chat/controllers/support_chat_controller.dart:140-147` (token overwrite `:180-183`) | `guestToken` is never sent, so a signed-out user's follow-up questions are asked for contact details again or open a new conversation with a new token. Team replies on the first thread are lost. | Send `guestToken` when signed out, and/or route follow-ups through `/chatbot/conversation/message` (`ApiConstants.chatbotConversationMessage`) |
| `PUT /api/users/profile` with a changed `email` (buyer) | `lib/app/modules/profile/controllers/profile_controller.dart:464`, field `lib/app/modules/edit_profile/views/edit_profile_view.dart:72` | Editing the email makes the whole save fail with 400 "Email cannot be changed from here…". It used to change the email. | Make the email field read-only, or drop `email` from the update body |
| (minor) OTP copy | `lib/app/modules/otp/views/otp_view.dart:130` | Says 10 minutes; every OTP now expires in 5 | Change the text to 5 minutes |

Not breaking but worth fixing: dead `subscription_*` and `verification_under_review` notification cases (`notifications_controller.dart:129-132`, `notification_model.dart:30`); the dead `isPriority` badge (`conversation_tile.dart:90`); type-ahead search without `suggest=1` (`search_repository.dart:27`); seller email field that silently never saves (`seller_edit_profile_view.dart:221`).

---

## Appendix B — commerce modules

## Commerce modules: backend diff a5cba9f..HEAD (5adba44) and impact on the app

Scope: products, product-variants, inventory, cart, checkout, payment, manual-payments, orders, refund-request, rating, couriers, collections, exchange-rate.
Backend = `edudeen_api/src/...`, App = `edudeen-app/lib/...`. Everything below was checked against the code unless marked **unverified**.

General finding: the `full-app` branch already follows much of the new API. It has client rules for coverStyle and class range, sends `storeId` on mark-paid, handles `partially_paid`, and already calls bulk-status, bulk-offers, stock/bulk, duplicate, low-stock-threshold, stock-history, seller-free-claims, seller-returns-all and return-follow-up. The real breakages are listed in the final table.

---

### products

#### c) DTO / validation (create/edit bodies are `any`, checked in `products.service.ts` and `product-input.util.ts`)
- **`productType: 'educational'` retired.** Create and edit return 400 "Educational products are no longer available. Choose digital." (`products.service.ts:1855,2132`). `ProductType` enum now has only physical/digital. `products-by-category?productType=educational` is mapped to `digital`.
- **Product status enum** now includes `pending_review` and `rejected`, set only by admin review. New fields: `approvedAt`, `reviewNote`, `reviewedAt`.
- **New required checks on create (drafts too):**
  - `description` is required and must be at least 20 characters after trimming (`assertDescriptionRule`, `price-rules.util.ts:44`).
  - Title must be at least 10 characters (`assertTitleRule`, `MIN_TITLE_LENGTH = 10`).
  - Physical variants: `shippingWeight` is required on create, 1 g to 50 kg, in a format like "0.5 kg", "500g" or "0.6" (`cleanShippingWeight(…, true)`). On edit or variant PATCH it is checked only when sent, and clearing it is rejected.
  - Prices: no negative prices. PKR must be whole rupees and other currencies allow at most 2 decimals. `compareAtPrice` must be strictly higher than `price` (`assertPriceRules`).
  - Stock: a whole number from 0 to 100,000 (`assertStockRule`). Bulk `stock/bulk` still allows up to 1,000,000, so the two limits disagree.
  - `images` max 20 (`UpdateProductDto` `ArrayMaxSize(20)`). New optional fields: `descriptionImages` (max 6), `video`.
- **Publish-time rules (`checkListing`, `products.service.ts:1975`)**, applied when the status moves to active or scheduled:
  - Digital listings need `classFrom` or `classTo`. Physical listings do not.
  - `coverStyle` must be `'book'` or `'flat'` for anything except `deliveryFormat='course'`. Physical products count as download here, so they need it too.
  - Re-saving a live product with the same status is exempt.
- **New optional fields:**
  - `curricula[]` (12 board codes)
  - `ageMin`/`ageMax` (0–99)
  - `classFrom`/`classTo` (values `nursery … university` in `class-levels.ts`). One side alone means that single class, and from cannot be after to.
  - `language` (ur/en/ar/mixed)
  - `author`/`publisher`/`edition` (120/120/60 characters)
  - `parcelType` (document/standard/fragile/bulky, default `standard`), `packageCm`, `dispatchDaysOverride` (1–7)
  - `campaignIds[]` (max 10), `premiumDiscountPercent` (1–50), `premiumOptOut`, `licenseTiers[]` (max 3)
  - `lowStockThreshold`
- **`deliveryFormat`** is `download` or `course`. `live_class` returns 400 "Live classes are no longer available…".
- **`digital.sampleFile`** `{url,name}` is accepted, but the server does **not** require it to publish. The app requires it (`publish_rules.dart:92`), which is stricter but harmless.
- `digital.pageCount` and `files[].pageCount` are filled server-side.
- Filters removed from `products-by-category`: `educationLevel` and `normalizedCustomLevel` are no longer read. Added: `q`, `curriculum`, `age`, `featured`, `class`, `exact`, `format=course`. The `limit` cap rose from 50 to 100.

#### d) Response shape
- `getProductById`: same envelope `{product, variants, defaultVariant, canReview?, hasReviewed?}`.
  - `product.sellerName` is now the **store name**.
  - The public product no longer carries `isDelete`, `isTest`, `ratingSum`, `normalizedCustomLevel`, review/moderation fields, `digital.sampleFile` or `liveSession`.
  - Added: `needsReview` (bool), `digital.fileFormats`, plus the premium/campaign fields on variants.
  - Old slugs resolve through `previousSlugs`.
- `products-by-category`: same `{total,page,limit,products}`. It may add top-level `didYouMean`, `correctedQuery` and `originalQuery` when `q` is used.
- `edit-product`: `data` now has `{product, pendingReview, variant, warnings, contactFlag}`, and the message changes when the edit is held. Create also returns `warnings` and `contactFlag`.
- `get-my-product`: returns the seller's pending edit overlaid on the product, plus `categoryName` and `subCategoryName`.

#### e) Business rules
- **Listing review:**
  - The first publish of a listing goes to `pending_review` unless the store has an active **paid** platform plan (`resolveSellerPublishStatus`, `sellerSkipsListingReview`). `LISTING_APPROVAL_REQUIRED=false` turns this off.
  - Text containing contact info (phone, WhatsApp or email) is forced to `pending_review`.
  - A non-blocking `needs_review` quality flag covers vague titles, duplicate title plus price, class conflicts and few images.
- **Edits to a live, approved listing** are held in `pendingEdit` until an admin approves them. This includes digital price changes and variant price/compareAt changes made through `PATCH /products/:id/variants/:vid`. Buyers keep seeing the old values.
- When a store's platform plan lapses, its listings are hidden (`pausedFromStatus`). They are restored when a plan becomes active again.
- Premium: the seller's sale price must stay below the Premium price by the admin gap (`assertPremiumGap`). A product can have a Premium offer or a platform campaign, never both (`assertOfferExclusive`). Campaign membership is strict per-product opt-in through `campaignIds`.
- Per-seller sequential SKUs (`STORE-id-YYMMDD-NNNN`) when no SKU is sent.
- `GET /products/sample/:id` returns 404 unless the env `PUBLIC_FREE_SAMPLE=true`. Buyer free samples are switched off.

#### APP IMPACT
- **Create physical product with no shipping weight → 400** "Shipping weight is required". `variant_entry.dart:76` sends `shippingWeight: null` when the field is empty, and `variant_card.dart:137-147` does not mark it required. This also hits `addVariant` (`edit_seller_product_controller.dart:476` → `seller_product_repository.dart:681`).
- **Create product (physical or digital, including drafts) with an empty description → 400** "description is required". With fewer than 20 characters → 400 "Description must be at least 20 characters". `add_seller_product_controller.dart:621,700` sends `null` when empty, `seller_product_repository.dart:541-542` drops the key, and `canProceed` (`add_seller_product_controller.dart:297-309`) checks only the name and price.
- **Title shorter than 10 characters → 400.** The app checks only that it is non-empty (`add_seller_product_controller.dart:307`).
- Price rules: the app sends a double. A value like `300.0` arrives as an integer and passes. A non-integer PKR value, or compare-at less than or equal to price, now returns 400. `PriceRules` (`lib/utils/price_rules.dart`) does not check either.
- **Live-listing price edits are held, but the app reports success.** `setDigitalPrice` (`seller_product_repository.dart:219`), `setVariantPrice` (`:231`) and `editPhysicalProduct` (`:395-398`) treat `success:true` as applied and ignore `data.pendingReview`. Nothing fails, but the UI is misleading.
  **[Corrected by the report author]** This claim is wrong. Edit-review is disabled in HEAD: `src/products/product-edit-review.util.ts:29` has `const hold = false && …` ("disabled: edits are not reviewed"), so live edits apply immediately and `pendingReview` is only true when a `pendingEdit` already exists. Not an app issue.
- `educationLevel`/`normalizedCustomLevel` filters are silently ignored. `api_constaints.dart:142-147` still sends them, and the filter sheet (`product_filter_bottom_sheet.dart`) has no effect. The `education/facets` part is already known. The replacement is `class=<slug>`.
- `'educational'` handling in the app is read-only (`seller_products_controller.dart:160`, `product_model.dart:364`). Create sends only `'digital'` (`seller_product_repository.dart:443`). OK.

### product-variants
- c) The variant POST now enforces `assertPriceRules`, `assertStockRule` and `cleanShippingWeight(required=true)` (`product-variants.service.ts:84-86`), plus the Premium gap check. PATCH re-checks price, compareAt and stock, and checks weight only when sent. The DTO files are unchanged.
- d) PATCH on an approved live listing returns the variant with the seller's **pending** price overlaid. The live price does not change.
- e) Auto SKU comes from `allocateSkus`.
- APP: an empty weight on `addVariant` returns 400 (see products above). `setVariantPrice` gets held silently (see above).

### inventory
- c) `getStoreInventory` query:
  - New params: `stockState` (low|out|in|unlimited), `sortBy` (name|price|stock|status), `order`, `deliveryFormat`, `categoryId`, `noSubcategory`, `q`, `quality=low`, `sort=views|sales`.
  - **An unknown `stockState`, `sortBy` or `order` value returns 400.** `status` accepts a comma-separated list. The `limit` cap is 100.
- d) Same `{stats, pagination:{page,limit,totalPages,totalProducts}, products}`.
  - `stats` gains `unlimited` and `statusCounts`.
  - Rows gain `courseSummary`.
  - The low-stock line is per product: `lowStockThreshold`, default 10.
- New: `GET stock-history/:storeId/:productId` → `{items:[{id,old,new,source,createdAt}]}`, up to 20 rows. `PATCH low-stock-threshold/:storeId/:productId {threshold: 0..1000|null}`.
- APP: `seller_inventory_repository.dart:51-70` sends only page, limit, type and q, and parses stats and pagination correctly. The stock-history parser (`:36-40`) matches. **No breakage.**

### cart
- c) No DTO change. `remove-from-wishlist` and `clear-wishlist` no longer require `storeId`.
- d) `get-cart` / `my-carts` / `unified`:
  - Additive fields: `currency`, `campaignDiscount`, `totalAfterDiscount`, `isPremium`, `premiumSavings`.
  - Per line: `type`, `deliveryFormat`, `onCampaign`, `campaignUnitPrice`, `premiumUnitPrice`, `listPrice`, `holidayBlocked`, `holidayText`, and `store.holiday`.
  - `unitPrice` is now the **live** variant price.
  - Lines for inactive or deleted products are dropped.
  - `sellerName` is now the store name.
- e) Business rules:
  - **Digital items are capped at quantity 1.** Add-to-cart clamps to 1. A repeat add returns "Digital items are limited to one per order". **`update-cart-quantity` with `increase` on a digital line returns 400** (`cart.service.ts:171-174`).
  - A store in holiday mode blocks add-to-cart (400) for the affected type. Live-class products return 400.
  - Campaign and Premium prices are applied in the cart.
- New `GET /cart/buy-now?productId&variantId&quantity`.
- APP:
  - `cart_controller.dart:167` only checks the 1000 cap, so tapping + on a digital line returns 400. The error is shown and the request fails.
  - A guest's local cart can hold a digital qty > 1, which is clamped to 1 on sync.
  - Cart totals are computed locally from `unitPrice` and do not reflect `campaignDiscount` or Premium prices (display only).

### checkout
- c) `create-checkout` body now reads:
  - `shippingZoneId` and **`addressId`**. The buyer's chosen address is now honoured. An unknown `addressId` returns 400.
  - `buyNow {productId, variantId, quantity 1..99}`.
  - `items[]` may carry an explicit quantity.
  - **New hard rule: when the cart has physical items and any active shipping zone exists, a missing `shippingZoneId` returns 400 "Choose a delivery option for your address"** (`checkout.service.ts`, the createCheckoutInner block "Once an admin has set up delivery zones…").
- d) create-checkout response:
  - **Removed `subscriptionSavingsHints`.**
  - Added `cod {available, reason, maxPerPackage, feePerPackage, packageCount, feeTotal, feeByStore}`.
  - `allowedPaymentMethods` may include `jazzcash` and `easypaisa` (PKR only).
  - `summary.shippingFee` and `totalAmount` now include shipping, plus `premiumDiscountUSD`.
  - `checkout.shippingByStore[]` gains `giftWrapFee`, `courier`, `service`, `etaDays`, `source`. New fields `checkout.shippingEstimate` and `codFeeTotal`.
  - `addShippingInCheckout` adds `shippingByStore` and `shippingEstimate`.
  - `getShippingZones` now hides inactive zones.
- e) Business rules:
  - **Multi-store COD is allowed.** COD is offered when every physical store has `codEnabled`, and the admin's per-package limit is respected.
  - The admin COD fee per package applies only to packages collected by the Edudeen courier.
  - Shipping per store: the seller's own delivery fee, the weight-based table (off by default), or a courier quote. Optional gift wrap fee.
  - Coupon rules: start date, first-order-only, Premium-only coupons, per-customer limits, and a fixed coupon/gift-card ordering ("Remove your gift card first…").
  - Digital quantity is 1. Platform fee per product type, with `premiumFeePercent` frozen on each line (finance side).
- New routes: `GET delivery-info`, `GET/POST gift-options`, and admin shipping-zones and shipping-rates CRUD.
- APP:
  - **`cart_controller.dart:400` → `checkout_repository.dart:30-38` posts only `items` and attribution fields: no `shippingZoneId`, no `addressId`.** Any cart with a physical item now fails with 400 once zones are configured. The checkout screen fetches zones only after creation (`checkout_controller.dart:166-200`), which is too late.
  - The app does not send the selected address, so the server falls back to the default address.
  - `subscriptionSavingsHints` defaults to `[]` (`create_checkout_response.dart:27`), so nothing crashes.
  - The COD amount shown (`checkout_controller.dart:132`) and the auto-selected zone price (`:196`) ignore the COD fee and per-store shipping.

### payment
- c) `paymentType` enum adds `jazzcash` and `easypaisa`. The COD request body is unchanged.
- d)
  - `cod-payment`, `free-checkout`, `status` and similar calls: `formatOrder` adds `productId` to items, plus `paymentStatus`, `packages[] {storeId,status,packageIsPaid,packagePaidAt,codAmount,codCollector}` and `shippingEstimate`.
  - `GET /payment/status` can now return `status:'failed'` (hosted providers only).
  - A multi-package COD creates one pending `PaymentTransaction` per package.
- e) Business rules:
  - The old single-store COD restriction is removed.
  - The COD limit is enforced server-side (400 with the reason), and the fee is folded into the totals when the order is placed.
  - An order where every line is free at list price is marked `isFreeClaim` and excluded from seller orders.
  - The bank-transfer checkout requires a platform account to be configured.
  - Buy Now checkouts do not touch the cart.
- New: `POST /payment/pk/:provider/initiate` and the GET/POST callbacks.
- APP: `checkout_repository.dart:159-190` reads `data.orders[].orderId`, which is unchanged. **No breakage.** The COD total the app shows can be lower than the amount charged when an admin COD fee is set (display only).

### manual-payments
- c) `GET /payment/manual-transfer/bank-details` **now requires `?checkoutId=`** (`manual-payments.controller.ts:36`, service `getBankDetails`). Without it the server returns 400 "checkoutId is required". The data now comes from the platform transfer details, not `getManualPaymentConfig().enabled`.
- d) bank-details adds `payeeName`. The proof schema adds `storeId`, `proofHash`, `transactionReferenceKey`, `receiptCheck` and `ordersReleasedAt`.
- e) Business rules:
  - A rejected proof that is not fixed within `REJECTED_PROOF_HOLD_DAYS` auto-cancels the unpaid orders and restocks. After that, a re-upload returns 400 "…Please place a new order."
  - Duplicate-proof and AI receipt checks are advisory only.
- New `api/seller/manual-payments/:storeId/{settings,proofs,…}` routes exist, but **every handler answers 410 Gone** because bank transfers are platform-only.
- APP: **`manual_transfer_repository.dart:21` calls bank-details with no query**, so it gets 400 and the controller (`manual_transfer_controller.dart:44`) gets null. The manual bank transfer flow cannot load the bank details.

### orders
- c) Changes to existing routes:
  - `PUT mark-paid/:orderId` takes body `{storeId}`, which is **required** for multi-seller COD orders. A seller may mark only their own package, and only after it is shipped or delivered. `AdminReauthGuard`/`RequireReauth` affect admins only.
  - `POST cancel/:orderId` still requires `reason`. The new `seller-cancel` route requires `storeId`.
  - `update-status → shipped` requires `tracking {carrier, trackingNumber (unless "I deliver myself"), trackingUrl http(s), expectedDeliveryDate ≤120d, note ≤300}`.
  - `return-request` accepts optional `reasonCode`, `note` and `evidenceImages`.
  - Guards: `my-orders`, `:orderId`, `by-checkout`, `download-url`, `get-download-link` and `stream-pdf` now also allow the `seller` role (`by-checkout` uses ParseObjectIdPipe).
- Enums:
  - `paymentStatus` adds `partially_paid`.
  - New per-package fields: `isPaid`, `paidAt`, `codAmount`, `codCollector` (seller|platform), `dispatchDays`, `shipment`, `trackingEvents`, `cancelledBy`.
  - New item fields: `returnReasonCode`, `returnNote`, `returnEvidence`, `returnFollowUp` (item_received|replacement_sent), `returnHistory`.
  - New order fields: `isFreeClaim`, `giftMessage`, `giftWrap`, `shippingEstimate`, Premium totals.
- d) Response shapes:
  - Buyer views (`my-orders`, `:orderId`, `by-checkout`) are additive: `isFreeClaim`, `shippingEstimate`, `storeName`, `codCollector`, item `returnStatus` and related fields, `trackingEvents`, `packageIsPaid`, `codAmount`, `storeSlug`, store contact details. `sellerName` is now the store name.
  - `seller-orders/:storeId`:
    - New `?tab=` (needs_action|shipped|delivered|completed|cancelled|all; anything else returns 400), plus `buyer`, `action` and `q`.
    - Adds `counts` (when `tab` is sent) and row fields `itemCount`, `cancelReason`, `codAmount`, `codCollector`, `shipBy`, `possibleDuplicate`.
    - Per-row `isPaid` now includes the package paid state.
    - Stats add `orderValue` and `paidRevenue`. **`totalRevenue` and `avgOrder` are redefined**: all non-cancelled orders, where before only completed or delivered orders counted.
    - Free claims are excluded.
- e) Returns:
  - Respond-by 48 h is **display-only** (`seller-returns-all.util.ts:6`). No return window is enforced.
  - A follow-up is allowed only on approved returns.
- **Backend bug:** `orders.service.ts` is double-encoded. 49 occurrences of "—" became "â€”", including error messages returned to clients (`:921,924,942,1437,1447,2300,2309,2508`), e.g. "Order is already shipped â€” it can't go back…".
- APP:
  - `seller_orders_repository.dart:168-176` sends `{storeId}` on mark-paid, `:120-133` sends `tracking{carrier,trackingNumber,trackingUrl}` (`order_status_picker_sheet.dart:94-96`), and `:16-29` free claims match.
  - `my_order_model.dart:146-156` handles `partially_paid`.
  - Buyer cancel and return send `reason` (`order_repository.dart:100,125`).
- **Defect in an already-adopted new route, `seller-returns-all`.** Rows are `{source, requestId, itemIds, orderId, orderNumber, item, buyer, type:'Return'|'Refund only', reason, status, requestedAt, respondBy, isOverdue, amount, note?, evidenceImages?, followUp?, reasonLabel?}` (`seller-returns-all.util.ts:13-37`). The app parser in `seller_return_item.dart` reads other keys:
  - **`:106` id** reads `refundRequestId|_id|id`, so it falls back to `orderId`. **Refund-request approve and reject** (`seller_returns_controller.dart:111,123`) then call `/refund-request/<orderId>/approve|reject` → 404 "Refund request not found".
  - `:111` productName reads `productName|name|product.name`, so it is blank. The backend sends `item`.
  - `:103` photos reads `photos|images|returnPhotos`, so the evidence is lost. The backend sends `evidenceImages`.
  - The product type is never present, so `isDigital` is always false.

### refund-request
- c) `CreateRefundRequestDto`:
  - `reason` is now optional.
  - New `reasonCode`: damaged | missing_pages | printing_error | wrong_item | wrong_edition_or_class | not_as_described | digital_not_working | other.
  - `note`: 20–1000 characters, required when `reasonCode` is sent. A note or photos without `reasonCode` returns 400.
  - `evidenceImages`: max 4, physical items only, Edudeen-uploaded jpg/png/webp/heic/avif only.
  - **`RejectRefundRequestDto.notes`: minimum length raised from 3 to 10.**
  - New `FollowUpDto {step: item_received|replacement_sent, note≤500}`.
- d) The schema adds `reasonCode`, `note`, `evidenceImages`, `followUp`, `followUpNote` and `history[]`. `GET admin/pending` was replaced by `GET admin` (filters plus pagination).
- e) Paid status is checked per package (`isPackagePaid`), and there is a submit-race guard.
- APP:
  - Create (`refund_request_repository.dart:30-38`) sends only `reason`, which is still valid.
  - Reject UI enforces `minRejectChars = 10` (`seller_returns_controller.dart:27`). OK.
  - Breakage comes only from the wrong id described under orders/seller-returns-all.
  - `PATCH /refund-request/:id/follow-up` is unused, and the app hides follow-up for refund rows (`seller_return_item.dart:76`).

### rating
- c) Add and edit DTOs:
  - `comment` max 2000 characters.
  - `media` max 4 items, each max 1000 characters.
  - New optional `usedFor`: home | classroom | school.
  - The ValidationPipe uses `whitelist` without `forbidNonWhitelisted`, so extra keys are stripped, not rejected.
- d) Product reviews add `usedFor`. The seller store-reviews list adds `counts`, `productFilter`, `sellerReport`, `canEditReply`, `flaggedByAdmin` and `productTitle`, plus filter and sort params.
- e) Business rules:
  - A seller can **edit a reply only within 24 h** (403 after that).
  - Admin-flagged reviews can be unflagged only by an admin.
  - `DELETE rating/admin/:reviewId` is now **admin-only**; sellers are no longer allowed.
  - Notifications are sent on new reviews and on replies.
- APP: buyer add, edit and delete only (`rating_repository.dart:49-83`). No `media` is sent, and comments are not length-capped. A comment over 2000 characters would now return 400 (edge case). The app does not call seller reply or store-review routes. **No breakage.**

### couriers (new module, seller only)
- `GET /api/couriers`, `GET /couriers/options`, `POST /couriers/shipments {orderId, storeId, courier}`, `GET /couriers/shipments/label`, `POST /couriers/:courier/webhook`.
- Couriers are off ("Coming soon") until an admin enables and connects them. A package priced for one courier must be booked with that courier.
- Not used by the app.

### collections (store collections, seller)
- c) Name length is limited by `COLLECTION_NAME_MIN/MAX`, after a `cleanCollectionName` transform. New smart-rule fields: `priceMin`/`priceMax`, `createdWithinDays`, `minRating`, `hasDiscount`, `bestSellersTopN`, `language`, `classFrom`/`classTo`, `sortBy`, `startAt`/`endAt`, `nameUr`/`descriptionUr`.
- New routes: `POST :storeId/preview` and `PATCH :storeId/reorder {ids[1..20]}`.
- Not used by the app.

### exchange-rate
- `GET /exchange-rate/current` is unchanged; this is the only endpoint the app uses (`api_constaints.dart:749`).
- New: public `GET /exchange-rate/display?country=` → `{country, currency, ratePerUSD, asOf, stale}`, for display only.
- Admin `api/admin/fx/*` now runs under AdminReauthGuard, with `held` confirm and dismiss.
- **No app impact.**

---

### New routes in these modules (ADDED in routes_diff.txt) the app does not use yet
- GET /api/cart/buy-now: Buy Now priced line (shape like my-carts).
- GET /api/checkout/delivery-info: public delivery fee, ETA and COD for a product page.
- GET/POST /api/checkout/gift-options: gift message and wrap on a checkout.
- GET/POST/PATCH/DELETE /api/checkout/admin/shipping-zones (+ seed-defaults), GET/PUT /api/checkout/admin/shipping-rates (+ /couriers): admin only.
- GET /api/couriers, /couriers/options, POST /couriers/shipments, GET /couriers/shipments/label, POST /couriers/:courier/webhook: courier booking (off).
- GET /api/exchange-rate/display: display currency by country.
- GET /api/admin/fx/held, POST /api/admin/fx/held/:id/confirm, POST /api/admin/fx/held/:id/dismiss: admin.
- GET /api/inventory/stock-history/…, PATCH /api/inventory/low-stock-threshold/…: **already used**.
- GET /api/orders/my-library: buyer library (digital).
- GET /api/orders/download-zip/:orderId/:productId, GET /api/orders/download-zip-link/:orderId/:productId, GET /api/orders/download-zip-file: zip of all files.
- POST /api/orders/resend-download-link: re-email the download link.
- GET /api/orders/seller-orders/:storeId/:orderId: seller order detail.
- GET /api/orders/seller-orders/:storeId/print: print data, up to 50 orders.
- POST /api/orders/seller-cancel/:orderId: seller or admin cancels unshipped items (`{storeId, reason}`).
- GET /api/orders/seller-returns-all/:storeId/:source/:requestId: return or refund detail drawer.
- GET /api/orders/seller-free-claims/:storeId, GET /api/orders/seller-returns-all/:storeId, PATCH /api/orders/return-follow-up/:orderId: **already used**.
- POST /api/payment/pk/:provider/initiate, GET/POST /api/payment/pk/:provider/callback: JazzCash and Easypaisa (PKR).
- GET /api/products/also-bought/:id, /bestsellers, /free-resources, /premium-deals, /compare?ids=: buyer shelves.
- GET /api/products/sample/:id: 404 unless PUBLIC_FREE_SAMPLE.
- GET /api/products/store/:storeId/storefront-sections (+ /preview): store highlights.
- PATCH /api/products/bulk-price `{ids, mode:set|percent, value, dryRun}`.
- PATCH /api/products/visibility/:productId `{active}`.
- POST /api/products/duplicate/:productId, PATCH /api/products/bulk-status, PATCH /api/products/bulk-offers, PATCH /api/products/stock/bulk: **already used**.
- GET /api/rating/my-reviewed-ids: "waiting for your review".
- GET /api/rating/store/:storeId/reviews and GET /api/rating/store/:storeId/public: public store reviews.
- GET/PUT /api/rating/reply-templates/:storeId, GET /api/rating/review-requests/:storeId, POST /api/rating/review-request/:orderId, GET /api/rating/store-insights/:storeId, POST /api/rating/:reviewId/report: seller review tools.
- GET /api/refund-request/admin (replaces admin/pending), PATCH /api/refund-request/:id/follow-up.
- GET/PUT /api/seller/manual-payments/:storeId/settings, GET …/proofs, GET …/proofs/:proofId/proof-url, PATCH …/proofs/:proofId/approve, PATCH …/proofs/:proofId/reject: **all return 410 Gone**. Do not adopt.
- POST /api/collections/:storeId/preview, PATCH /api/collections/:storeId/reorder.
- Removed in my scope: GET /api/products/education/facets, GET /api/products/education/custom-level-suggestions (app still references both: `api_constaints.dart:166,169`, `product_repository.dart:54`), GET /api/refund-request/admin/pending (not used by the app).

---

### BREAKING for the app

| call | app file:line | what breaks | fix needed |
|---|---|---|---|
| POST /api/checkout/create-checkout (cart with a physical item) | `lib/app/modules/cart/controllers/cart_controller.dart:400` → `lib/app/data/repositories/checkout_repository.dart:30-38` | Body has no `shippingZoneId`. When any active shipping zone exists, the server returns 400 "Choose a delivery option for your address", so physical checkout is impossible. `addressId` is also not sent, so the buyer's chosen address is ignored. | Fetch zones and pick one (and the address) **before** create-checkout and send `shippingZoneId` + `addressId`. Or move zone and address selection ahead of creation. Read `summary.shippingFee`/`totalAmount` and `cod` from the response. |
| GET /api/payment/manual-transfer/bank-details | `lib/app/data/repositories/manual_transfer_repository.dart:21` (caller `lib/app/modules/manual_transfer/controllers/manual_transfer_controller.dart:44`) | `checkoutId` query is now required, so the call returns 400 and the bank transfer screen gets no bank details. | Pass `queryParameters: {'checkoutId': checkoutId}`. The response also has a new `payeeName`. |
| PATCH /api/refund-request/:id/approve and /reject (from the seller Returns list) | `lib/app/modules/seller_returns/models/seller_return_item.dart:106`, used at `lib/app/modules/seller_returns/controllers/seller_returns_controller.dart:111,123` | `seller-returns-all` rows carry `requestId`, not `refundRequestId`/`_id`/`id`. The app falls back to `orderId`, so approve and reject hit the wrong id → 404 "Refund request not found". | Read `j['requestId']` (for the refund source it is the RefundRequest `_id`). Also map `item`→productName (`:111`) and `evidenceImages`→photos (`:103`). |
| POST /api/products/add-physical-product and POST /api/products/:id/variants (empty weight) | `lib/app/data/models/common_models/variant_entry.dart:76`; `lib/app/modules/add_seller_product/widgets/variant_card.dart:137-147` | `shippingWeight: null` now returns 400 "Shipping weight is required", for drafts too. | Make Shipping Weight required (1 g–50 kg, "0.5 kg"/"500 g") in the variant form. |
| POST /api/products/add-physical-product and add-digital-product (no or short description, short title) | `lib/app/modules/add_seller_product/controllers/add_seller_product_controller.dart:297-309,621,700`; `lib/app/data/repositories/seller_product_repository.dart:541-542` | Description is required and must be at least 20 characters (drafts too). Title must be at least 10 characters. Both return 400. | Add client checks: description ≥ 20 characters and title ≥ 10 characters. Always send the description. |
| POST /api/cart/update-cart-quantity `action=increase` on a digital line | `lib/app/modules/cart/controllers/cart_controller.dart:167` | Returns 400 "Digital items are limited to one per order". | Hide or disable + for `type=='digital'` lines. The cart JSON now has `type`. |
| (non-breaking, dead filter) GET products-by-category `educationLevel` / `normalizedCustomLevel` | `lib/app/network/api_constaints.dart:142-147`; `lib/app/components/product_filter_bottom_sheet.dart` | Params are ignored, so the filter does nothing. The facets endpoint is gone (already known). | Switch to `class=<slug>` (`class-levels.ts` values) and `curriculum`. |
| (backend cosmetic) error messages from orders | `edudeen_api/src/orders/orders.service.ts` (49× "â€”") | Toasts show "â€”" mojibake. | Backend: re-save the file as UTF-8 (not an app change). |

---

## Appendix C — seller / platform modules

## Seller-side backend diff a5cba9f..5adba44: store, finance, plans, analytics, marketing, classroom, common

Read-only review. API = `edudeen_api` (paths relative to it), APP = `edudeen-app` (paths relative to it, branch full-app @ f1d48c1e).

Overall: the app was clearly written against the *new* live API for most seller screens (finance earnings, dashboard-summary, plan lapse, analytics 403, store settings, course builder, maintenance). Its comments cite live checks from 2026-11-17/18. The real breakages are in areas the app never updated: **buyer/seller store memberships (removed)**, **store banner link types**, **analytics overview comparison fields**, **"Create New Store" (one store per seller)**, plus one existing finance bug (payout-method PATCH).

---

### subscriptions (REMOVED) / stripe-billing

- Removed on purpose by `eee3d8a` (2026-11-03) "Remove buyer store-membership subscriptions". From the commit message: *"Delete src/subscriptions (controller, service, benefits, emails, schemas, DTOs), its crons, the SUBSCRIPTION_EMAILS queue and member benefits in checkout/orders/products/store/messaging. Shared Stripe billing code for seller platform plans moved to src/stripe-billing (webhook URL unchanged)."*
- **Nothing replaces it as a feature.** `src/stripe-billing` is only the shared Stripe plumbing (payment-gateway, webhook processor, invoice counter, refund DTO) that seller **platform plans** use. It is not a membership product. The webhook stays at `POST /api/subscriptions/webhooks/stripe` (`src/stripe-billing/webhooks/stripe-webhook.controller.ts:9,21`).
- Related: `platform-plan.schema.ts` marks `subscriptionProductsAllowed` as legacy/unused. `analytics.service` revenue-breakdown keeps `recurringSubscriptionRevenue: 0` and drops `note`. The closest buyer-side replacement is the separate **Premium** program (`src/premium`, outside this scope). It is platform-run, not per store.
- All 47 `/api/subscriptions/*` routes except the webhook now return 404.

APP IMPACT (the app still ships both flows):
- Storefront (every buyer, every store): `lib/app/modules/storefront/views/seller_storefront_view.dart:60-62` renders `StorefrontPlansTeaser`, which calls `getStorePlans` (`lib/app/modules/storefront/widgets/storefront_plans_teaser.dart:40`). That goes to `GET /api/subscriptions/public/:storeId/plans` (`lib/app/data/repositories/buyer_memberships_repository.dart:21`) and gets a 404. `DioExceptionHandler.handleDioException(e)` then toasts "Cannot GET /api/subscriptions/public/…" (line 29-30, `showToast` defaults to true). **A visible error toast on every storefront open.** The `getStoreBenefits` call is silent (line 211).
- Seller Settings, "Subscription Plans" tile: `lib/app/modules/seller_settings/controllers/seller_settings_controller.dart:105-108` opens `seller_subscriptions`. Every call in `lib/app/data/repositories/subscription_plans_repository.dart` (19, 45, 84, 114, 136, 162, 190, 205-208) returns 404 with a toast.
- My Memberships: `lib/app/modules/notifications/controllers/notifications_controller.dart:132` and the whole `lib/app/modules/my_memberships/*` use `buyer_memberships_repository.dart`. All return 404.
- Fix: remove the teaser, the settings tile, the `seller_subscriptions` and `my_memberships` modules, both repositories and the `ApiConstants` entries (`lib/app/network/api_constaints.dart:453-473, 659-678`).

### store

c) DTO / validation changes on `POST /api/store/update-store` (`src/store/store.service.ts:644-873`, body is still untyped `any`):
- name/tagline/description now go through `cleanStoreProfileText` (`src/store/store-page.util.ts:12-15,43-60`). New limits are **name 60, tagline 100, description 1000**, enforced only when the value changes (old hard caps 120/200/5000 still apply). Name is required (400 "Store name is required" when blank).
- contactPhone must normalise to a Pakistani number (`STORE_PHONE_ERROR`). contactEmail must match a stricter regex. Both checks apply only when the value changes.
- New fields:
  - `premiumDiscount`: {enabled, percent 1-50} or null.
  - `educatorProfile`: object, list caps 10/15, experienceYears 0-70.
  - `shippingNote`, `faqs`.
  - `returnPolicy`: {returnsAccepted bool **required**, windowDays int 0-90, ≥1 when accepted, note ≤300, digitalNote ≤300}. digitalNote is kept when not sent.
  - `aboutBio` ≤1500.
  - `deliverySettings`: {enabled bool required, fee 0-10M, freeOverAmount null or 0-10M}.
  - `deliveryMethod`: self or empty. Couriers return 400 "coming soon" while courier delivery is off.
  - `shipFrom`: {city, province}, sliced to 60. A missing or empty city clears it to null.
  - `deliveryDays`: keys sameCity/sameProvince/national, each {min,max} whole 0-30 with min≤max. Unknown key gives 400 (`src/store/delivery-days.util.ts:23-45`).
  - `dispatchDays`: number 1-7 only. Strings are rejected (`store.service.ts:827-833`).
  - `giftWrap`: {enabled bool required, fee}.
- `codEnabled` is still `!!codEnabled` (line 720).
- `productTypes` validation is unchanged (lines 690-698, 844-847).
- `POST /api/store/create-store`: **one store per seller**. A second store gets 409 "You already have a store — each seller account can run one store" (commit `b8a83e1`). Business verification was removed (`90ecd24`), so new stores are live immediately (`selfServeActivation = true`).
- New `PATCH /api/store/:storeId/holiday`, `PUT …/customers/:customerId/note` (DTO `store-customer-note.dto.ts`).
- `ParseObjectIdPipe` on many `:storeId` params: a bad id now returns 400 "Invalid id" instead of 500.

d) Response shape:
- Removed: `GET/PATCH /api/store/:storeId/verification*`, `GET /api/store/verification/requirements-preview`, `PATCH /api/store/:storeId/customers/:customerId` (customers are now read-only and masked via `StoreCustomersService`; followers moved there too).
- `GET /api/store/public/:storeId/products`: limit max 50→100. New `kind`, `q`, subject/class filters and collection order. Test products are excluded. Additive.
- `GET /api/store/public/top`: items gain `topProducts, soldCount, categoryName, featuredRank`. There is now a quality gate, so fewer stores may appear.
- `platform-stats` gains `productsCount`.
- getStoreById / my-stores / public/:slug / follow / filters: no diff.

e) Rules: holiday mode, one store per seller, no verification. `isCodOffered` = any active store with `codEnabled != false`.

APP IMPACT:
- `lib/app/data/repositories/seller_store_settings_repository.dart:85-104` (`toBody`) matches the new rules (dispatchDays int, deliveryDays with null clearing, returnPolicy fields). OK.
- Minor: when the seller sets a province without a city, `toBody` sends `{city:null, province:'X'}` and the server stores `shipFrom = null`, so the province is silently dropped (`store.service.ts:813-816`).
- `lib/app/data/repositories/seller_repository.dart:84-91` (store profile) sends `name`/`description` with no client length cap. A changed name over 60 or description over 1000 now gets a 400 (the message is toasted). Not a crash.
- **Create New Store**: `lib/app/modules/seller_stores/views/seller_stores_view.dart:31-33` → `seller_stores_controller.dart:172` → onboarding → `seller_repository.dart:197` `create-store`. This gives **409 for any seller who already has a store**, after the seller has filled the whole wizard. Hide the button when the seller has one store.

### store-dashboard (new module)

- `GET /api/store/:storeId/dashboard-summary` returns `{success, data:{actionItems, overview, revenueSeries, today, totalProducts, activeProducts, shelf, checklist, profile, premium:{…, windowDays:30}}}` (`src/store-dashboard/store-dashboard.service.ts:104-116`). The app model `lib/app/data/models/seller_dashboard_summary.dart:1-14` was written from the live shape and matches.
- `GET /api/store/:storeId/health` (new). The app does not use it.

### finance

c) DTO: `add-payout-method.dto.ts`, `request-payout.dto.ts` and `update-payout-schedule.dto.ts` are **unchanged**. New service-side payout-method checks (`src/finance/finance.service.ts:755-779`):
- bank_transfer needs bankName and accountHolder.
- PKR bank needs a valid IBAN `^PK\d{2}[A-Z]{4}\d{16}$`. The number is normalised and stored AES-encrypted (`accountNumberEnc`, never returned).
- jazzcash/easypaisa need an account number.
- paypal needs an email in `externalAccountId`.
- stripe needs `acct_…`.

The payout-schedule default frequency is now from admin config (`monthly`), not `weekly` (`payout-schedule.schema.ts`, `finance.service.ts:209-224`).

d) Response:
- `GET /finance/:storeId/dashboard`: `feeBreakdown` is kept. Added `cardProcessing{percent,fixedUSD}`, `platformFeeRate`, `platformFeeBreakdown`. `nextPayoutAt`/`scheduledAt` now come from `resolveNextPayoutAt`. Additive.
- New un-wrapped (no `{success,data}`) endpoints:
  - `earnings-summary`: currency, available, clearing, clearingReleaseAt, expected{…}, commissionOwed, nextPayoutDate, payoutFrequency, defaultMethod, platformFees, fallbackFeeRate, cardProcessing, clearingDays… (lines 1315-1356).
  - `earnings-statement`: {month,currency,totals,truncated,total,page,limit,pages,rows,payout}.
  - `earnings-statement/download`: csv or pdf, 10/min.
  - `fee-estimate`: {currency,type,price,fee,net,reason: null|'not_set'|'rate_unavailable'}, 60/min.
  - `monthly-statement`.
- The payout-method response goes through `withoutSecrets`.
- transactions / payouts / payout-methods list / schedule: no shape diff.

e) Platform fees: the sale fee is now the admin `PlatformConfig.platformFees` per type (percentage or fixed USD per unit). Premium lines pay their own percent. The fallback is the legacy commission rule (`finance.service.ts:2259-2310`). Commit `b8a83e1` turned the per-sale commission off by default.
- Note: `fee-estimate` returns `reason:'not_set'` whenever admin platformFees are unset, while `recordSale` would still apply a legacy commission rule if one exists (`finance.service.ts:1376` vs `2262`). Unverified whether any non-zero rule exists in prod.

APP IMPACT: `lib/app/data/repositories/seller_finance_repository.dart` reads the new un-wrapped shapes (lines 26-68) correctly.
- **Existing bug, not a regression:** `updatePayoutMethod` (`seller_finance_repository.dart:245-253`) never sends `type`. `PATCH …/payout-methods/:id` validates the body with `AddPayoutMethodDto`, whose `type` is required (`src/finance/dto/add-payout-method.dto.ts:6-8`; controller `finance.controller.ts:168-176`). **Every edit fails with 400 "type must be one of the following values: "** (called from `lib/app/modules/seller_finance/widgets/finance_payout_methods_sheet.dart:379`). Fix: send `type` in the app, or make the backend PATCH use a partial DTO.

### platform-plans

c)
- Subscription status enum adds **`expired`** (`seller-platform-subscription.schema.ts`): trialing | active | past_due | canceled | expired.
- New `complimentary` field. New `GrantPlatformPlanDto` {planId, days 1-31, reason≤300}.
- `SaveOnboardingDraftDto.step/maxReached` are now int 1-10 and `form` must be an object.

d)
- `GET /api/platform-plans/:storeId` with no record returns **200 `{success:true,data:null}`** instead of 404.
- Entitlements: `maxProducts` is always `{limit:-1, allowed:true}`. New `maxActivePromotions{limit,used,allowed}`.
- `change-plan`: `requiresAction:false` and `clientSecret:null` when the saved card was charged straight away (`chargeSavedCard:true`).
- New `GET /api/platform-plans/free-trial-eligibility`, `GET /public/addons`, admin grant.

e) Plan lapse:
- Every lapse (cancellation reached its end, failed payments, admin grant ended, trial ended) now lands as **`expired`** (it used to drop silently to free and `active`).
- `expired | past_due | canceled` hides the store's active/scheduled listings, sets `pausedFromStatus`, and restores them when a plan becomes usable again (`plan-listing-sync.util.ts:16-40`, schema post-save hooks).
- `assertCanCreateProduct` gives **403 "Your free trial has ended. Choose a plan in Plan & Billing to add or publish products."** for those statuses (`entitlements.service.ts`).
- The free trial is one per seller (`seller.freeTrialUsedAt`). Picking the free trial plan again gives 400.
- A downgrade to a plan without loyalty disables the loyalty program.
- There is no product cap any more.

APP IMPACT:
- `lib/app/modules/seller/utils/plan_lapse.dart:13` already treats expired/past_due/canceled as lapsed. With `data:null`, `platform_plans_repository.dart:49` throws on the cast, which is caught and returns null. No crash.
- Minor: `MyPlanCard` labels any unknown status as "Canceled", so `expired` shows "Canceled" (`lib/app/modules/seller_platform_plans/widgets/platform_plan_widgets.dart:37-42`). Add `'expired' => 'Expired'`.

### analytics (seller)

c) New `ProductTableQueryDto` (storeId required MongoId, q≤100, sort enum, page, limit≤50, days enum).

d) `GET /api/seller/analytics/overview` (`analytics.service.ts` ~217-290):
- **Removed `totalRevenueChangePercent`.**
- Added `bookedValue, collected, freeClaims, timezone`. Under compare: `bookedValueChangePercent, collectedChangePercent, freeClaimsChange`.
- **`totalOrdersChange`, `avgOrderValueChangePercent` and `repeatBuyerTrend` are now only sent when `compareToPreviousPeriod=true`** (before, they were always sent).
- `totalRevenue` = booked value net of refunds. Free claims are excluded. Ranges use Pakistan time.
- `today` adds `freeClaims` (paid orders only).
- revenue-breakdown drops `note`. `recurringSubscriptionRevenue` is always 0.
- New: `products`, `products/export`, `free-to-paid`.

e) Plan gating, 403 via `assertAdvancedAnalytics` → `entitlements.assertFeatureAllowed` (`entitlements.service.ts:150-158`). Message: **"Advanced analytics is not included in your current platform plan — available starting with the "<Plan>" plan."**
- Gated: traffic-sources, customers, products/performance, inventory-insights, payment-methods, revenue-breakdown, export, products, products/export, free-to-paid.
- Not gated: today, overview, revenue-over-time, orders-over-time, top-products.

APP IMPACT:
- The 403 is handled (`lib/app/data/repositories/seller_analytics_repository.dart:19-50`, `PlanLockedCard`).
- **Overview KPI comparisons are now always empty**:
  - `lib/app/data/models/analytics/analytics_overview_model.dart:57` reads `totalRevenueChangePercent`, which no longer exists.
  - `seller_analytics_repository.dart:102` never passes `compare:true` (`_rangeParams` line 54-61).
  - So `lib/app/modules/seller_analytics/widgets/analytics_kpi_grid.dart:29-30` always shows "No prior data", line 35 always "+0 vs last period", line 41 always "No prior data".
  - Fix: send `compareToPreviousPeriod=true` and read `bookedValueChangePercent`.

### analytics-visits (new)

- `POST /api/analytics/view` (public beacon, 204, 60/min, body {type,id,source,term,row}).
- `GET /api/seller/analytics/visits`, `GET /api/seller/analytics/page-insights`, admin visits.
- The app never sends the beacon, so views/conversion in the new product table and page insights will not count app traffic (columns are null until tracking starts). Not a failure.

### marketing (coupons / campaigns)

c) Coupon create/update DTOs add optional:
- `appliesTo` (store|categories|products)
- `targetIds` (≤100 MongoIds)
- `startsAt`
- `perCustomerLimit` (1-1000, null clears on update)
- `firstOrderOnly`
- `visibility` (public|private, default private)

New service rules (`assertCouponRules`):
- code `^[A-Z0-9_-]{3,20}$` after upper-casing. This also applies on *any* update, so editing a legacy coupon with an odd code now gives 400.
- percentage ≤ 90.
- fixed ≤ minOrderAmount.
- expiry not in the past.
- targets must be own products or valid categories.

Campaign schema adds `backgroundImage, subsidyCapUSD, endNotifiedAt, liveNotifiedAt`.

d) Coupon create/list/update responses add computed `status`. `GET /api/public/marketing/campaigns` adds `?includeUpcoming=1` and, for logged-in Premium users, early-access rows (`earlyAccess:true`). New `GET /api/seller/marketing/kpis`, `GET /api/seller/promotions/stats?range=7d|30d|90d`.

e) Campaign participation is **strictly per product** (`product.campaignIds`). Joining a campaign without ticking products gives no discount (`campaign-eligibility.util.ts:5-13`). A platform campaign stops pricing once `subsidyCapUSD` is used up. A platform sale suspends the seller's own sale per item.
- APP: `seller_platform_sales_controller.dart:10,67` and `seller_products_controller.dart:66,218` already use `campaignIds`. OK.
- Maintenance `feature:flash_sale` blocks `/api/public/marketing/*` and `/api/marketing/:storeId/campaigns*`.

### promotions

- `create-promotion-request` placement is now `SELLER_PROMOTION_PLACEMENTS`: homepageHero, marketplaceHero, educationHero, categoryHero. `productPage` is admin-only.
- Cancel now refunds through Stripe. If the refund fails, you get 400 and the request is not cancelled.
- Pay/confirm on a no-longer-open request auto-refunds and gives 400.
- Schema adds `refundedUSD`.
- Admin list is paginated.
- The seller-facing shapes are otherwise unchanged. `maxActivePromotions` is surfaced in entitlements.

### store-banner

- **Link rule changed** (`src/store-banner/store-banner-rules.util.ts:10-27`, service lines 123-130, 156, 243-246). A slide may only link to the seller's own **live product or collection by 24-hex id**.
  - `external` https URLs and `category` links now give 400: "A banner link must be the id of one of your own products or collections" / "A banner can only link to one of your live products or collections". A slug also gives 400.
  - The old service accepted external https and product/category/collection ids.
- Max **4** active+scheduled slides. Create/resume/update past that gives 400 (SLOT_FULL).
- List items add `linkPath`.
- New `PATCH /api/store-banner/:storeId/reorder` {ids: exactly all the store's banner ids}.

APP IMPACT (BREAKING):
- `lib/app/modules/seller_store_banners/widgets/store_banner_form_sheet.dart:19` offers `['external','product','category','collection']`, defaults to `'external'` (lines 50, 68), and hints "https://..." or "ID or slug" (line 234).
- `lib/app/data/repositories/store_banner_repository.dart:45,55` sends `linkType: 'external'` by default.
- Any slide with an external URL, a category, or a product/collection slug is rejected.
- Fix: offer only product/collection pickers that send ids, and handle the 4-slide cap.

### store-theme

- New `PATCH /api/store-theme/:storeId/storefront` (`featuredProductIds` ≤8, `showNewArrivals`, `showBestSellers`) and `PATCH …/store-page` (Customize-store draft). The app uses neither. No existing route changed.

### loyalty / gift-cards / discounts / seller

- loyalty: the overview `programMembers` counts distinct users and is 0 when the program is disabled. The program is auto-disabled on a plan without `loyaltyProgramAllowed`.
- gift-cards: new stores get a 12-month expiry and PKR denominations [500,1000,2000,5000]. The code search is regex-escaped.
- discounts: bundles compete as percentage discounts.
- seller schema: `freeTrialUsedAt`, `phoneVerified/phoneE164/phoneVerifiedAt`.
- No HTTP contract break for the app.

### classroom (new module: courses, roster, bundles, Q&A, curated collections, learning paths)

c) Course PUT `PUT /api/courses/seller/:storeId/:productId` → `cleanCourseInput` (`src/classroom/course.util.ts:174-230`):
- sections/lessons have limits (`COURSE_LIMITS`).
- section title is cut to 120, lesson title to 150 (`str()` at line 6).
- lesson types: video / PDF / text / quiz.
- outcomes ≤10 × 200.
- instructor name ≤100, bio ≤1000.
- accessDays 1-3650 or null.
- certificateConfig is optional.
- Only digital products can be courses.

Roster `GET /api/courses/seller/:storeId/roster` (+ `/export`, `/student/:userId`) uses `ParseObjectIdPipe`.

APP IMPACT:
- `lib/app/data/repositories/seller_course_repository.dart:44,93` already caps titles at 150/120.
- `lib/app/data/repositories/seller_students_repository.dart:177` uses the roster.
- The buyer player routes (`/courses/learn/*`, `outline`, `preview`, `certificates`, lesson complete/quiz) are not in the app.

### admin-config (platform config, maintenance, fees, COD)

- **Maintenance:** a global middleware in `src/main.ts` returns **503** `{statusCode:503, maintenanceMode:true, scope, scopes, type, title, message, endsAt, statusNote}` (`admin-config.service.ts:100-109`).
  - Scopes are `all | buyer | seller | checkout | uploads | feature:<flash_sale|search|categories|product_page|cart|reviews|messaging|stores|learn|orders>`.
  - Exempt: `/api/admin`, `/api/auth`, `/api/platform-config`, webhooks, health (`maintenance.util.ts:94-108`). Admin tokens pass.
  - The public `GET /api/platform-config/maintenance` returns `{success, data:{state:'off'|'scheduled'|'active', …}}`.
- `GET /api/platform-config/public` returns `{success, data:{socialLinks, homeContent, commerce:{codAvailable, paymentMethods, cod:{maxPerPackagePKR, feePerPackagePKR}}, sellerPage, chatbot, payout:{frequency}}}`.
- Admin DTOs:
  - `UpdatePlatformFeesDto` {digital|physical: {mode percentage|fixed, value 0-…}}.
  - `UpdateCodConfigDto` {maxPerPackagePKR ≥1 or null, feePerPackagePKR 0-100000}.
  - `UpdateMaintenanceDto` (scopes/type/title≤120/message≤1000/startsAt/endsAt/statusNote≤300/scopeMessages).
  - `payoutFrequency`.
- APP: `lib/app/network/maintenance_interceptor.dart:11-14` and `lib/app/services/maintenance_service.dart:60-98` handle both shapes. `state:'scheduled'` is correctly treated as not blocking. `platform_config_service.dart:43-56` unwraps `data`. OK.

### common (global behaviour)

- No global exception filter or response wrapper was added. The `ValidationPipe {transform, whitelist}` options are unchanged. `NoOperatorKeysInterceptor` is unchanged.
- New `ParseObjectIdPipe` (`src/common/parse-object-id.pipe.ts`) returns 400 "Invalid id" where applied. Routes without it still turn a Mongoose CastError into a 500.
- `main.ts`:
  - Throttle default goes from 100 to **300 req/min/IP**.
  - Realtime publish after successful writes.
  - Security headers.
  - CORS: admin paths are restricted to whitelisted origins, and `Idempotency-Key`, `X-Request-Id` and `X-Admin-Reauth` are allowed.
  - Staff-access middleware.
  - Maintenance middleware (above).
  - Swagger is off in prod unless `ENABLE_SWAGGER=true`.
- Pagination helpers: unchanged. Per-endpoint shapes differ, as noted above.

---

### Known backend issues 2-8 (checked against HEAD)

| # | Status | Evidence |
|---|---|---|
| 2 | **STILL OPEN** | `src/finance/finance.controller.ts:188-191` defaults `currency || 'USD'`. `finance.service.ts:993-996` `getPayoutSchedule` → `getOrCreateSchedule` (`finance.service.ts:209-224`): `findOne({storeId,currency})`, then `scheduleModel.create(...)` when missing. Only change: the new doc's frequency now comes from admin config (default `monthly`) instead of `weekly`. |
| 3 | **STILL OPEN** | `src/finance/dto/add-payout-method.dto.ts:7` `@IsEnum(['bank_transfer',…])` (array). class-validator `validEnumValues` drops numeric keys (`node_modules/class-validator/cjs/decorator/typechecker/IsEnum.js:17-21`), so the message list is empty. The same pattern is in `add-payout-method.dto.ts:11`, `update-payout-schedule.dto.ts:8,13`, `marketing/dto/create-coupon.dto.ts:12,39,68`, `update-coupon.dto.ts:13,46,78`, `platform-plans/dto/subscribe-platform-plan.dto.ts:11,21`, `update-platform-plan.dto.ts:8`, `loyalty/dto/*`, `discounts/dto/*`. Fix: `@IsIn([...])`. |
| 5 | **STILL OPEN** | `finance.controller.ts:52-64` reads only `price`, `type`, `currency`. `finance.service.ts:1363-1384` `estimatePlatformFee` passes `[{type,totalPrice,quantity:1}]` with no `feePercent`, so the Premium branch (`finance.service.ts:2302-2310`) is never hit. `premiumPercent`/`productId` are ignored. |
| 6 | **STILL OPEN** | `src/store/store.service.ts:690-698` only loops over the entries (an empty array passes). Lines 844-847 store `productTypes: []` and `enabledTools: []`. A non-array value (e.g. a string) also skips validation and reaches the update (no `runValidators`). Unverified whether Mongoose then casts or stores it. |
| 7 | **STILL OPEN** | `store.service.ts:720` `updateData.codEnabled = !!codEnabled` ("x" becomes true). `shipFrom` (lines 813-821) copies only `city`/`province`, so extra keys are silently dropped (not rejected). `String(sf.province)` turns a number into a string ("5"). No province allow-list. A non-string city is also coerced. |
| 8a (500 on bad id) | **PARTLY FIXED** | Roster routes use `ParseObjectIdPipe` and now return 400 "Invalid id" (`src/classroom/classroom.controllers.ts:255-275`). Builder/students/PUT have no pipe on `:storeId` (`classroom.controllers.ts:281-298`). `courses.service.ts:84-85` → `verifyStoreOwnershipStrict` → `storeModel.findById(badId)` (`src/common/store-ownership.util.ts:27`) gives a CastError, and with no global filter that is a **500**. The paths in the original report (`/api/courses/seller/product/<id>`, `/seller/roster/<storeId>`) match `seller/:storeId/:productId` with storeId='product'/'roster', so they **still 500**. A bad productId returns 404 (`courses.service.ts:86`). |
| 8b (silent cut) | **STILL OPEN** | `src/classroom/course.util.ts:6` `str = v.trim().slice(0,max)`. Line 187 cuts the section title to 120, line 191 the lesson title to 150, with no 400. The app works around it with client caps (`seller_course_repository.dart:44,93`). |

---

### New backend routes in these modules the app does not use yet (non-admin)

- GET /api/store/:storeId/health (store health metrics)
- GET /api/store/:storeId/customers/:customerId (masked customer detail)
- PUT /api/store/:storeId/customers/:customerId/note (private seller note)
- PATCH /api/store/:storeId/holiday (holiday mode)
- GET /api/store/public/:storeId/catalog-facets (in-store filter facets)
- PATCH /api/store-theme/:storeId/storefront (featured products / rails toggles)
- PATCH /api/store-theme/:storeId/store-page (Customize-store draft)
- PATCH /api/store-banner/:storeId/reorder (slide order)
- GET /api/finance/:storeId/monthly-statement (settlement statement)
- GET /api/platform-plans/public/addons (public add-on catalog)
- GET /api/seller/analytics/products (product table)
- GET /api/seller/analytics/products/export (CSV)
- GET /api/seller/analytics/free-to-paid
- GET /api/seller/analytics/visits
- GET /api/seller/analytics/page-insights
- POST /api/analytics/view (page-view beacon)
- GET /api/seller/marketing/kpis
- GET /api/seller/promotions/stats
- GET /api/courses/outline/:idOrSlug
- GET /api/courses/preview/:idOrSlug/:lessonId
- GET /api/courses/learn/:idOrSlug
- GET /api/courses/learn/:idOrSlug/lessons/:lessonId
- POST /api/courses/learn/:idOrSlug/lessons/:lessonId/complete
- POST /api/courses/learn/:idOrSlug/lessons/:lessonId/quiz
- POST /api/courses/learn/:idOrSlug/certificate-details
- GET /api/courses/certificates/:code (public certificate check)
- GET /api/courses/seller/:storeId/roster/student/:userId (student detail)
- GET /api/bundles/public, /public/:slug, /store/:storeId, /for-product/:productId
- GET/POST /api/bundles/seller/:storeId, PATCH/DELETE /api/bundles/seller/:storeId/:id, POST …/:id/duplicate, …/quote, …/suggestions
- GET/POST /api/product-questions/product/:idOrSlug, GET /api/product-questions/seller/:storeId, PATCH …/:id/answer, PATCH …/:id/visibility, DELETE /api/product-questions/:id
- GET /api/curated-collections/home, GET /api/curated-collections/:slug
- GET /api/learning-paths, GET /api/learning-paths/:slug
- Admin-only: POST /api/platform-plans/admin/grant/:storeId, /api/admin/curated-collections*, /api/admin/learning-paths*, /api/admin/analytics/visits (not for the app)

---

### BREAKING for the app

| call | app file:line | what breaks | fix needed |
|---|---|---|---|
| GET /api/subscriptions/public/:storeId/plans (+ /my/benefits/:storeId) | `lib/app/data/repositories/buyer_memberships_repository.dart:21,29-30`; triggered by `lib/app/modules/storefront/widgets/storefront_plans_teaser.dart:40` from `lib/app/modules/storefront/views/seller_storefront_view.dart:60-62` | 404 on every storefront open, toasted "Cannot GET …" | Remove `StorefrontPlansTeaser` and the buyer membership code |
| All /api/subscriptions/:storeId/* (seller plans, dashboard, subscribers) | `lib/app/data/repositories/subscription_plans_repository.dart:19,45,84,114,136,162,190,205-208`; entry `lib/app/modules/seller_settings/controllers/seller_settings_controller.dart:105-108` | Feature removed, every call 404 | Remove the "Subscription Plans" tile and the `seller_subscriptions` module |
| All /api/subscriptions/my* + /subscribe | `lib/app/data/repositories/buyer_memberships_repository.dart` (all methods); entry `lib/app/modules/notifications/controllers/notifications_controller.dart:132` | Feature removed, 404 | Remove the `my_memberships` module, route and notification deep link |
| POST/PATCH /api/store-banner/:storeId[/:bannerId] with linkType external/category or a slug | `lib/app/modules/seller_store_banners/widgets/store_banner_form_sheet.dart:19,50,68,234`; `lib/app/data/repositories/store_banner_repository.dart:45,55,109` | 400 "A banner link must be the id of one of your own products or collections"; also 400 above 4 active+scheduled slides | Only allow product/collection, send 24-hex ids (picker), handle the 4-slide cap |
| GET /api/seller/analytics/overview | `lib/app/data/models/analytics/analytics_overview_model.dart:57`; `lib/app/data/repositories/seller_analytics_repository.dart:102` (no compare); `lib/app/modules/seller_analytics/widgets/analytics_kpi_grid.dart:29-30,35,41` | `totalRevenueChangePercent` removed; order/AOV changes only sent with `compareToPreviousPeriod=true`, so the KPI cards always show "No prior data" / "+0" | Pass `compare: true`; read `bookedValueChangePercent` (optionally show `bookedValue`/`collected`/`freeClaims`) |
| POST /api/store/create-store (second store) | `lib/app/modules/seller_stores/views/seller_stores_view.dart:31-33` → `seller_stores_controller.dart:172` → `lib/app/data/repositories/seller_repository.dart:197` | 409 "You already have a store…" after the whole onboarding | Hide "Create New Store" when the seller already has a store |
| PATCH /api/finance/:storeId/payout-methods/:id (existing bug, not a regression) | `lib/app/data/repositories/seller_finance_repository.dart:245-253`; caller `lib/app/modules/seller_finance/widgets/finance_payout_methods_sheet.dart:379` | Body has no `type` and the DTO requires it, so 400 "type must be one of the following values: " | Send `type` (the method's current type) in the app, or have the backend use a partial DTO |
| GET /api/platform-plans/:storeId status `expired` (minor display issue) | `lib/app/modules/seller_platform_plans/widgets/platform_plan_widgets.dart:37-42` | `expired` shows as "Canceled" | Add an `'expired' => 'Expired'` label |
| POST /api/store/update-store shipFrom with province and no city (minor data loss) | `lib/app/data/repositories/seller_store_settings_repository.dart:95-97` | Server stores `shipFrom:null`, so the province is lost silently | Require a city in the UI, or send nothing |

---

## Appendix D — route diff (OLD a5cba9f → HEAD 5adba44)

Extracted from every `@Controller` / `@Get|Post|Put|Patch|Delete` decorator (comment lines ignored). Controllers with an array prefix (e.g. `banner`: `['api/banners','api/spotlight']`) are not expanded; banner routes did not change. Guards = class-level + method-level `@UseGuards`/`@Roles`.

```
## ADDED
DELETE /api/admin/curated-collections/:id  [src/classroom/classroom.controllers.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
DELETE /api/admin/learning-paths/:id  [src/classroom/learning-paths.controller.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
DELETE /api/admin/marketplace/leads/:id  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
DELETE /api/admin/premium/plans/:id  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
DELETE /api/admin/staff/:id  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
DELETE /api/admin/staff/notes/:id  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
DELETE /api/admin/staff/roles/:id  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
DELETE /api/admin/staff/tasks/:id  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
DELETE /api/bundles/seller/:storeId/:id  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
DELETE /api/checkout/admin/shipping-zones/:id  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
DELETE /api/children/:id  [src/children/children.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
DELETE /api/home-cards/:id  [src/home-cards/home-cards.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
DELETE /api/messaging/seller/quick-replies/:id  [src/messaging/messaging.controller.ts]  UseGuards(JwtAuthGuard) | UseGuards(RolesGuard) Roles('seller')
DELETE /api/notifications/clear-read  [src/notifications/notifications.controller.ts]  UseGuards(JwtAuthGuard)
DELETE /api/product-questions/:id  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard)
DELETE /api/wishlist-share  [src/retention/retention.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /admin/all  [src/banner/banner.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/ai/config  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/ai/embeddings/status  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/ai/moderation/:productId  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/ai/usage  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/analytics/visits  [src/analytics-visits/visits.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/chat/conversations  [src/chatbot/chat-admin.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/chat/conversations/:id  [src/chatbot/chat-admin.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/chat/stats  [src/chatbot/chat-admin.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/curated-collections  [src/classroom/classroom.controllers.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/curated-collections/:id  [src/classroom/classroom.controllers.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/curated-collections/product-search  [src/classroom/classroom.controllers.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/exports/listings  [src/admin-exports/admin-exports.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/exports/orders  [src/admin-exports/admin-exports.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/exports/payment-proofs  [src/admin-exports/admin-exports.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/exports/users  [src/admin-exports/admin-exports.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/credit-jobs  [src/admin-finance/admin-finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/monthly-settlement  [src/admin-finance/admin-finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/payouts/:payoutId/destination  [src/admin-finance/admin-finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/fx/held  [src/exchange-rate/exchange-rate.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/learning-paths  [src/classroom/learning-paths.controller.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/learning-paths/:id  [src/classroom/learning-paths.controller.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/marketplace/listings/:id/review  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/marketplace/listings/review/count  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/marketplace/stores/featured  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/orders  [src/admin-orders/admin-orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/orders/:id  [src/admin-orders/admin-orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/orders/manual/products  [src/admin-orders/admin-orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/pending-counts  [src/admin-pending/admin-pending.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/platform-config/chatbot  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/platform-config/cod  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/platform-config/platform-fees  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/premium/members  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/premium/payments  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/premium/payments/:id/proof-url  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/premium/plans  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/premium/settings  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/premium/stats  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/retention/referral  [src/retention/retention.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/approvals  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/approvals/count  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/audit  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/me  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/notes  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/permissions  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/roles  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/settings  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/tasks  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/staff/tasks/unread  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/store-lookup  [src/admin-pending/store-lookup.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/ai/features  [src/ai-studio/ai-features.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/ai/reviews/summary/:productId  [src/ai-studio/ai-features.controller.ts]  
GET /api/ai/search  [src/ai-studio/ai-features.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/ai/seller/:storeId/insights/latest  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/ai/seller/:storeId/insights/settings  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/ai/seller/:storeId/orders/:orderId/cod-risk  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/ai/seller/:storeId/worksheets/:generationId/html  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/auth/phone/availability  [src/phone-verification/phone-verification.controller.ts]  
GET /api/auth/phone/status  [src/phone-verification/phone-verification.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/bundles/for-product/:productId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(OptionalJwtAuthGuard)
GET /api/bundles/public  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(OptionalJwtAuthGuard)
GET /api/bundles/public/:slug  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(OptionalJwtAuthGuard)
GET /api/bundles/seller/:storeId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/bundles/store/:storeId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(OptionalJwtAuthGuard)
GET /api/cart/buy-now  [src/cart/cart.controller.ts]  UseGuards(JwtAuthGuard)
GET /api/categories/admin/requests  [src/categories/category-requests.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller') | UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/categories/admin/tree  [src/categories/categories.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/categories/requests  [src/categories/category-requests.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/categories/store-usage/:storeId  [src/categories/category-requests.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/chatbot/conversation  [src/chatbot/chatbot.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/checkout/admin/shipping-rates  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/checkout/admin/shipping-rates/couriers  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/checkout/admin/shipping-zones  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/checkout/delivery-info  [src/checkout/checkout.controller.ts]  
GET /api/checkout/gift-options  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /api/children  [src/children/children.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') | UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /api/couriers  [src/couriers/couriers.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/couriers/options  [src/couriers/couriers.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/couriers/shipments/label  [src/couriers/couriers.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/courses/certificates/:code  [src/classroom/classroom.controllers.ts]  
GET /api/courses/learn/:idOrSlug  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard)
GET /api/courses/learn/:idOrSlug/lessons/:lessonId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard)
GET /api/courses/mine  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard)
GET /api/courses/outline/:idOrSlug  [src/classroom/classroom.controllers.ts]  
GET /api/courses/preview/:idOrSlug/:lessonId  [src/classroom/classroom.controllers.ts]  
GET /api/courses/seller/:storeId/:productId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/courses/seller/:storeId/:productId/students  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/courses/seller/:storeId/roster  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/courses/seller/:storeId/roster/export  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/courses/seller/:storeId/roster/student/:userId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/curated-collections/:slug  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller') | UseGuards(OptionalJwtAuthGuard)
GET /api/curated-collections/home  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller') | UseGuards(OptionalJwtAuthGuard)
GET /api/exchange-rate/display  [src/exchange-rate/exchange-rate.controller.ts]  
GET /api/finance/:storeId/earnings-statement  [src/finance/finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/finance/:storeId/earnings-statement/download  [src/finance/finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/finance/:storeId/earnings-summary  [src/finance/finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/finance/:storeId/fee-estimate  [src/finance/finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/finance/:storeId/monthly-statement  [src/finance/finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/home-cards  [src/home-cards/home-cards.controller.ts]  
GET /api/home-cards/admin/all  [src/home-cards/home-cards.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/inventory/stock-history/:storeId/:productId  [src/inventory/inventory.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/learning-paths  [src/classroom/learning-paths.controller.ts]  
GET /api/learning-paths/:slug  [src/classroom/learning-paths.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/messaging/seller/conversations/:id/context  [src/messaging/messaging.controller.ts]  UseGuards(JwtAuthGuard) | UseGuards(RolesGuard) Roles('seller')
GET /api/messaging/seller/quick-replies  [src/messaging/messaging.controller.ts]  UseGuards(JwtAuthGuard) | UseGuards(RolesGuard) Roles('seller')
GET /api/orders/download-zip-file  [src/orders/orders.controller.ts]  
GET /api/orders/download-zip-link/:orderId/:productId  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/orders/download-zip/:orderId/:productId  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/orders/my-library  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/orders/seller-free-claims/:storeId  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
GET /api/orders/seller-orders/:storeId/:orderId  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
GET /api/orders/seller-orders/:storeId/print  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
GET /api/orders/seller-returns-all/:storeId  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/orders/seller-returns-all/:storeId/:source/:requestId  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/payment/pk/:provider/callback  [src/payment/payment.controller.ts]  
GET /api/platform-config/maintenance  [src/admin-config/public-platform-config.controller.ts]  
GET /api/platform-config/public  [src/admin-config/public-platform-config.controller.ts]  
GET /api/platform-plans/free-trial-eligibility  [src/platform-plans/platform-plans.controller.ts]  UseGuards(JwtAuthGuard)
GET /api/platform-plans/public/addons  [src/platform-plans/platform-addons.controller.ts]  
GET /api/premium/bank-details  [src/premium/premium.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /api/premium/me  [src/premium/premium.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller') UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /api/premium/payments  [src/premium/premium.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /api/premium/plans  [src/premium/premium.controller.ts]  
GET /api/premium/seller/conflicts  [src/premium/premium.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/premium/terms  [src/premium/premium.controller.ts]  
GET /api/product-questions/product/:idOrSlug  [src/classroom/classroom.controllers.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/product-questions/seller/:storeId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/products/also-bought/:id  [src/products/products.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/products/bestsellers  [src/products/products.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/products/compare  [src/products/products.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/products/free-resources  [src/products/products.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/products/premium-deals  [src/products/products.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/products/sample/:id  [src/products/products.controller.ts]  
GET /api/products/store/:storeId/storefront-sections  [src/products/products.controller.ts]  UseGuards(OptionalJwtAuthGuard)
GET /api/products/store/:storeId/storefront-sections/preview  [src/products/products.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/rating/my-reviewed-ids  [src/rating/rating.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /api/rating/reply-templates/:storeId  [src/rating/rating.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
GET /api/rating/review-requests/:storeId  [src/rating/rating.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
GET /api/rating/store-insights/:storeId  [src/rating/rating.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
GET /api/rating/store/:storeId/public  [src/rating/rating.controller.ts]  
GET /api/rating/store/:storeId/reviews  [src/rating/rating.controller.ts]  
GET /api/referrals/me  [src/retention/retention.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') | UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /api/refund-request/admin  [src/refund-request/refund-request.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/search/trending  [src/search/search.controller.ts]  
GET /api/seller/analytics/free-to-paid  [src/analytics/analytics.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/analytics/page-insights  [src/analytics-visits/visits.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/analytics/products  [src/analytics/analytics.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/analytics/products/export  [src/analytics/analytics.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/analytics/visits  [src/analytics-visits/visits.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/manual-payments/:storeId/proofs  [src/manual-payments/seller-manual-payments.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/manual-payments/:storeId/proofs/:proofId/proof-url  [src/manual-payments/seller-manual-payments.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/manual-payments/:storeId/settings  [src/manual-payments/seller-manual-payments.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/marketing/kpis  [src/marketing/seller-marketing-kpis.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/seller/promotions/stats  [src/marketing/seller-marketing-kpis.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/staff/invite/:token  [src/staff/staff.controller.ts]  
GET /api/store/:storeId/customers/:customerId  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/store/:storeId/dashboard-summary  [src/store-dashboard/store-dashboard.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/store/:storeId/health  [src/store-dashboard/store-dashboard.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/store/:storeId/seo/products/visibility  [src/seo/seller/seller-product-seo.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/store/public/:storeId/catalog-facets  [src/store/store.controller.ts]  
GET /api/wishlist-share/mine  [src/retention/retention.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
GET /api/wishlist-share/public/:token  [src/retention/retention.controller.ts]  
GET /seo-render  [src/seo/public/seo-render.controller.ts]  
GET /seo-render/home  [src/seo/public/seo-render.controller.ts]  
GET /seo-render/page/:slug  [src/seo/public/seo-render.controller.ts]  
GET /seo-render/root/:slug  [src/seo/public/seo-render.controller.ts]  
PATCH /api/admin/chat/conversations/:id/close  [src/chatbot/chat-admin.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/curated-collections/:id  [src/classroom/classroom.controllers.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/learning-paths/:id  [src/classroom/learning-paths.controller.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/marketplace/listings/:id/approve  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/marketplace/listings/:id/quality/approve  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/marketplace/listings/:id/quality/ask-fix  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/marketplace/listings/:id/reject  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/marketplace/listings/:id/test  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/marketplace/listings/:id/trust  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/marketplace/stores/:id/featured  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/premium/payments/:id/approve  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/premium/payments/:id/reject  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/premium/plans/:id  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/staff/:id  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/staff/roles/:id  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/staff/tasks/:id  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/admin/users/:role/:id/force-logout  [src/admin-users/admin-users.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/bundles/seller/:storeId/:id  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/categories/admin/requests/:id/decision  [src/categories/category-requests.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller') | UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/checkout/admin/shipping-zones/:id  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/children/:id  [src/children/children.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') | UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
PATCH /api/collections/:storeId/reorder  [src/collections/collections.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/home-cards/:id  [src/home-cards/home-cards.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/home-cards/admin/reorder  [src/home-cards/home-cards.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/inventory/low-stock-threshold/:storeId/:productId  [src/inventory/inventory.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/messaging/admin/reports/:id  [src/messaging/messaging.controller.ts]  UseGuards(JwtAuthGuard) | UseGuards(RolesGuard) Roles('admin')
PATCH /api/messaging/seller/quick-replies/:id  [src/messaging/messaging.controller.ts]  UseGuards(JwtAuthGuard) | UseGuards(RolesGuard) Roles('seller')
PATCH /api/orders/return-follow-up/:orderId  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/product-questions/seller/:storeId/:id/answer  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/product-questions/seller/:storeId/:id/visibility  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/products/bulk-offers  [src/products/products.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/products/bulk-price  [src/products/products.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/products/bulk-status  [src/products/products.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/products/stock/bulk  [src/products/products.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/products/visibility/:productId  [src/products/products.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/refund-request/:id/follow-up  [src/refund-request/refund-request.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
PATCH /api/seller/manual-payments/:storeId/proofs/:proofId/approve  [src/manual-payments/seller-manual-payments.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/seller/manual-payments/:storeId/proofs/:proofId/reject  [src/manual-payments/seller-manual-payments.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/store-banner/:storeId/reorder  [src/store-banner/store-banner.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/store-theme/:storeId/store-page  [src/store-theme/store-theme.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/store-theme/:storeId/storefront  [src/store-theme/store-theme.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/store/:storeId/holiday  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/admin/ai/ask  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/ai/embeddings/backfill  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/ai/moderation/:productId  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/chat/conversations/:id/reply  [src/chatbot/chat-admin.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/curated-collections  [src/classroom/classroom.controllers.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/finance/credit-jobs/:id/retry  [src/admin-finance/admin-finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/finance/monthly-settlement/run  [src/admin-finance/admin-finance.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/fx/held/:id/confirm  [src/exchange-rate/exchange-rate.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/fx/held/:id/dismiss  [src/exchange-rate/exchange-rate.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/learning-paths  [src/classroom/learning-paths.controller.ts]  UseGuards(OptionalJwtAuthGuard) UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/orders/manual  [src/admin-orders/admin-orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/premium/members/:userId/revoke  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/premium/members/grant  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/premium/plans  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/reauth/verify-password  [src/admin-reauth/admin-reauth.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/:id/reactivate  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/:id/resend-invite  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/:id/reset-2fa  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/:id/sign-out  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/:id/suspend  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/approvals/:id/decide  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/invite  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/me/2fa/disable  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/me/2fa/enable  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/me/2fa/setup  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/me/sign-out-everywhere  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/notes  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/roles  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/tasks  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/tasks/:id/comments  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/admin/staff/tasks/seen  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/ai/assistant/chat  [src/ai-studio/ai-features.controller.ts]  UseGuards(OptionalJwtAuthGuard)
POST /api/ai/seller/:storeId/help  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/image-check  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/insights/weekly  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/products/:productId/cover  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/products/:productId/translate  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/quiz  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/quiz/audio  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/reviews/:ratingId/reply-draft  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/sheet/html  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/sheet/save-as-product  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/translate  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/seller/:storeId/translate/batch  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/ai/voice-search  [src/ai-studio/ai-features.controller.ts]  UseGuards(OptionalJwtAuthGuard)
POST /api/analytics/view  [src/analytics-visits/visits.controller.ts]  
POST /api/auth/become-seller  [src/auth/auth.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/auth/create-buyer-account  [src/auth/auth.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/auth/phone/send  [src/phone-verification/phone-verification.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
POST /api/auth/phone/verify  [src/phone-verification/phone-verification.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
POST /api/auth/switch-to-buyer  [src/auth/auth.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/bundles/seller/:storeId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/bundles/seller/:storeId/:id/duplicate  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/bundles/seller/:storeId/quote  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/bundles/seller/:storeId/suggestions  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard) | UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/categories/requests  [src/categories/category-requests.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/chatbot/conversation/message  [src/chatbot/chatbot.controller.ts]  UseGuards(OptionalJwtAuthGuard)
POST /api/chatbot/message  [src/chatbot/chatbot.controller.ts]  UseGuards(OptionalJwtAuthGuard)
POST /api/checkout/admin/shipping-zones  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/checkout/admin/shipping-zones/seed-defaults  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/checkout/gift-options  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/children  [src/children/children.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') | UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/collections/:storeId/preview  [src/collections/collections.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/couriers/:courier/webhook  [src/couriers/couriers.controller.ts]  
POST /api/couriers/shipments  [src/couriers/couriers.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/courses/learn/:idOrSlug/certificate-details  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard)
POST /api/courses/learn/:idOrSlug/lessons/:lessonId/complete  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard)
POST /api/courses/learn/:idOrSlug/lessons/:lessonId/quiz  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard)
POST /api/home-cards  [src/home-cards/home-cards.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/messaging/seller/quick-replies  [src/messaging/messaging.controller.ts]  UseGuards(JwtAuthGuard) | UseGuards(RolesGuard) Roles('seller')
POST /api/messaging/seller/start  [src/messaging/messaging.controller.ts]  UseGuards(JwtAuthGuard) | UseGuards(RolesGuard) Roles('seller')
POST /api/orders/resend-download-link  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
POST /api/orders/seller-cancel/:orderId  [src/orders/orders.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
POST /api/payment/pk/:provider/callback  [src/payment/payment.controller.ts]  
POST /api/payment/pk/:provider/initiate  [src/payment/payment.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/platform-plans/admin/grant/:storeId  [src/platform-plans/platform-plans.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/premium/cancel  [src/premium/premium.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/premium/payments/:paymentId/proof  [src/premium/premium.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/premium/resume  [src/premium/premium.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/premium/subscribe  [src/premium/premium.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/product-questions/product/:idOrSlug  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard)
POST /api/products/duplicate/:productId  [src/products/products.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/rating/:reviewId/report  [src/rating/rating.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/rating/review-request/:orderId  [src/rating/rating.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/referrals/apply  [src/retention/retention.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') | UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
POST /api/staff/invite/:token/accept  [src/staff/staff.controller.ts]  
POST /api/staff/invite/:token/activate  [src/staff/staff.controller.ts]  
POST /api/store/:storeId/seo/ai/product-draft  [src/seo/seller/seller-seo-ai.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/upload/product-video  [src/upload/upload.controller.ts]  UseGuards(JwtAuthGuard)
POST /api/wishlist-share  [src/retention/retention.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
PUT /api/admin/ai/flags  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PUT /api/admin/ai/store-overrides  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PUT /api/admin/platform-config/chatbot  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/admin/platform-config/cod  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/admin/platform-config/home-content  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/admin/platform-config/platform-fees  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/admin/platform-config/seller-page  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/admin/platform-config/social-links  [src/admin-config/admin-config.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/admin/premium/settings  [src/premium/premium.controller.ts]  Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PUT /api/admin/retention/referral  [src/retention/retention.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('user') UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PUT /api/admin/staff/settings  [src/staff/staff.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PUT /api/ai/seller/:storeId/insights/settings  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PUT /api/ai/seller/:storeId/products/:productId/urdu  [src/ai-studio/ai-features.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PUT /api/checkout/admin/shipping-rates  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PUT /api/checkout/admin/shipping-rates/couriers  [src/checkout/checkout.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PUT /api/courses/seller/:storeId/:productId  [src/classroom/classroom.controllers.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PUT /api/rating/reply-templates/:storeId  [src/rating/rating.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
PUT /api/seller/manual-payments/:storeId/settings  [src/manual-payments/seller-manual-payments.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PUT /api/store/:storeId/customers/:customerId/note  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PUT /api/users/logout-others  [src/users/users.controller.ts]  UseGuards(JwtAuthGuard)

## REMOVED
DELETE /api/subscriptions/:storeId/plans/:id  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/products/education/custom-level-suggestions  [src/products/products.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/products/education/facets  [src/products/products.controller.ts]  
GET /api/refund-request/admin/pending  [src/refund-request/refund-request.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/store/:storeId/verification  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/store/:storeId/verification/requirements  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/store/verification/requirements-preview  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/subscriptions/:storeId/analytics/advanced  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/subscriptions/:storeId/dashboard  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/subscriptions/:storeId/export  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/subscriptions/:storeId/plans  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/subscriptions/:storeId/plans/:id  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/subscriptions/:storeId/subscribers  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/subscriptions/:storeId/subscribers/:id  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
GET /api/subscriptions/admin/churn-cohorts  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/ltv  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/overview  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/payment-failures  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/revenue-breakdown  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/stores  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/stores/:storeId  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/subscriptions/:id  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/subscriptions/:id/payment-attempts  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/admin/webhooks  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/subscriptions/my  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
GET /api/subscriptions/my/:id  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
GET /api/subscriptions/my/:id/timeline  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
GET /api/subscriptions/my/benefits/:storeId  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
GET /api/subscriptions/my/credits  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
GET /api/subscriptions/my/notification-preferences  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
GET /api/subscriptions/public/:storeId/plans  [src/subscriptions/subscriptions.controller.ts]  
PATCH /api/admin/marketplace/leads/:id/under-review  [src/admin-marketplace/admin-marketplace.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/store/:storeId/customers/:customerId  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/store/:storeId/verification  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/subscriptions/:storeId/plans/:id  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/subscriptions/:storeId/subscribers/:id/cancel  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/subscriptions/:storeId/subscribers/:id/pause  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/subscriptions/:storeId/subscribers/:id/resume  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
PATCH /api/subscriptions/admin/plans/:id/suspend  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/subscriptions/admin/plans/:id/unsuspend  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
PATCH /api/subscriptions/my/:id/cancel  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
PATCH /api/subscriptions/my/:id/change-plan  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
PATCH /api/subscriptions/my/:id/pause  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
PATCH /api/subscriptions/my/:id/resume  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
PATCH /api/subscriptions/my/notification-preferences  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
POST /api/auth/admin/create-admin  [src/auth/auth.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/store/:storeId/verification/documents  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/store/:storeId/verification/submit  [src/store/store.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/subscriptions/:storeId/plans  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/subscriptions/:storeId/plans/estimate-health  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/subscriptions/:storeId/subscribers/:id/invoices/:invoiceId/refund  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('seller')
POST /api/subscriptions/admin/invoices/:invoiceId/refund  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/subscriptions/admin/webhooks/:id/retry  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
POST /api/subscriptions/my/billing-portal  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
POST /api/subscriptions/my/credits/:storeId/spend  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
POST /api/subscriptions/my/setup-intent  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)
POST /api/subscriptions/subscribe  [src/subscriptions/subscriptions.controller.ts]  UseGuards(JwtAuthGuard)

## GUARDS CHANGED
DELETE /:id
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
DELETE /api/admin/marketing/campaigns/:id
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
DELETE /api/admin/marketing/coupons/:id
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
DELETE /api/categories/category/:id
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
DELETE /api/rating/admin/:reviewId
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
GET /api/admin/activity-log
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/activity-log/export
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/commission-over-time
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/export
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/fx-exposure
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/overview
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/payout-methods/pending-verification
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/payouts
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/reconciliation
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/reconciliation/history
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/reports/monthly
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/reports/refunds
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/reports/settlement
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/reports/tax
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/revenue-over-time
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/sellers/:storeId
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/sellers/:storeId/transactions
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/sellers/balances
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/finance/transactions
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/fx/history
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/fx/staleness
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/marketing/campaigns
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/admin/marketing/coupons
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
GET /api/orders/:orderId
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/orders/by-checkout/:checkoutId
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/orders/download-url
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/orders/get-download-link
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/orders/my-orders
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/orders/stream-pdf
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('user')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('user', 'seller')
GET /api/public/marketing/campaigns
   OLD 
   NEW UseGuards(OptionalJwtAuthGuard)
PATCH /:id
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /:id/pause
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /:id/resume
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/finance/payouts/:payoutId/approve
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/finance/payouts/:payoutId/reject
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/finance/payouts/:payoutId/retry
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/finance/sellers/:storeId/payout-methods/:methodId/verify
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/marketing/campaigns/:id/status
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/admin/marketing/coupons/:id
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/categories/category/:id
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PATCH /api/categories/reorder
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/finance/process-clearing
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/finance/process-scheduled-payouts
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/finance/sellers/:storeId/payouts/manual
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/fx/override
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/marketing/campaigns
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/admin/marketing/coupons
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
POST /api/categories/add-category
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('seller', 'admin')
POST /api/contact
   OLD 
   NEW UseGuards(OptionalJwtAuthGuard)
POST /upload
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PUT /api/admin/marketing/campaigns/:id
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('admin')
PUT /api/admin/platform-config/fx
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/admin/platform-config/manual-payment
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/admin/platform-config/payout
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard) Roles('admin') | UseGuards(AdminReauthGuard)
PUT /api/orders/mark-paid/:orderId
   OLD UseGuards(JwtAuthGuard, RolesGuard) Roles('seller', 'admin')
   NEW UseGuards(JwtAuthGuard, RolesGuard, AdminReauthGuard) Roles('seller', 'admin')
```
