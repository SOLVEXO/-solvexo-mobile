# Errata for docs/EDUDEEN_DOCS.md

`EDUDEEN_DOCS.md` is not edited. **Where this file and EDUDEEN_DOCS.md
disagree, this file wins.**

Source: backend `edudeen_api` main `5adba44` (2026-11-17). Every entry
names the backend code it comes from. The full diff is in
`docs/BACKEND_DIFF_REPORT.md`.

| # | Where in EDUDEEN_DOCS.md | The docs say | Correct (backend 5adba44) | Backend source |
|---|---|---|---|---|
| E1 | §2.1, "ALL buyer payments…" (line 102) | Bank/wallet details come from `GET /api/payment/manual-transfer/bank-details` | It needs **`?checkoutId=<id>`** (400 without it). The response also has `payeeName` | `src/manual-payments/manual-payments.controller.ts:35-37` |
| E2 | §2.2, plan features (line 106) | Plan features include "subscriptions" | **Store subscriptions (buyer memberships of a store) are retired.** All `/api/subscriptions/*` routes are gone except the Stripe webhook (`POST /api/subscriptions/webhooks/stripe`). No app screen for store plans, subscribers or "My memberships" | commit `eee3d8a` (2026-11-03) "Remove buyer store-membership subscriptions" |
| E3 | §2.5 line 129 ("no stacking with sale/**subscriber**/campaign") and §2.6 line 134 ("Lines with a **store-subscriber price** keep 'only if cheaper'") | Store-subscriber prices exist | There are **no store-subscriber prices** any more (same retirement as E2). Ignore every mention of subscriber prices | as E2 |
| E4 | §6.9 Marketing (line 327) | "subscriptions" is a seller marketing tool | Removed (as E2) | as E2 |
| E5 | §3 / §6.3, line 153 | "Free sample is **required for sellers to publish** digital products" | The **server does not require** a free sample to publish (backend issue 10). **The app keeps requiring one** (owner decision 2026-11-18, matches the web and the product rule). A sample or an enabled buyer preview only raises the listing's quality score ("Add a free sample or preview"). Publishing needs `coverStyle`, and for digital listings `classFrom`/`classTo`. The first publish goes to `pending_review` unless the store is on a paid plan (`product-input.util.ts:169-172`) | `src/products/product-quality.util.ts:139,177`; no sample check in `products.service.ts` |
| E6 | §5.7 Checkout, steps 1–3 | Create the checkout first, then choose the address and delivery zone. The create call is written as `POST /api/checkout` | The call is **`POST /api/checkout/create-checkout`** and takes **`addressId`** (the chosen saved address; otherwise the default is used) and **`shippingZoneId`**. When the cart has physical items and **any active shipping zone exists**, a missing `shippingZoneId` gives **400 "Choose a delivery option for your address"**. So the buyer picks the address and zone **before** the checkout is created (zones: `GET /api/checkout/getShippingZones`). `addShippingInCheckout` still exists for changing the zone later | `src/checkout/checkout.service.ts:601-608, 674-680, 749-762` |
| E7 | §5.7 step 2, "validation, cap 20" | Address validation is unspecified | Strict Pakistani rules, server-side, with a 400 `{message, errors:{field: msg}}`. Required: `phoneNumber`, `zipCode`, `city`, `addressLine1`, `state`. **Phone** `03XXXXXXXXX` / `+923XXXXXXXXX` / `923XXXXXXXXX` (spaces and dashes ignored, stored as `+923…`). **Zip** exactly 5 digits. **City** letters and spaces, at least 2. **Line 1** at least 5 characters. **State** one of exactly `Sindh, Punjab, Khyber Pakhtunkhwa, Balochistan, Islamabad Capital Territory, Gilgit-Baltistan, Azad Kashmir` (case-sensitive). Every text field at most 200 characters. At most 20 addresses; the first is the default | `src/address/address.service.ts:7-71, 90-93` |
| E8 | §5.11 Account / Profile (line 271) | Profile edit unspecified for email | **Email cannot be changed** through `PUT /api/users/profile`. A different email gives 400 "Email cannot be changed from here. Contact support to change your login email." No endpoint changes it; the email field is read-only | `src/users/users.service.ts:57` |
| E9 | §4 Login/Register (lines 163, 194) | OTP lifetime not stated | An **OTP expires after 5 minutes** | `src/auth/auth.service.ts:57,301,786` (`OTP_TTL_SECONDS = 5 * 60`) |
| E10 | §6.x Store builder / store banners (store-banner routes, line 376) | No rules given | A store banner slide may only link to **one of the seller's own live products or collections, by its 24-character id**. External, category or slug links give 400 "A banner link must be the id of one of your own products or collections". **At most 4 active or scheduled slides** per store | `src/store-banner/store-banner-rules.util.ts:4,24`; `store-banner.service.ts:18` |
| E11 | §6.6 Returns / Part C | `seller-returns-all` row id not documented | Each row is keyed by **`requestId` + `source`**. For a refund request, `requestId` is the RefundRequest `_id` (used by `PATCH /api/refund-request/:id/approve|reject`). For an item return, `requestId` is `"<orderId>:<itemId>"`. Detail: `GET /api/orders/seller-returns-all/:storeId/:source/:requestId` | `src/orders/seller-returns-all.util.ts:15`, `orders.controller.ts:202-210` |
| E12 | §6.x Analytics | Comparison figures not described | The seller analytics **overview** sends change percentages (`bookedValueChangePercent`, `collectedChangePercent`, `avgOrderValueChangePercent`, …) **only when `compareToPreviousPeriod=true`**. `totalRevenueChangePercent` no longer exists in seller analytics | `src/analytics/analytics.service.ts:217-266` |
| E13 | §2.1 / §6.1 stores | "One store per seller" | Confirmed and enforced: a second `POST /api/store/create-store` gives **409** "You already have a store — each seller account can run one store". There is no "create another store" flow | `src/store/store.service.ts:141-144` |
| E14 | Global (uploads) | Public upload limit not stated | `POST /api/upload/file` accepts **at most 20 MB** (it was 100 MB) and checks the file contents. Private uploads (`/upload/private-file`) stay at 500 MB | `src/upload/upload.controller.ts:26` (`PUBLIC_UPLOAD_MAX_BYTES`) |
| E15 | Part C (endpoint appendix) | Cut off before the finance and orders modules | Also live and used by the app: `GET /api/finance/:storeId/earnings-summary`, `GET /api/orders/seller-returns-all/:storeId`, `GET /api/orders/my-library`, `GET/PUT /api/courses/seller/:storeId/:productId`, `GET /api/courses/seller/:storeId/roster` (+ `/export`) | backend route table, report Appendix D |

Notes
- `/api/seller/manual-payments/*` (doc line 103) do return 410 as the docs
  say, but the controller is still registered. The app must never call
  these routes.
- No change needed: §2.3 multi-seller COD per package (already in the
  docs); "edits to live listings apply immediately" (line 154; the
  edit-review hold is switched off in
  `product-edit-review.util.ts:29`).
