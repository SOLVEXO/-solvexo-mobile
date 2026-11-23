# Seller app ↔ backend alignment checklist

Source of truth: Edudeen docs Part B §2 (rules), §6 (seller screens), §11
(retired). Found by a static audit of `lib/` (grep of endpoints/fields), not
by calling the API. Tick items off in commits that name the item number.

## P0 — publishing/selling breaks without these
1. [x] **Product publish fields.** API requires `coverStyle` (book|flat) to go
   live and `classFrom/classTo` to publish digital. App sends neither
   (0 references). Add to Add/Edit product + bulk rules.
2. [x] **Retired `educational` type.** Still in edit product (`isEducational`,
   `educationLevel`), seller products filter, onboarding "Educational
   Resources", buyer product card. Map to Digital; keep reading legacy
   `educational` only for display.
3. [x] **Free sample required to publish digital** (docs §2.9). Check the add
   flow uploads `digital.sample`; show the API error otherwise.
4. [x] **Plan lapse** (docs §2.8): `expired|past_due|canceled` → Plan expired
   screen with Choose a plan + Switch/Create buyer account; block
   create/activate. Some `past_due` handling exists (6 files) — verify.
5. [x] **Account switching**: `POST /api/auth/become-seller`,
   `/switch-to-buyer`, `/create-buyer-account`, `GET
   /api/platform-plans/free-trial-eligibility` (hasSellerAccount /
   hasBuyerAccount / trialUsedAt). None used. A seller session cannot use
   buyer checkout (403) → show "Switch to your buyer account".

## P1 — money and orders
6. [x] **Finance (new model, §2.1, §6.10)**: platform-fee wording (not
   commission), Available / Clearing / Open-order estimate / Commission owed
   tiles, monthly statement + `earnings-statement/download?format=csv|pdf`,
   `fee-estimate?price&type`, payout method stores full number encrypted
   (seller sees last 4). Seller direct bank transfer must not exist (410).
7. [x] **COD per package** (§2.3): Mark paid only when `codCollector=='seller'`,
   send `storeId`; order status `partially_paid`.
8. [x] **Returns (§6.6)**: one list (`seller-returns-all` = item returns +
   refund requests), respond-by 48 h pills, reject reason ≥ 10 chars,
   follow-up `item_received → replacement_sent`. Currently separate calls.
9. [x] **Orders (§6.5)**: tabs Needs action / Shipped / Delivered / Completed /
   Cancelled / All, ship-by 48 h badges, Free claims card, buyer cancel reason.

## P2 — features the web has
10. [x] Dashboard summary endpoint (KPIs, action counts, setup checklist).
11. [x] Products list: status tabs with counts (In review / Needs changes),
    inline price/stock edit, Duplicate, bulk activate/deactivate, "Paused –
    plan ended", "Fix now" with admin note.
12. [x] Offers: Premium % vs platform sale (either/or), `PATCH
    /api/products/bulk-offers`, "Your earnings" calculator.
13. [x] Inventory: `PATCH /api/products/stock/bulk`, low-stock limit, history.
14. [x] Course builder (video-only lessons, accessDays, certificate design) and
    Students roster.
15. [x] Store settings: `codEnabled`, `deliverySettings`, `giftWrap`,
    `deliveryDays`, `shipFrom`, `returnPolicy {note, digitalNote}`.
16. [x] Analytics plan-gating: locked card on 403 instead of an error.
18. Bulk upload, docs §6.3; web-only for now.

## Cleanup
17. [x] Remove dead store-verification constants in `api_constaints.dart`.

## Backend issues

Found while aligning the app with the live API (api.edudeen.com,
2026-11-17). The app does not work around any of them.

**Status against backend `main` 5adba44 (2026-11-17), checked in the
source on 2026-11-18** (details: `docs/BACKEND_DIFF_REPORT.md` 3.2):

| # | Issue | Status | Evidence in 5adba44 |
|---|---|---|---|
| 1 | Refund-request "502" | Not a backend issue (retracted) | – |
| 2 | GET payout-schedule creates a record (USD default) | **Fixed on `jami-branch` (PR i9experts/edudeen_api#1, not merged)**: GET is read-only (`saved:false`), store currency default; payout currency rule = owner decision | `finance.service.ts:209-224` find -> create; `finance.controller.ts:190` defaults to USD |
| 3 | Empty enum list in "type must be one of the following values: " | **Open** | `add-payout-method.dto.ts:7` `@IsEnum([...])` with an array (same in coupon, plan, loyalty, discount DTOs); `@IsIn` fixes it. Seen again live 2026-11-18 on PATCH payout-methods without `type` |
| 4 | Docs gap: earnings-summary, seller-returns-all not in EDUDEEN_DOCS Part C | **Open (docs)** | covered by `docs/DOCS_ERRATA.md` E15 |
| 5 | fee-estimate ignores Premium input | **Fixed on `jami-branch` (PR i9experts/edudeen_api#1, not merged)**: `premiumPercent`/`productId` -> `premium` block; app shows member-price earnings | `finance.controller.ts:52-64`, `finance.service.ts:1363-1384` |
| 6 | update-store accepts an empty `productTypes` | **Fixed on `jami-branch` (PR i9experts/edudeen_api#1, not merged)**: 400 for an empty list | `store.service.ts:690-698, 844-847` |
| 7 | update-store coerces `codEnabled`, loose `shipFrom` | **Fixed on `jami-branch` (PR i9experts/edudeen_api#1, not merged)**: boolean required, known province + city required | `store.service.ts:720` (`!!value`); `:813-821` (drops keys, stringifies a numeric province; no city -> shipFrom null) |
| 8 | 500 on bad ids in course routes; silent title cutting | **Fixed on `jami-branch` (PR i9experts/edudeen_api#1, not merged)**: all builder routes 400 on bad ids; titles over 120/150 -> 400 | roster routes now 400 "Invalid id"; builder / students / PUT still 500 on a bad storeId (`classroom.controllers.ts:281-298` -> `store-ownership.util.ts:27`); titles still cut at 120/150 (`course.util.ts:6,187,191`) |
| 9 | Seller manual-payments controller still registered | **Fixed on `jami-branch` (PR i9experts/edudeen_api#1, not merged)**: every route 410, one message | see 9 below |
| 10 | Server does not require a free sample to publish digital products | **Fixed on `jami-branch` (PR i9experts/edudeen_api#1, not merged)**: 400 when a download goes live without a sample (courses exempt) | see 10 below |

1. **Refund-request "502" — retracted (not a backend issue).** Reported
   during P1 (#8 commit message) as `PATCH /api/refund-request/<id>/approve|
   reject -> 502 upstream error`. That came from my test harness: a shell
   loop sent the whole "PATCH /api/..." string as the HTTP method with an
   empty path, which the proxy rejected. Re-tested with clean requests:
   - `PATCH /api/refund-request/000000000000000000000000/approve` -> 404
     `Refund request not found`
   - `PATCH .../reject {}` -> 400 `notes must be longer than or equal to 10
     characters` (and `<= 500`); `{notes: "<10+ chars>"}` -> 404 `Refund
     request not found`
   - `GET /api/refund-request/seller/:storeId` -> 200 `{items:[], total:0,
     page:1, limit:20}`
   This matches `edudeen_api/src/refund-request` (controller `@Patch(':id/
   approve')`, `@Patch(':id/reject')` with `RejectRefundRequestDto.notes`;
   service throws `NotFoundException('Refund request not found')`). The
   same harness bug made my first `return-action` / `return-follow-up`
   probes unreliable; the field rules recorded in the #8 commit come from
   the later, direct requests and stand.
2. **A GET creates data.** `GET /api/finance/:storeId/payout-schedule`
   creates a schedule document when none exists for the asked currency
   (`finance.service.ts`: `findOne` -> `create`, default currency `USD`).
   `GET dashboard` then lists a wallet for that currency, so a PKR store
   shows an empty USD wallet after one USD read (happened to the test store
   on 2026-11-17). Suggest: return a default without saving, and drop the
   `USD` default. The app now only reads the schedule in the store's own
   currency and hides empty wallets in other currencies.
3. **Empty enum list in a validation message.** `POST /api/finance/:storeId/
   payout-methods {type:"zzz"}` -> 400 `type must be one of the following
   values: ` (the allowed values are missing from the text).
4. **Docs gap, not a bug.** `GET /api/finance/:storeId/earnings-summary`
   (Available / Clearing + clearingReleaseAt / expected / commissionOwed)
   and `GET /api/orders/seller-returns-all/:storeId` are live but are not in
   EDUDEEN_DOCS Part C (it is cut off before the finance and orders
   modules).
5. **No server figure for member-price earnings.** `GET /api/finance/:storeId/
   fee-estimate?price&type` ignores any Premium input (`premiumPercent`,
   `premiumDiscountPercent`, `percent`, `productId` all return the same
   `{fee, net}` for the list price). The app shows "Your earnings" for the
   normal price only and does not work out the member price on the device.
   Suggest: accept `premiumPercent` (or `productId`) and return the member
   price, fee and net.
6. **update-store accepts an empty `productTypes`.** `POST /api/store/
   update-store {storeId, productTypes: []}` -> 201 and the store then sells
   nothing (happened to the test store on 2026-11-18; put back at once to
   `["physical_products","digital_downloads"]`). The app requires at least
   one. Suggest: reject an empty list.
7. **update-store coerces loose values.** `codEnabled: "x"` is saved as
   `true` (`!!value`), and `shipFrom` takes any keys and numbers
   (`{province: 5}` -> `"5"`). Suggest: require a boolean and a known
   province list.
8. **500 instead of 400/404 on a bad id in course routes.** `GET /api/
   courses/seller/product/<id>`, `/seller/roster/<storeId>` and
   `/seller/students/<storeId>` -> 500 "Internal server error" (the first
   path part is read as a store id). Suggest: validate the ids and return
   400. Also, the course PUT cuts section titles to 120 and lesson titles
   to 150 characters without an error; the app limits them itself.
9. **Retired seller direct bank transfer is still routed.**
   `SellerManualPaymentsController` (`src/manual-payments/
   seller-manual-payments.controller.ts`, `@Controller('api/seller/
   manual-payments/:storeId')`: settings GET/PUT, proofs list / url /
   approve / reject) is still in `manual-payments.module.ts:17`, although
   the docs say seller direct bank transfer is retired (§2.1, §11). Every
   method answers 410 Gone ("Bank transfers are now paid to Edudeen and
   confirmed by the Edudeen team — sellers no longer set up or confirm
   direct payments.", `manual-payments.service.ts:512-527`), so the routes
   only add surface. Suggest: drop the controller from the module. The app
   must not call these routes; it has no constant or call for them
   (checked in `api_constaints.dart` on 2026-11-18).
10. **Server does not require a free sample to publish digital products,
    although the web and the docs do.** In backend 5adba44 a free sample
    (or an enabled buyer preview) only adds to the listing's quality score
    (`src/products/product-quality.util.ts:139,177`, "Add a free sample or
    preview"); `products.service.ts` has no publish check for
    `digital.sample`. EDUDEEN_DOCS.md §3 (line 153) and the web require one.
    Decision (owner, 2026-11-18): the app KEEPS the requirement (checklist
    #3), matching the web and the product rule. Suggest: enforce it on the
    server when a digital listing goes live. DOCS_ERRATA.md E5 records the
    server behaviour only; it does not change the app rule.
