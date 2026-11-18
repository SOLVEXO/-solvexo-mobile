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
14. Course builder (video-only lessons, accessDays, certificate design) and
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
