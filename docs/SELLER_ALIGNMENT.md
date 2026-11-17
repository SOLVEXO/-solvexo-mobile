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
5. **Account switching**: `POST /api/auth/become-seller`,
   `/switch-to-buyer`, `/create-buyer-account`, `GET
   /api/platform-plans/free-trial-eligibility` (hasSellerAccount /
   hasBuyerAccount / trialUsedAt). None used. A seller session cannot use
   buyer checkout (403) → show "Switch to your buyer account".

## P1 — money and orders
6. **Finance (new model, §2.1, §6.10)**: platform-fee wording (not
   commission), Available / Clearing / Open-order estimate / Commission owed
   tiles, monthly statement + `earnings-statement/download?format=csv|pdf`,
   `fee-estimate?price&type`, payout method stores full number encrypted
   (seller sees last 4). Seller direct bank transfer must not exist (410).
7. **COD per package** (§2.3): Mark paid only when `codCollector=='seller'`,
   send `storeId`; order status `partially_paid`.
8. **Returns (§6.6)**: one list (`seller-returns-all` = item returns +
   refund requests), respond-by 48 h pills, reject reason ≥ 10 chars,
   follow-up `item_received → replacement_sent`. Currently separate calls.
9. **Orders (§6.5)**: tabs Needs action / Shipped / Delivered / Completed /
   Cancelled / All, ship-by 48 h badges, Free claims card, buyer cancel reason.

## P2 — features the web has
10. Dashboard summary endpoint (KPIs, action counts, setup checklist).
11. Products list: status tabs with counts (In review / Needs changes),
    inline price/stock edit, Duplicate, bulk activate/deactivate, "Paused –
    plan ended", "Fix now" with admin note.
12. Offers: Premium % vs platform sale (either/or), `PATCH
    /api/products/bulk-offers`, "Your earnings" calculator.
13. Inventory: `PATCH /api/products/stock/bulk`, low-stock limit, history.
14. Course builder (video-only lessons, accessDays, certificate design) and
    Students roster.
15. Store settings: `codEnabled`, `deliverySettings`, `giftWrap`,
    `deliveryDays`, `shipFrom`, `returnPolicy {note, digitalNote}`.
16. Analytics plan-gating: locked card on 403 instead of an error.

## Cleanup
17. Remove dead store-verification constants in `api_constaints.dart`.
