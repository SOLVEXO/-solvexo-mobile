# EDUDEEN MOBILE APP - COMPLETE SINGLE FILE

> Give this ONE file to the AI. Contents: Part A brief, Part B documentation, Part C API endpoints.

---

# PART A - Brief for the AI

You are a senior mobile engineer. Build the **Edudeen mobile app** (iOS + Android) as a new client for an **already-live backend**. Do NOT redesign or rewrite the backend.

## Files
Everything is in THIS ONE FILE: Part A = this brief, Part B = full product documentation, Part C = API endpoint appendix (paths already include the /api prefix; where a controller has two prefixes the extractor may join them oddly, e.g. address is really /api/address/...).

## Backend facts
- Live API: `https://api.edudeen.com`. REST, JSON, `{success, data}` responses. Auth = JWT access + refresh (`POST /api/auth/refresh`); on 401 refresh once, else log out. Admin tokens last 2 h.
- Realtime: socket.io namespace `/realtime` (topic names only; re-fetch quietly) + notifications socket.
- Any request can return **503 maintenance** `{maintenanceMode, scope, title, message, endsAt}` — show a maintenance screen.
- Money rules, COD, Premium, campaign pricing, returns, plan-lapse rules are in section 2 of the documentation — follow them exactly. **Prices and totals come from the server; never calculate money on the device.**
- Only **Physical** and **Digital** (download or online course) products exist. Do NOT build retired features (section 11): POS, educational type, live classes, seller verification, seller direct bank transfer, marketplace page.

## Scope & order
Follow section 14 phases: (1) foundation, (2) buyer core, (3) buyer learning, (4) seller core, (5) seller advanced, (6) optional admin-lite, (7) hardening. Ship Phase 1–3 as the **Buyer app first**.

## Tech requirements
- Flutter or React Native (Expo) — choose one and keep it consistent. TypeScript/strict Dart.
- English + Urdu with RTL; Noto Nastaliq font for Urdu; seller/admin screens may stay English.
- Secure token storage (Keychain/Keystore). Idempotency-Key header on payment calls.
- Every screen: loading skeleton, error + Retry, empty state, form validation, 44 px touch targets, safe areas.
- Deep links and push (FCM) per section 10. Account deletion in-app + `/delete-account`.
- Image/file uploads with progress and retry; private file downloads via signed URLs; PDF viewer; course video player with the watch rules.
- Stripe card payments USD only; PKR = bank-transfer proof upload or COD.

## Rules for you
- Ask me only about things not in the documents or API appendix. If a request/response shape is unclear, **inspect the endpoint's actual response** (call the API with a test account) instead of guessing.
- Do not invent features, stats or data. Hide blocks when data is missing (as the web does).
- Never hard-code secrets. Use env/config for API base URL and keys (Stripe publishable key, Google client IDs, Firebase).
- Deliver per phase: working code, README with run/build steps, and a short list of what is untested.
- Treat the “Known gaps” in section 12 as unverified: test real Stripe, push and uploads before claiming they work.


---

# PART B - DOCUMENTATION

# Edudeen Mobile App — Complete Detailed Documentation

> Built from the full `CLAUDE.md` project memory (all 9 sections + the whole change log up to 16 Nov 2026), the web router and the API controllers.
> Edudeen is **education-only** (no POS / fashion / food / beauty). The mobile app is a **new client on the existing API** — no backend rewrite is required.
> Status words used below: **LIVE** = built in web/API; **RETIRED** = removed, do not build; **GAP** = not built / not verified yet.

---

## 0. Table of contents
1. Product overview & architecture
2. Business rules (money, plans, fees, COD, currency, Premium, campaigns, returns)
3. Cross-cutting app behaviour (auth, maintenance, realtime, i18n, errors…)
4. Data model cheat-sheet
5. BUYER app — every screen and rule
6. SELLER app — every screen and rule
7. ADMIN — features (web) and what to put in a mobile admin
8. Notifications catalogue
9. API reference by module
10. Mobile-specific build guidance
11. Retired features (do NOT build)
12. Known gaps, open issues, roadmap
13. Environment / owner TODOs / release checklist
14. Suggested delivery phases

---

## 1. Product overview & architecture

**What it is:** a multi-seller marketplace for education in Pakistan (PKR/USD, English + Urdu/RTL, buyers can see prices in local currency). Sellers = teachers, publishers, academies, schools. Buyers = parents, students, teachers, schools.

**What is sold (only two product types remain):**
| Type | Notes |
|---|---|
| **Physical** | books, stationery, toys, etc. Variants, stock, weight, parcel type, shipping, COD. |
| **Digital** | downloadable files (PDF, worksheets), **or Online Course** (`deliveryFormat = download | course`). Always **qty 1**. Class range (`classFrom/classTo`) required to publish. |

`educational` product type and `live_class` are **RETIRED** (see §11).

**Stack**
| Part | Path | Stack |
|---|---|---|
| Web | `edudeen_web` | React 19 + Vite + TS + Tailwind v4, react-router 7 |
| API | `edudeen_api` | NestJS + Mongoose 9, BullMQ (Redis), Stripe, Cloudinary (+ Cloudflare R2 / Backblaze B2 for big private files), Anthropic (AI), socket.io |
| Live API | `https://api.edudeen.com` (Railway), all routes `/api/...` | |
| Web host | Vercel (bot prerender via edge middleware + `/seo-render`) | |

**Roles:** `user` (Buyer), `seller`, `admin` (owner) and **staff** (admin doc with `isStaff`, role template + permission add/remove). One store per seller. A person can have both a seller account and a buyer account on the same email (switch / create-buyer-account endpoints).

**Important route-role rule:** checkout / payment / order / library routes are `@Roles('user','seller')` for library and **buyer-only for checkout/payment** (a seller session gets 403 → app must show “Switch to your buyer account”).

---

## 2. Business rules (the app must show these correctly)

### 2.1 Money flow (new model, 12 Oct)
- **Seller buys a monthly/yearly platform plan** (admin edits plans; optional card-less **free trial** plan with `trialDays`). Yearly = `yearlyPriceUSD` or 12× monthly. Plan limits are one PlatformPlan (monthly/yearly only change price).
- **Platform fee per sale** (admin → Platform Config → *Platform fees*): `{digital, physical}` each `{mode: percentage | fixed USD per unit, value}`. Applies on **item price only, never shipping**. Falls back to old commission rules when unset (legacy).
- **ALL buyer payments go to the PLATFORM account.** Card = platform Stripe. Bank/wallet = account entered by admin (`GET /api/payment/manual-transfer/bank-details`). Buyer uploads **proof** → **admin approves** (Admin → Payment proofs) → order paid → seller wallet credited (sale − fee, “clearing” period).
- **Seller direct bank transfer is RETIRED** (`/api/seller/manual-payments/*` return 410).
- **Seller paid via wallet → payout request → admin approves/sends manually.** Payout account numbers stored encrypted (AES-GCM); seller sees last 4 only; admin reveal is audit-logged.
- Seller credit is **durable** (outbox `sale_credit_jobs`, cron every 5 min, retries 10×, admin “Failed credits” tab).
- No per-plan product-count limit. Plan features gate: promotions, advanced analytics, SEO tools/AI, email campaigns, loyalty, subscriptions, custom domain, AI credits, priority support, featured badge.

### 2.2 Currency
- Charge currencies: **PKR and USD only**. **Card works only on USD checkouts**; PKR → bank transfer / COD.
- **Display currency**: buyer sees prices in detected local currency (menu: local / USD / PKR). Display only; charge currency = `chargeCurrencyFor` (PKR→PKR, else USD). API `GET /api/exchange-rate/display?country=` → `{country, currency, ratePerUSD, asOf, stale}`; detection order = CDN header → client IP (api.country.is) → browser hint. A saved choice holds only while the buyer is in the same country.
- FX: daily cron + on-demand; providers open.er-api / jsdelivr / frankfurter. Admin FX Settings can override; held (suspicious) rates need admin confirm.
- One formatter everywhere: USD `$12.50`, PKR `Rs 1,440` (`formatPrice`).

### 2.3 Cash on Delivery (COD)
- Allowed for **physical** items only; digital never COD (mixed carts = “split”).
- Multi-seller carts allowed: **collected and confirmed PER PACKAGE** (each seller order has `isPaid/paidAt/codAmount`; order status can be `partially_paid`). Each store must have `codEnabled`.
- Admin COD config: `maxPerPackagePKR` (limit incl. package shipping) and `feePerPackagePKR`. Over the limit → COD hidden.
- **Who collects the cash:** if delivered by Edudeen’s courier (`codCollector='platform'`) only admin confirms paid and seller is credited after; fee charged only on those. If the seller’s own rider (`'seller'`) the seller marks paid and Edudeen debits the commission from the wallet. **Couriers (TCS/Leopards/PostEx) are switched OFF** until credentials exist (`COURIER_DELIVERY_ENABLED`), so today COD cash stays with the seller.

### 2.4 Shipping & delivery
- Admin shipping **zones** (physical orders need a zone once any zone exists; zone gates where Edudeen delivers). Optional **weight-based rate table** (slabs per route class sameCity / sameProvince / national, extra per kg, volumetric weight, fragile surcharge, fuel %, tax %) — **OFF by default**.
- Seller options: own delivery fee / free-over amount (`Store.deliverySettings`), **gift wrap** fee (`Store.giftWrap`), `deliveryDays {sameCity, sameProvince, national:{min,max}}`, `shipFrom {city, province}`, dispatch days.
- Product `parcelType` (document | standard | fragile | bulky), `packageCm {l,w,h}`, `shippingWeight` required for physical.
- Delivery info for product page: `GET /api/checkout/delivery-info?productId&variantId&quantity&zoneId&currency` (read-only) → fee, estimate, freeShipping, cod, `dispatchDays`, `routeDays`.
- Seller must mark shipped within **48 h** of payment (dispatch-on-time metric); “ship by” badges grey/amber/red.

### 2.5 Edudeen Premium (buyer membership)
- Plans (monthly/yearly), paid by **bank transfer + proof → admin approval** (card billing not done). Benefits: member price on products where seller opted in (`Store.premiumDiscount`, `Product.premiumDiscountPercent`) + platform discount (default 5%, admin 0–30%), monthly platform-funded personal coupon, early access to campaigns, more children (limit from entitlements), priority support on Contact, wishlist alerts first.
- Member price = LIST × (1 − seller% − platform%); the member gets **only** that (no stacking with sale/subscriber/campaign); never worse than normal price. Premium and platform sale are **mutually exclusive per product** (`premiumOptOut`).
- Free products show no Premium teaser. Premium page shows USD/PKR only.

### 2.6 Campaigns / flash sale / offers
- Platform campaigns computed from **LIST price** (compare-at when higher than price). Strict **per-product opt-in** (`Product.campaignIds`).
- **Platform sale suspends the seller’s own sale** while live (owner-approved money change): Edudeen sale price always applies; platform-sponsored seller is credited LIST; seller-sponsored gets buyer unit. Lines with a store-subscriber price keep “only if cheaper”.
- Campaign fields: dates, subsidy cap `subsidyCapUSD` (soft), `backgroundImage`, `bannerImage`, “Coming soon” state (`includeUpcoming=1`), rotation slot, end notification (“continue your sale?”).
- Seller joins via `/store/:id/marketing/sale/:campaignId` (“Apply now / Manage”, uses `PATCH /api/products/bulk-offers`).

### 2.7 Returns & refunds
- **Physical** only after delivery; **digital** refundable only if never downloaded.
- Buyer raises item **return** (order path) or item **refund request**; both use ONE reason list: `damaged, missing_pages, printing_error, wrong_item, wrong_edition_or_class, not_as_described, digital_not_working, other` (note 20–1000 chars, up to 4 photos). Old codes still display.
- Seller sees ONE list with **respond-by 48 h (display only, nothing auto-approved)**; reject needs reason ≥ 10 chars; follow-up tracking steps `item_received → replacement_sent` (no money).
- Seller-stated `returnPolicy` (physical note + digital note) is shown but not enforced by the API.

### 2.8 Plan lapse
- Trial / paid plan ends (`expired`, `past_due`, `canceled`) → the store’s live listings are **hidden (paused)** and restored when a plan returns; seller sees the **Plan expired** screen; cannot create/activate products. Trial: once per seller, 3-day warning email + notification.
- Admin can give a seller a **free plan 1–31 days** (complimentary).
- Listings of sellers on a **paid active plan publish directly**; free/trial plan = admin review first. Contact info (phone/WhatsApp/email) in text forces review. Quality rules set a non-blocking `needs_review` flag.

### 2.9 Other rules
- Store names (not personal seller names) are shown to buyers everywhere.
- Digital qty always 1; Buy Now does not touch the cart (`GET /api/cart/buy-now`).
- Free digital product (price 0) = **“Avail for free”** → free checkout → order marked `isFreeClaim` (“Availed” badge; excluded from seller revenue).
- Free sample is **required for sellers to publish** digital products but **no buyer-facing sample button** (env `PUBLIC_FREE_SAMPLE`); buyer sees a protected **preview** (stamped PDF pages).
- Edits to live listings apply **immediately** (edit-review was reversed); first publish may go to review.

---

## 3. Cross-cutting app behaviour

| Topic | Rule |
|---|---|
| **Auth** | JWT access (24 h; **admin 2 h**) + refresh (`POST /api/auth/refresh`). Admin refresh is single-use rotation. On 401 refresh once then logout; a wrong *current password* must not log out. |
| **Login** | Buyer \| Seller toggle; unverified login → resend OTP + OTP screen with `attemptsLeft`. Social login (Google; Facebook fails closed without keys). Admin/staff: lockout after 5 fails (15 min), staff get an e-mailed 6-digit code (or TOTP). Admin password reset by e-mail is refused. |
| **Maintenance** | Any call can return **503** `{maintenanceMode, scope, title, message, endsAt}`. Scopes: areas `all|buyer|seller|checkout|uploads` and `feature:<flash_sale|search|categories|product_page|cart|reviews|messaging|stores|learn|orders>`. Poll `GET /api/platform-config/maintenance`. Never blocked: auth, admin, platform-config, webhooks, health. Show full-screen page for `all|buyer`, per-feature notice otherwise. Scheduled (`startsAt` future) = banner only. |
| **Platform config** | `GET /api/platform-config/public`: homeContent (hero text/images, trust, about, legal pages, contact, app store links), social links, `commerce.codAvailable/cod/paymentMethods`, chatbot, sellerPage, statsThresholds. Cache stale-while-revalidate. |
| **Realtime** | socket.io namespace `/realtime`: send token in handshake `auth`; rooms `user:<id>`, `store:<id>`, `admin`. Messages are **topic names only** (no data) → client re-reads quietly. Public topics: catalog, products, config, banners, home-cards, campaigns, categories, reviews, plans, bundles, announcements, faqs, learning-paths, storefront. Private topics: orders, finance, loyalty, quotes, promotions, children, store… Skip the echo of your own write for ~4 s. Reconnect on login/logout. |
| **Notifications socket** | separate gateway: new notification pushes; fall back to 30 s unread poll when socket down; dedupe by `_id`; page size 50. |
| **Language** | English / Urdu (RTL, font Noto Nastaliq “Edudeen Urdu”). Web translates by exact-string dictionary (`ur.ts`); admin/seller panels stay English. User-generated text not translated. |
| **Errors** | Every call: loading / error + Retry / empty. Idempotency-Key header on payment calls (`cod|free:<checkoutId>`, card includes page-load id). 429 throttles (default 300/min per IP; auth/payment/AI have own limits). |
| **Uploads** | Public images → Cloudinary; private (sold files, samples, proofs) → R2/B2 (`r2/<folder>/<uuid>-<name>`) else Cloudinary (10 MB cap on free plan). Magic-byte check: images/PDF must match extension; proofs allow jpg/png/webp/heic/pdf. Upload timeout 10 min; private max 500 MB, general 20 MB, product video 60 MB (mp4/mov/webm). |
| **Security** | Never boot API on live DB; admin writes need password re-auth (`X-Admin-Reauth`) on money routes; security headers; tokens currently in JS cookies (HttpOnly+CSRF is an open item — on mobile use secure storage). |
| **Visit tracking** | `POST /api/analytics/view {type:store|product,id,source?,term?}` (204 always, bots dropped, 30-min dedupe). Source: utm / in-app previous screen / referrer → edudeen_search, category, direct, social, external. |
| **Country in URL** | web appends `#pk`; not needed in app. |
| **Order numbers** | Use `orderNumber`, never raw ObjectIds, in any visible text. |

---

## 4. Data model cheat-sheet (fields the app touches)

- **User/Seller/Admin** (separate docs, same email allowed): name, email, phone (verified via WhatsApp/SMS), photo, role, displayCurrency, detectedCountry, currencyPreference (charge), freeTrialUsedAt, notification prefs (topics incl. promotions, retention channel), tokenVersion.
- **Store:** name, slug, logo, coverImage, tagline, description, aboutBio, educatorProfile, productTypes (`physical_products` / `digital_downloads`), status (`active` immediately; legacy `pending`/`rejected`), baseCurrency, codEnabled, deliverySettings, giftWrap, deliveryDays, shipFrom, deliveryMethod (self only while couriers off), returnPolicy {note, digitalNote}, premiumDiscount, responseStats, trustStats {responseRate, dispatch}, averageRating, featuredRank, skuSeq, directPayment (retired).
- **Product:** title (starts capital, ≥10 chars), slug (+previousSlugs → 301), description (≥20), descriptionImages ≤6, images ≤20, video {url,posterUrl,frontFirst}, productType physical|digital, deliveryFormat download|course, categoryId (root) + subCategoryId (any descendant, 4 levels), classFrom/classTo, curricula/board, tags, coverStyle book|flat (required to go live), author/publisher/edition, digital {fileFormats, pageCount, sample, preview}, variants (price, compareAt, sku, stock, weight, options, license tiers), lowStockThreshold, campaignIds, premiumDiscountPercent/premiumOptOut, status (draft, pending_review, active, scheduled, inactive, rejected), scheduledAt (Pakistan time), flags (needs_review, contact_info), qualityReasons, isTest, parcelType, purchaseCount, pausedFromStatus.
- **Course:** sections/lessons (new lessons = video only; YouTube/Vimeo link or upload; old pdf/text/quiz lessons still play), outcomes, instructor, accessDays (+`accessDaysLog`, per-buyer window), certificateConfig {watermark text/image, stamp, signature name/title/image, issuer, logo}. **CourseProgress:** completed lessons, lastLessonId, certificateDetails, completedAt.
- **Cart / Checkout / Order:** order → `sellerOrders[]` (packages) with status, isPaid, codAmount, codCollector, shippingCourier, shippingFee, giftWrapFee, items (variant, qty, price, returnStatus/…), fxSnapshots, `isPremiumOrder`, `isFreeClaim`, cancelReason.
- **Coupon:** code, type/value (≤90% percent), appliesTo store|categories|products, targetIds, startsAt, expiresAt, perCustomerLimit, firstOrderOnly, visibility public|private, usage.
- **Others:** Wishlist, Children (≤8, class/gradeLabel/subjects), Notification, Conversation/Message, Rating, RefundRequest (+history, followUp), Campaign, Banner (placement, schedule, draft), HomeCard, PlatformConfig, FinanceTransaction/Wallet/Payout/PayoutMethod, PremiumPlan/Membership/Payment, StoreTheme (+draft), PlatformPlan/SellerPlatformSubscription, stock_history, analytics_visit_daily, ChatConversation (support).

---

## 5. BUYER app — screens, behaviour, APIs

### 5.1 Launch & auth
1. **Splash** (logo + progress) → **Intro slides** (admin-managed `GET /api/onboarding-slides`, edited in Admin → App slides).
2. **Register**: Buyer | Seller toggle (`?role=seller`), email/phone + password → **OTP verify** (`/api/auth/register`, `/verifyOtp`, `/resend-otp`; error codes + attemptsLeft).
3. **Login** (`/login`), **Google/social** (`/social-login`; pre-hijack protected), **Forgot password** (`/forgot-password` → `/verify-otp` → `/new-password`).
4. After login: if `afterAuthPath` stored (e.g. buy-now) go back there (`safeRedirectPath` only).
5. Guests can browse, add to cart, wishlist (sign-in prompt for saving, checkout, reviews, messaging).
6. **Switching:** buyer → “Sell on Edudeen” (`POST /api/auth/become-seller` creates seller on same email/password, plan preselected); seller → “Switch to shopping” (`POST /api/auth/switch-to-buyer`) or “Create buyer account” (`/create-buyer-account`). `GET /api/platform-plans/free-trial-eligibility` returns `hasSellerAccount/hasBuyerAccount/trialUsedAt`.

### 5.2 Home (landing)
Order of blocks (all admin-driven, each hides itself when empty):
1. Top ticker/announcements/deals (`useTopBarDeals`): platform sale “UP TO X%” (platform campaign % only), flash deals, early-access chip for members, countdown (>24 h “15d 12h 03m”, else HH:MM:SS).
2. **Mega Sale strip** (DealsBanner): campaign slides + “Coming soon / Starts in”, optional background image.
3. **Hero**: admin banners (placement `homepageHero`, 2560×720, draft/schedule/live) else HomeHero text card (h1). Skeleton until config loads.
4. **Home cards grid** (Amazon-style 4-up cards; admin-created, tiles with in-site link or http(s)) or fallback **Shop by category** cards (up to 8 mains with photo collages from best-selling products).
5. **Bestsellers** (“X sold” only ≥10; 4 or 8 items), **For your child** rail (one query per child subject, interleaved), **Browse everything** (100 products, “More” +100, filters, sort, grid/list), bundles, featured, curated shelves/picks, featured sellers, collections, trust/stats + newsletter, reviews.
6. Footer: contact (phone/WhatsApp/address/email), social links, legal links, Sitemap.
- Excluded from rails server-side: `isTest`, `needs_review`, invalid price (`RAIL_QUERY_EXCLUDE`).
- Quick-access rail (xl+ only on web; use tab/shortcuts on phone).
- “Open app / Download app” promos exist on web only when `VITE_APP_LIVE=true`; QR shown only with a public store link.

### 5.3 Browse / search / learn
- **Categories**: tree up to 4 levels (`GET /api/categories/category-tree`, one query; each node has `productCount`, `coverImage`, `coverImages`). Hide nodes with count 0. Mega menu = icon per category (keyword-chosen lucide icon, no repeats in a list).
- **Browse URL model** (same on app as screen params): `category`, `search/q`, `class`, `subjects` (multi, interleaved), `board`, `type` (physical | digital | course), `min/max` price, `rating`, `free`, `campaign`, `format=course`, `sort`, `page`, `exact`, `browse`.
- **Quick filter row**: All filters (drawer), Class, Board, Type, Price (preset buckets / “Custom”). **Filters drawer**: single “Type” group (Physical / Digital download / Online course), categories, price, rating, free. Sort menu; grid/list toggle (list: 2-line description, store, rating). Main-category pill row on shop views.
- **Learn pages**: `/learn`, `/learn/:level/:subject?`, `/browse/:class/:subject?`; class levels nursery → class-12, O/A-level, university (`class-levels.ts`); chips show **Board**; `?grade=`/`?age=` legacy still mapped.
- **Search** (`/api/search`): synonyms incl. Roman Urdu/Urdu, typo fix (`correctedQuery/didYouMean`, `?exact=1`), trending searches, recent searches, **voice search** (device speech), semantic/hybrid (embeddings) when enabled, shows “Free”.
- **Compare** (≤4, `GET /api/products/compare?ids=`), compare tray.
- Campaign landing `?campaign=<id>`; collections `/collections/:slug`; curated picks `/picks/:slug`; seasonal `/seasonal/:slug`; bundles `/bundles/:slug`; learning paths `/learning-paths(/:slug)`.
- Recently viewed (synced to account).
- Product cards: image whole (`object-contain`), book-cover style or flat (per `coverStyle`), one % badge, rating only if ≥1 review, class range, hover/long-press: store name, Compare, Save; **cart button** on cards; Premium teaser only on buy box/cart line.

### 5.4 Product page
- Gallery: video slide (first or after pictures), swipe, zoom (+/-, prev/next), max 20 images; one sale badge.
- Title, price (campaign price if applicable), compare-at, **member price**, store trust card (logo, name, rating ≥10 reviews, response/dispatch stats ≥10 samples, **Visit store**), variants/license tiers, qty (hidden for digital), class range, board, “What you get” (file formats, page count), author/publisher/edition, details tab (SKU), description tab (+pictures), reviews (summary, star breakdown, filter by `usedFor`, write review if `canReview`, seller reply), Q&A, bundles (“Also in: …”), delivery row (see 2.4), COD row, returns line + policy link, public coupon badge (`publicCoupon`), seller trust, related rails (level, bought together, seller, **Similar for Class N**), AI review summary.
- Buttons: **Add to cart** (selected qty), **Buy now** (`/checkout?buyNow=` ephemeral cart), **Avail for free** (price 0), wishlist heart, share, report, compare.
- Course product: course info (outcomes, instructor, access days, lessons count).
- Product page is prefetched; cache last answer per slug 10 min.

### 5.5 Store page (`/shop/:slug`)
Identity banner (cover, logo, name, tagline), **trust strip** (rating ≥10, response rate, on-time dispatch, city, “Not enough data” below 10), tabs **Products / About / Reviews** (`?tab=`), products with kind pills (All / Digital / Physical / Online courses) + search + filters, **store highlights** (Featured ≤8, New arrivals, Best sellers; published config only), About (aboutBio, educator card, return policy), Reviews (all stars, paged), follow/unfollow, message seller, store blog (`/api/public/store-blog`), custom pages, store banners. Seller custom domains supported (storefront layout).

### 5.6 Cart & wishlist
- Multi-store cart (`/api/cart`), repriced from live variant price, qty rules (digital = 1), campaign/premium lines, store groups, “Sold by <store>”, **remove with 5 s Undo**, **Save for later** (wishlist add + cart remove in parallel with rollback), **Saved for later** list (= wishlist lines not in cart; Move to cart), coupon hint (“Have a coupon? Apply at checkout”), shipping shown only when cart is exactly one physical line, one **Proceed to Checkout** for all stores.
- Guest cart supported. Add to cart rejects cancelled/removed items. Cart count cached; no 0 flash.
- Wishlist (`/api/wishlist...`, shared link `GET/…/wishlist-share`, public `/wishlist/shared/:token`), heart toggles optimistic, wishlist alerts (price drop / back in stock) toggle; Compare.
- Retention: cart reminders, back-in-stock/price-drop, referral coupons (settings in own collection).

### 5.7 Checkout (`/api/checkout`)
1. **Create** `POST /api/checkout` (all stores unified; `items[]` or `buyNow`). Errors: CastError → 400 “Something in your cart is no longer valid”, show Retry.
2. **Address** step (saved addresses `/api/address`, first = default, validation, cap 20; digital-only skips address). Changing address drops old checkout state.
3. **Delivery** step: zone shipping per package (“Shipment N of M”); if exactly one option, step hidden and shown as a line.
4. **Gift options**: `GET/POST /api/checkout/gift-options` (note + wrap fee, re-prices).
5. **Coupon / gift card**: apply one at a time; remove first to replace. Seller coupons rules in 2.9/§4; platform/Premium coupons skip store rules. Premium savings estimate shown.
6. **Payment methods** (only usable ones selectable; “No payment method is available” until admin fills account):
   - **Card (Stripe)** USD only: `apiInitiatePayment` (re-initiated when total changes), 3DS, poll status; late duplicate card payment is auto-refunded.
   - **Bank transfer / wallet**: show platform account, **upload proof** (jpg/png/webp/heic/pdf, hash used for duplicate detection) with Idempotency-Key.
   - **COD** (physical only; limit/fee note; per-package amounts; split with digital).
   - **Free** (total 0).
   - PK hosted gateways (JazzCash/Easypaisa/Safepay) `payment/pk-return` exist env-gated.
7. **Review** → place order → **Order success** (`/order-success?checkout=ID`, restores orders via `GET /api/orders/by-checkout/:id`), per-package payment status, Download button for free/COD digital, NextUp rail.
- Show currency note “Approx. in your currency”; seller sessions see switch-to-buyer message.
- Checkout cancels open card PaymentIntents after COD/bank/free orders.

### 5.8 Orders & after-sales (`/api/orders`)
- **My orders** list + detail: per-package status timeline (`buildOrderProgress`), payment status per package, COD “Pay Rs X on delivery”, tracking/courier link (`safeHttpUrl`), shipping estimate snapshot, cancel (preset/custom reason; seller sees it), **invoice** page (print/share PDF), “Availed” for free claims, re-download.
- **Returns / refunds**: Account → Returns; request return or item refund with structured reason + photos; status + timeline; seller reject reason shown. (Order-return dialog still free-text only — structured form for it is a GAP.)
- Reviews after delivery (`canReview/hasReviewed`), `usedFor` home|classroom|school.
- Reorder / re-send download link `POST /api/orders/resend-download-link` (5/10 min).

### 5.9 Library (Downloads) — `/account/downloads`
Tabs **Files / Courses**; filters (type, sort, last 30 days), unavailable/expired states, secure signed URLs (expiring R2/Cloudinary), **download all as ZIP** (`download-zip-link` token flow, counts one download per bundle), “Pick up where you left off”, NextUp rail. Preview PDFs stamped; Cloudinary lesson links do not expire (use R2).

### 5.10 Courses (`/course/:slug`, `/api/courses`)
- Player: lessons outline, video (YouTube/Vimeo via postMessage or uploaded), **watch rules**: no seeking past watched, Next locked until the video ends (completed lessons free), 60 s inactivity pauses behind “Are you still there?” (client-side only; server does not enforce).
- Progress, mark complete (`apiCompleteLesson`), quizzes (legacy lesson types still play), `GET /api/courses/mine` (progress, `isPublished`), access window per buyer (purchase date + `accessDays` at purchase; lifetime = stays; seller deleting course doesn’t cut existing buyers; admin takedown does).
- **Resume popup** (home + downloads, snooze 30 min; per-course dismiss).
- **Certificate**: before first issue buyer fills details (`POST /api/courses/learn/:id/certificate-details {fullName, guardianName, institute, city, country}`), then certificate issues on completion; public verify `GET /api/courses/certificates/:code`; A4-landscape view with watermark/stamp/signature/logo; print/save PDF (on mobile generate PDF or share image).

### 5.11 Account (`/account/*`)
Dashboard (stat cards link, account completion list, premium status), Orders, Returns, **Referrals** (`/api/referrals`), Downloads, **My children** (`/api/children`, ≤8; class/grade + subjects drive ShoppingForBar and rails; Premium raises limit), Premium, Wishlist, Reviews, Payments, Profile (photo, name, **phone verification** via WhatsApp/SMS `/api/auth/phone/*`, **change password** — new token pair must be stored), Security, Addresses, Notifications, Settings, Messages, Lists/Quotes. Profile menu: role badge, Premium badge. **Delete account**: `DELETE /api/users/profile {confirm:'DELETE', password?}`; 409 `ACCOUNT_DELETE_BLOCKED` while open orders / active Premium (server message is shown). Public page `/delete-account` needed for store compliance.

### 5.12 Premium (`/premium`, `/api/premium`)
Landing (member card, Free vs Premium table, how it works), subscribe → shared bank details + proof upload (yearly toggle), status, early-access chips, member prices everywhere, monthly coupon (PRM), cancel/expiry. Admin approves.

### 5.13 Messaging
Buyer ↔ seller chat (`/api/messaging`, socket): conversations, unread, attachments, block rules. Seller can start a thread only with a buyer who holds a live digital item of that store (hidden for buyer until first message). “View Store” opens `/shop/<slug>`, never the seller dashboard.

### 5.14 Notifications (`/api/notifications`)
List (page 50, Load more), unread filter, mark read, delete, **Clear read** (`DELETE /clear-read`), topic toggles (orders, messages, promotions…), **WhatsApp/SMS channels locked “Coming soon”** (const `CHANNELS_COMING_SOON`), push needs Firebase keys. Notification `data.link` deep-links to order/product/store pages. See §8.

### 5.15 Support
- **Help chatbot** (`POST /api/chatbot/message {audience,text,lang?}`): greetings in many languages, FAQ matcher, quick replies + action links; typed unknown text **escalates to Admin Chat** (guests give name + email/phone once → `guestToken`; poll `GET /api/chatbot/conversation?since=`; replies come as `support_reply` notification + e-mail). AI fallback toggle default off. WhatsApp bridge dropped.
- Contact form (`POST /api/contact`, priority for signed-in Premium), FAQ, Help, Returns, About, Pricing, Become-a-seller, Privacy, Terms, Cookie policy, Sitemap (HTML), Blog.

### 5.16 Other buyer features
Newsletter signup (`/api/newsletter`, source home|footer), testimonials, gift cards/loyalty on storefront (retired extras flag off), **AI worksheet builder trial** (`/api/public/worksheet-builder`), CourseResumePopup, app-open prompts (web only), 404 page, crash screen (`AppCrashScreen`) + stale-chunk reload.

---

## 6. SELLER app — screens, behaviour, APIs
(Seller panel is **English only**, base `/store/:storeId`, API under `/api/store*`, `/api/finance`, `/api/orders/seller-*`, `/api/inventory`, `/api/products`, `/api/courses/seller`.)

### 6.1 Onboarding & access
Register as seller or `become-seller` from buyer; onboarding wizard (store details, plan & payment step; free-trial plan skips card; draft saved); stores are **active immediately** (no verification). Plan states (`planStatus`): trial N days left / trial ended / ended / paid / free / none. **Plan-expired screen** (`/plan-expired`) with “Choose a plan” and Switch/Create buyer account.

### 6.2 Dashboard
Summary endpoint (KPIs, today block paid/free/mixed, action counts = to-ship + overdue, low stock, setup checklist `SetupChecklistCard`), Premium card, notifications bell → `/notifications`, activity feed. Metrics rules: booked vs collected, free claims counted separately, PKT timezone.

### 6.3 Products
- **List**: status tabs All / Active / In review / Needs changes / Draft / Inactive with counts, filters (type, category incl. descendants), search, last-30-days views/sales, sort, low-quality toggle, **inline price/stock edit**, bulk change price / deactivate / activate, row menu (Premium add/remove, platform sale add/remove, **Duplicate** as draft, **Activate/Deactivate**, View on store, Delete with past-sales warning), “Paused – plan ended”, “Fix now” for rejected (admin note banner), `?nosub=1` filter bar.
- **Add/Edit wizard (6 steps)**: type (Physical | Digital), basics (title capital, category + sub cascade, class range, board, tags — unconfirmed tag saved on blur), photos (multi-upload, drag, reorder, cover, ≤20, 3 parallel; description pictures ≤6; product video), files (digital: multiple files via R2, **free sample required to publish**, stamping + buyer preview default ON, file formats, page count auto), pricing/variants (compare-at > price, PKR whole rupees, license tiers incl. classroom/school for digital), shipping (physical: weight required ≤50 kg, parcel type, packed cm, SKU auto `<STORE3>-<id>-<YYMMDD>-<NNNN>`), **Product card style** (book | flat, required to go live), **Offers** (Premium % vs platform sale either/or; “Your earnings” calculator), Book details (author/publisher/edition), schedule (Pakistan time), review step with missing-field links, sticky Save draft / Publish, live preview, autosave restore (Add), leave guard. Live inline field errors + global live validation. Number inputs blur on wheel scroll.
- **Course builder** (`/products/:id/course`): sections, **video-only new lessons** (upload or YouTube/Vimeo link), outcomes, instructor, `accessDays`, **Certificate design** (logo, watermark, stamp, signature draw/upload, title select, live preview), save & publish; Students (`/products/:id/course/students`).
- **Bulk upload** (`/products/bulk`): Digital or Physical (type locked once rows exist), ≤50 rows, spreadsheet rows with required fields inline and optional groups in modal, cover photos matched by file name, optional free sample, free checkbox, restore autosave, create 3 at a time via existing endpoints (drafts or publish; first publish → pending_review). Locked types show “turn it on in Store settings”.
- Quality: duplicate-listing warning, title/class mismatch, course-on-physical, single-image warning (non-blocking → `needs_review`); admin approve / ask-fix → notification `listing_fix_requested`.
- Scheduled products go live by cron (waits for active store) with notifications.
- Rules in `priceRules.ts` / `price-rules.util.ts`; zero stock needs confirmation.

### 6.4 Inventory (physical)
Stat cards act as filters (low/out/in/unlimited), sortable (name/price/stock/status), URL state, **−/+ stock buttons**, sticky unsaved-changes bar (Save/Discard, leave guard), per-product **low-stock limit** (0–1000, default 10), **stock history** (last 20), CSV export honouring filters, bulk stock set/add/subtract (`PATCH /api/products/stock/bulk`).

### 6.5 Orders
Tabs **Needs action / Shipped / Delivered / Completed / Cancelled / All** with counts; ship-by urgency sort and badges; table → cards on phones; copyable short order id; order modal (items, variant current SKU, buyer phone real, cancelled-by-buyer reason, gift note, PO/net terms), process/ship (courier booking locked to the quoted courier when couriers are on), **Mark paid** for COD per package (only when seller collects), **Free claims card** (buyer, product, date), print orders (`/orders/print`), `?buyer=` filter, `?q=` search.

### 6.6 Returns & refunds
One list (`/returns`) merging item returns + refund requests: stats (open, overdue, 30-day return rate ≥10 orders else “Not enough data”, refunded 30 d), respond-by pills, **Return drawer** (items, photos, digital “Downloaded yes/no”, timeline, Approve/Reject (reason ≥10), Mark received, Mark replacement). Approve/reject call existing `PUT /api/orders/return-action/:id` or `PATCH /api/refund-request/:id/approve|reject`.

### 6.7 Customers, Students, Followers
- **Customers** (`/customer/list`): masked email/phone, sort/search (phone formats), KPIs, detail panel (orders, repeat badge, existing chat thread), private note + tags (≤5), owner’s own buyer account excluded; seller can never edit a buyer.
- **Students** (digital/course stores): roster aggregated over paid + free-claim orders, progress %, status chips (not started / in progress / completed / inactive 14 d), product filter, drawer with lesson checklist/downloads/order numbers, **Message student** (`POST /api/messaging/seller/start`), CSV export (masked email).
- Followers tab.

### 6.8 Messaging, reviews, questions, quotes
Inbox (`?conv=`), reviews list + reply (seller can only **flag**, admin removes; “Flagged by Edudeen”), product Q&A, quotes (PO / net terms), response-rate stats.

### 6.9 Marketing
Discounts/coupons (scope, start, per-customer, first order, visibility), gift cards, loyalty program (disabled automatically if plan loses it), **Platform Sales** (apply products per campaign), **Promotions** (paid placement request: product picker, date range, price preview; admin approves; cancel refunds pro-rata), subscriptions, email campaigns (plan-gated, AI), KPIs, join campaigns.

### 6.10 Finance (`/finance`, one page)
Hero tiles (Available, Clearing + earliest release, Open-order estimate, Commission owed) each linking to filtered lists; next payout (computed from schedule); **monthly statement** (prev/next, vs last month, CSV/PDF download `GET /api/finance/:storeId/earnings-statement/download?format=csv|pdf`); transactions; payout method card (add: **full number encrypted**, last-4 shown) + payout history; collapsible “How fees work” from platform fees config; **fee estimate** `GET /api/finance/:storeId/fee-estimate?price&type`. COD commission debit nets off later sales. Wallets per currency.

### 6.11 Plan & Billing
Current plan card, trial/renewal, comparison table (limits only), Choose/Upgrade/Downgrade, yearly price + `≈ Rs`, usage meters (active promotions, AI credits, amber ≥80%, red at 100%), **Buy more credits** (add-ons catalog), 3DS confirmation, plan-expired/past_due messaging. `GET /api/platform-plans/:storeId` (200/null when none), `free-trial-eligibility`.

### 6.12 Store builder / Customize store
ONE draft/publish bar: store page (name, tagline, description, logo, cover, aboutBio, educator profile), banner style/accent, **Store highlights** (featured ≤8 search/order, toggles for New arrivals / Best sellers), preview (phone/desktop), Discard / Save draft / Publish (transaction; buyers see only on publish), pages, blog, theme preview `/store/:id/theme-preview/:themeId`, live preview, store settings (name, ships-from, delivery fee, gift wrap, deliveryDays, COD toggle, return policy, product types), categories/collections/bundles tabs, announcement.

### 6.13 Analytics (plan-gated tabs; locked card otherwise)
Overview (10 KPIs, PKT range presets + custom, compare, charts with compact ticks), **Visits + conversion + sources + search terms** (Pro), **Product performance table** (revenue/orders/views/conversion/free claims, CSV), **Free→Paid conversion** (7/30/90), Store Health (`GET /api/store/:storeId/health?range=30|90`: late dispatch ≤10%, return rate ≤10%, response rate ≥90%, first reply ≤24 h, rating ≥4.0, listings sent back).

### 6.14 SEO & AI Studio
SEO (`/api/store/:storeId/seo/*`): store/product SEO, audit, redirects, canonical rules, analytics, search-console integrations, AI SEO (plan-gated). **AI Studio** (`/api/ai-studio`, `/api/ai/seller/:storeId`): listing writer, pricing suggestions, content, SEO, email campaigns, moderation, translate, receipt OCR, quiz/worksheet tool + draft digital product (pdf-lib), covers, help-bot, ask-data, COD risk, review summary, insights; credit wallet; disabled when AI not configured; kill switches in `aiConfig`.

### 6.15 Other
Notifications page (same panel, seller topics incl. Payouts & Earnings, no WhatsApp/SMS), integrations, activity log (security alerts), account settings (photo saves immediately, change password stores new tokens), delete account (blocked with open orders / pending payouts / non-zero wallet), health, loyalty, loyalty members, shipping page (zones read, delivery days), AI credits in sidebar, “Growth tools” group collapse, sidebar by `productTypes`.

---

## 7. ADMIN (web; suggested light mobile)
**Web admin sidebar:** Overview/analytics, Users (+ force logout API), Moderation, Activity log, **Messages hub** (support chat, contact form, buyer-seller conversations), Store approvals (legacy), Refunds, Shipping zones (+ weight rate table, couriers card), Picks, Learning paths, App slides, Orders, Marketplace (listings review: approve/send back/bulk publish/test flag/needs-review, featured sellers pins), Categories (tree), Platform plans (+ give free access), Finance (payouts queue + “Pay to”, reconciliation, balances, failed credits, held FX), Premium (plans, payments, platform offer, grant/revoke), **Payment proofs**, FX settings, Commission rules (legacy), Announcements, Banners (placements, draft/schedule), Home cards, FAQs, Contact, Chat, Testimonials, **Platform config** (7 accordions: Maintenance, AI, Email, Manual bank/payment account, Homepage/About/legal + contact + Urdu, Referral, Social; plus Platform fees, COD, payout, FX, chatbot, become-a-seller page), Marketing (campaigns, subsidy cap, Mega Sale backgrounds), Settings, **Collaboration** (staff team, roles & rights, tasks, approvals, notes, activity, security), SEO (landing pages, sitemap, redirects, monitoring, integrations), AI Studio admin, Exports (CSV: users, orders, listings, payment proofs, activity).
**Security model:** staff default-deny, route→permission rules, two-person approvals (payout, refund, payment-proof; limits per currency), IP allow-list + working hours, access expiry, TOTP/e-mail code, password re-auth for money routes, audit log (awaited), sensitive reads audited, `*.export` rights separate.
**Inline site editor** (Edit mode with password re-auth) for banners, hero, trust, about, legal, FAQs, categories, social, app links, contact, seller page.
**Mobile admin suggestion:** push + one-tap approve/reject for payment proofs, payouts, refunds, listings; chat inbox; pending counts (`GET /api/admin/pending-counts`); badges via `useAdminBadges`.

---

## 8. Notifications catalogue
Buyer: order placed / shipped / delivered / payment received / bank proof approved/rejected (link `/account/orders/:id`), return & refund requested/approved/rejected, review replied, support reply (`/account/dashboard?openChat=1`), wishlist price-drop/back-in-stock, cart reminders, referral, Premium (expiry reminders, coupon), campaign end, scheduled/published product, course reminders.
Seller: order placed (with link), return requested, refund requested, review received, low stock / out of stock (>10 line crossing, link inventory), trial ending (3 days) / ended, payment failed, plan ended, promotion/banner status, listing in review / scheduled / published / fix requested, payout updates, campaign end “continue your sale?”.
Admin: activity-log alerts, credit job failures, listing edit/quality, support escalations (Messages badge).
Channels: **in-app (live)**, **push (needs Firebase keys)**, **email (needs Brevo/SMTP)**, WhatsApp/SMS (locked “coming soon”).

---

## 9. API reference by module (all under `/api`)
| Module | Prefix(es) |
|---|---|
| Auth | `auth` (register, login, social-login, refresh, resend-otp, verifyOtp, forgot-password, reset-password, become-seller, switch-to-buyer, create-buyer-account, logout, getprofile), `auth/phone` |
| Users | `users` (profile, change-password, DELETE profile) |
| Address / Children | `address`, `children` |
| Catalogue | `products` (+ bestsellers, products-by-category, compare, stock/bulk, bulk-offers, duplicate/:id, visibility/:id, store/:id/storefront-sections), `product variants`, `categories` (category-tree), `attributes`, `collections`, `public/collections`, `search`, `learning-paths`, `bundles/public` |
| Content | `banners`, `spotlight`, `home-cards`, `announcements`, `faqs`, `testimonials`, `onboarding-slides`, `newsletter`, `contact`, `platform-config` (public, maintenance), `public/store-banners|store-blog|store-pages|store-theme|marketing` |
| Commerce | `cart` (buy-now), `checkout` (delivery-info, gift-options, admin/shipping-rates), `payment` (manual-transfer/bank-details, hosted PK, webhooks), `orders` (by-checkout, seller-orders, seller-returns-all, return-action, mark-paid, download-zip, resend-download-link, seller-free-claims), `refund-request`, `rating`, `couriers`, `exchange-rate` |
| Money | `finance`, `premium`, `platform-plans` (+addons, admin/grant, free-trial-eligibility), `stripe-connect` (onboarding/status only), `commission-rules` (legacy), `gift-cards`, `discounts`, `loyalty`, `promotions`, `marketing` |
| Engagement | `messaging`, `notifications`, `chatbot`, `wishlist-share`, `referrals`, `retention`, `analytics/view` |
| Seller | `store`, `store-theme`, `store-banner`, `store-blog`, `store-pages`, `inventory`, `seller/analytics`, `store/:storeId/seo/*`, `courses` (learn, mine, certificates, seller roster/students), `ai`, `ai-studio`, `upload` (file, private-file, product-video), `media-library` |
| Admin | `admin/*` (analytics, users, orders, marketplace, finance, premium, ai-studio, config, marketing, promotions, learning-paths, exports, pending-counts, store-lookup, reauth, staff, chat, fx, activity-log, seo…) |
| Realtime | socket.io `/realtime`, notifications gateway |
| Other | `health`, Swagger only if not production or `ENABLE_SWAGGER=true`, `/seo-render/*`, `robots.txt`, `sitemap*.xml` |
Response shape: `{success, data, ...}`; list endpoints paginate (`limit` max usually 50, browse 100).

---

## 10. Mobile-specific build guidance
- **Stack:** Flutter or React Native (Expo). REST + JWT; secure storage; request cache with quiet refresh; global Idempotency-Key for payment calls.
- **Navigation (buyer):** tabs Home | Browse/Learn | Cart | Library | Account. Seller mode = separate tab set or separate app flavour (Dashboard | Orders | Products | Messages | More).
- **Deep links:** `/product/:slug`, `/shop/:slug`, `/course/:slug`, `/certificates/:code`, `/account/orders/:id`, `/wishlist/shared/:token`, `/bundles/:slug`, `/picks/:slug`, `/learning-paths/:slug`, `/?category=`, `/?campaign=`; notification `data.link` values.
- **Push:** FCM token registration endpoint must be confirmed/added; Firebase keys are an owner TODO.
- **Downloads:** signed expiring URLs → download manager; ZIP bundle link; PDF viewer for preview; keep files in app sandbox (protection roadmap: watermark/preview).
- **Course player:** native video + YouTube/Vimeo embed; replicate watch rules (no seek ahead, lock next, inactivity pause); background audio off.
- **Certificates:** native PDF generation or image share (web uses window.print).
- **Uploads:** compress images, resumable large uploads (R2 via API proxy, 500 MB), progress + retry, camera for proof/photos.
- **Payments:** Stripe SDK (needs publishable key) for USD cards; PKR → bank proof/COD; handle 3DS; hosted PK gateway via in-app browser + return deep link `payment/pk-return`.
- **Offline:** cache home/categories/product pages read-only; queue nothing money-related offline.
- **Accessibility/UX:** 44 px tap targets, RTL mirroring, Urdu font, no hover-only actions (hover popups → long-press/menu), skeleton loaders, safe-area padding, chat bubble must avoid wizards/checkout forms.
- **Privacy:** masked contact info for sellers, never show ObjectIds, never show other users’ data; no fabricated stats (stats blocks hidden below thresholds).
- **Store compliance:** privacy policy URL, **account-deletion URL** (`/delete-account`) + in-app deletion, app-promo hidden until live.

---

## 11. RETIRED — do NOT build
POS; Educational product type (migrated to Digital); Live classes/webinars (code + DB data removed); Seller business verification/KYC step (stores go live at once; Admin “Store approvals” only for legacy); Seller direct bank transfer (410); Marketplace page (`/marketplace`; home is the only shop; `/c/:slug` and `/search` redirect); Shop-by-grade tiles, Free-resources shelf, app-notify strip, “Why buyers choose Edudeen” blocks, recently-viewed on home; buyer “Free sample” button; edit-review for live listings; per-plan product limit; admin create-admin route; admin password reset by e-mail; Commission Rules / per-plan fee (legacy); `educationLevel` taxonomy UI (legacy fallback only); “Courses & Live Classes” category (hidden by 0-count; rename script `rename:courses-category` not run); WhatsApp chat bridge.

---

## 12. Known gaps, open issues, roadmap
**Not exercised in tests / unverified:** real Stripe card + webhooks, real e-mails (SMTP/Brevo), real Cloudinary/R2 uploads, Google/Apple/Facebook login, Firebase push, AI Studio with real Anthropic key, course/classroom flows & certificates in browser, subscription billing, real courier APIs, most recent UI work “NOT browser-tested”. No frontend automated test suite (manual Playwright harness); lint has pre-existing react-hooks errors.
**Feature gaps (from CLAUDE.md §11/§10):** Pakistani gateways (JazzCash/Easypaisa/Safepay) env-gated unverified; WhatsApp/SMS notifications (locked); courier integration TCS/Leopards/PostEx (adapters `TODO(owner)`); digital-file protection (watermark/PDF preview/virus scan); custom domain polish; CSV bulk import polish; coupons per grade/bundle; **parent/school accounts & bulk purchase**; wishlist price-drop polish; Q&A moderation; invoices/tax; **mobile apps**; Sentry monitoring (optional env); backups/runbook (`backup:db`, `docs/RUNBOOK.md`); accessibility audit; frontend E2E + CI.
**Open issues worth knowing:** HttpOnly cookies + CSRF + CSP not done; SEO is bot-prerender only (no SSR; home perf Lighthouse <85); Urdu is a DOM translator (sub-category/user text English); API throttle; Cloudinary lesson links never expire; free products show Premium rules edge cases; “Class N complete set” page not built; order-return dialog not structured; seller cancellations not stored; COD cash remittance reconciled by hand; refund/payout aging view missing; force-logout web button missing; campaign subsidy cap soft; coupon re-check after revoke; 20k-enrolment roster cap; Store Settings instant-save vs draft overwrite; no live-class anything.
**AI roadmap (§12):** receipt OCR (built advisory), semantic search + recommendations, auto-tagging from PDFs, listing translation, RAG support chatbot + seller assistant, moderation, review summaries (built), worksheet/quiz generator (built), AI tutor, seller insights/forecasting, order fraud/COD risk (built).
**Pre-existing failing specs** exist (checkout subtotal, unified-cart, wishlist, orders digital-delivery/fulfillment-mode, payment.free-checkout, product-create-variant coverStyle) — not from app work.

---

## 13. Environment, owner TODOs, release checklist
**API env:** `JWT_SECRET`, `MONGO_URI`, `REDIS_URL`, Stripe keys + webhook secret, `CLOUDINARY_*`, `R2_ACCOUNT_ID/ACCESS_KEY_ID/SECRET_ACCESS_KEY/BUCKET` (+`R2_ENDPOINT`, `R2_REGION`; B2 compatible), SMTP/Brevo, `ANTHROPIC_API_KEY`, `SEO_TOKEN_ENCRYPTION_KEY` (never change), `PAYOUT_ENCRYPTION_KEY`, `GOOGLE_CLIENT_ID/SECRET`, `FACEBOOK_APP_ID/SECRET`, `WEB_APP_URL=https://edudeen.com`, `ADMIN_ORIGINS`, `COURIER_DELIVERY_ENABLED`, `ENABLE_SWAGGER`, `TRUST_PROXY`, `VISIT_HASH_SECRET`, `PUBLIC_FREE_SAMPLE`, `PUBLIC_ASSET_HOSTS`, `SENTRY_DSN`, Voyage key for embeddings, Firebase keys, JazzCash/Easypaisa/courier keys.
**Web env:** `VITE_API_URL`, `VITE_GOOGLE_CLIENT_ID`, `VITE_STRIPE_PUBLISHABLE_KEY` (**missing → card disabled**), `VITE_APP_LIVE`, `VITE_BUNDLES_ENABLED`, `VITE_GOOGLE_PLAY_URL`, `VITE_APP_STORE_URL`, `VITE_SENTRY_DSN`.
**Deploy order:** push both repos (terminal cannot push — user uses GitHub Desktop); **API first, then web**.
**Owner TODOs:** set USD→PKR in FX Settings; add shipping zones; enable Manual bank transfer / COD and fill **Platform payment account**; set Platform fees (digital/physical, owner plan = 10%); `ADMIN_ORIGINS` if separate admin domain; check commission-rules unique index duplicates before deploy; scripts NOT yet run on live: `report:needs-review`, `fix:skus`, `fix:slugs`, `backfill:pdf-pages`, `rename:courses-category`, `admin:reset-password`, `seed` Islamic Accessories; give `*.export` rights carefully; sandbox keys for gateways/couriers; WhatsApp templates; Play Store/App Store public links (Admin → Homepage content).
**Release checklist for the app:** store accounts, privacy + deletion URLs, Stripe key, Google client IDs per platform, FCM keys, deep-link domains, QA per role (buyer/seller/admin), regression pass, test with maintenance 503, Urdu/RTL, 360/390/768 widths, low-end Android performance, then flip `VITE_APP_LIVE=true` on web to show app promos/QR.

---

## 14. Suggested delivery phases
1. **Foundation:** auth, platform config, maintenance, i18n/RTL, networking layer, realtime, notifications list.
2. **Buyer core:** home, browse/search/filters, product page, store page, cart/wishlist, checkout (COD, bank proof, free; card), orders, address book.
3. **Buyer learning:** library/downloads, course player, certificates, children, premium, referrals, returns/refunds, reviews, messaging, chatbot/support.
4. **Seller core:** dashboard, orders, products list + wizard, inventory, messaging, notifications.
5. **Seller advanced:** finance, plan & billing, marketing, returns drawer, customers/students, course builder, analytics/health, store builder, AI Studio, SEO.
6. **Admin lite (optional):** approvals (payment proofs, payouts, refunds, listings), chat, pending counts.
7. **Hardening:** push, deep links, performance, accessibility, store submission.


---

# PART C - API ENDPOINT APPENDIX

# Edudeen API - Endpoint Appendix (auto-extracted from NestJS controllers)

Base URL: https://api.edudeen.com  |  all routes start with /api (prefix below already includes it). Auth: Bearer JWT unless public. Response shape usually {success, data}.


## [activity-log\activity-log.controller.ts] /api/activity-log
- GET /api/activity-log/:storeId
- GET /api/activity-log/:storeId/stats
- GET /api/activity-log/:storeId/export

## [activity-log\admin-activity-log.controller.ts] /api/admin/activity-log
- GET /api/admin/activity-log
- GET /api/admin/activity-log/export

## [address\address.controller.ts] /address, api/address
- POST /address, api/address/add-address
- POST /address, api/address/update-address
- GET /address, api/address/get-address-by-id/:addressId
- GET /address, api/address/getMyAddresses
- GET /address, api/address/getDefaultAddress
- PATCH /address, api/address/setDefaultAddress/:addressId
- DELETE /address, api/address/delete-address/:addressId

## [admin-analytics\admin-analytics.controller.ts] /api/admin/analytics
- GET /api/admin/analytics/overview
- GET /api/admin/analytics/revenue-over-time
- GET /api/admin/analytics/revenue-breakdown
- GET /api/admin/analytics/sellers/top
- GET /api/admin/analytics/sellers/performance
- GET /api/admin/analytics/sellers/registration-trends
- GET /api/admin/analytics/customers
- GET /api/admin/analytics/products/top
- GET /api/admin/analytics/categories/top
- GET /api/admin/analytics/products/performance
- GET /api/admin/analytics/inventory-insights
- GET /api/admin/analytics/orders-over-time
- GET /api/admin/analytics/orders/status-breakdown
- GET /api/admin/analytics/payments/breakdown
- GET /api/admin/analytics/platform-metrics
- GET /api/admin/analytics/export

## [admin-announcements\admin-announcements.controller.ts] /api/admin/announcements
- POST /api/admin/announcements
- GET /api/admin/announcements
- PUT /api/admin/announcements/:id
- PATCH /api/admin/announcements/:id/status
- DELETE /api/admin/announcements/:id

## [admin-announcements\public-announcements.controller.ts] /api/announcements
- GET /api/announcements/active

## [admin-config\admin-config.controller.ts] /api/admin/platform-config
- GET /api/admin/platform-config
- PUT /api/admin/platform-config/feature-flags
- PUT /api/admin/platform-config/ai
- PUT /api/admin/platform-config/email
- PUT /api/admin/platform-config/placement-limits
- PUT /api/admin/platform-config/payout
- PUT /api/admin/platform-config/promotion-pricing
- PUT /api/admin/platform-config/manual-payment
- GET /api/admin/platform-config/platform-fees
- PUT /api/admin/platform-config/platform-fees
- GET /api/admin/platform-config/cod
- PUT /api/admin/platform-config/cod
- PUT /api/admin/platform-config/fx
- PUT /api/admin/platform-config/home-content
- PUT /api/admin/platform-config/seller-page
- PUT /api/admin/platform-config/social-links
- GET /api/admin/platform-config/chatbot
- PUT /api/admin/platform-config/chatbot
- PATCH /api/admin/platform-config/maintenance

## [admin-config\public-platform-config.controller.ts] /api/platform-config
- GET /api/platform-config/maintenance
- GET /api/platform-config/public

## [admin-exports\admin-exports.controller.ts] /api/admin/exports
- GET /api/admin/exports/users
- GET /api/admin/exports/orders
- GET /api/admin/exports/listings
- GET /api/admin/exports/payment-proofs

## [admin-finance\admin-finance.controller.ts] /api/admin/finance
- GET /api/admin/finance/overview
- GET /api/admin/finance/revenue-over-time
- GET /api/admin/finance/commission-over-time
- GET /api/admin/finance/reconciliation
- GET /api/admin/finance/reconciliation/history
- GET /api/admin/finance/fx-exposure
- GET /api/admin/finance/sellers/balances
- GET /api/admin/finance/sellers/:storeId
- GET /api/admin/finance/sellers/:storeId/transactions
- POST /api/admin/finance/sellers/:storeId/payouts/manual
- GET /api/admin/finance/credit-jobs
- POST /api/admin/finance/credit-jobs/:id/retry
- GET /api/admin/finance/transactions
- GET /api/admin/finance/payouts
- GET /api/admin/finance/payouts/:payoutId/destination
- PATCH /api/admin/finance/payouts/:payoutId/approve
- PATCH /api/admin/finance/payouts/:payoutId/reject
- PATCH /api/admin/finance/payouts/:payoutId/retry
- POST /api/admin/finance/process-clearing
- POST /api/admin/finance/process-scheduled-payouts
- GET /api/admin/finance/monthly-settlement
- POST /api/admin/finance/monthly-settlement/run
- GET /api/admin/finance/payout-methods/pending-verification
- PATCH /api/admin/finance/sellers/:storeId/payout-methods/:methodId/verify
- GET /api/admin/finance/reports/refunds
- GET /api/admin/finance/reports/tax
- GET /api/admin/finance/reports/settlement
- GET /api/admin/finance/reports/monthly
- GET /api/admin/finance/export

## [admin-marketing\admin-marketing.controller.ts] /api/admin/marketing
- POST /api/admin/marketing/campaigns
- GET /api/admin/marketing/campaigns
- PUT /api/admin/marketing/campaigns/:id
- PATCH /api/admin/marketing/campaigns/:id/status
- DELETE /api/admin/marketing/campaigns/:id
- POST /api/admin/marketing/coupons
- GET /api/admin/marketing/coupons
- PATCH /api/admin/marketing/coupons/:id
- DELETE /api/admin/marketing/coupons/:id

## [admin-marketplace\admin-marketplace.controller.ts] /api/admin/marketplace
- GET /api/admin/marketplace/stats
- GET /api/admin/marketplace/listings
- PATCH /api/admin/marketplace/listings/:id/feature
- PATCH /api/admin/marketplace/listings/:id/test
- PATCH /api/admin/marketplace/listings/:id/trust
- PATCH /api/admin/marketplace/listings/:id/remove
- GET /api/admin/marketplace/listings/review/count
- GET /api/admin/marketplace/listings/:id/review
- PATCH /api/admin/marketplace/listings/:id/approve
- PATCH /api/admin/marketplace/listings/:id/reject
- PATCH /api/admin/marketplace/listings/:id/quality/approve
- PATCH /api/admin/marketplace/listings/:id/quality/ask-fix
- PATCH /api/admin/marketplace/stores/:id/badge
- PATCH /api/admin/marketplace/stores/:id/fulfillment-mode
- GET /api/admin/marketplace/stores/featured
- PATCH /api/admin/marketplace/stores/:id/featured
- GET /api/admin/marketplace/leads
- GET /api/admin/marketplace/leads/:id
- PATCH /api/admin/marketplace/leads/:id/approve
- PATCH /api/admin/marketplace/leads/:id/reject
- DELETE /api/admin/marketplace/leads/:id

## [admin-moderation\admin-moderation.controller.ts] /api/admin/moderation
- GET /api/admin/moderation/stats
- GET /api/admin/moderation/queue
- PATCH /api/admin/moderation/:id/review
- PATCH /api/admin/moderation/:id/approve
- PATCH /api/admin/moderation/:id/remove

## [admin-orders\admin-orders.controller.ts] /api/admin/orders
- GET /api/admin/orders/manual/products
- POST /api/admin/orders/manual
- GET /api/admin/orders
- GET /api/admin/orders/:id

## [admin-pending\admin-pending.controller.ts] /api/admin/pending-counts
- GET /api/admin/pending-counts

## [admin-pending\store-lookup.controller.ts] /api/admin/store-lookup
- GET /api/admin/store-lookup

## [admin-reauth\admin-reauth.controller.ts] /api/admin/reauth
- POST /api/admin/reauth/verify-password

## [admin-users\admin-users.controller.ts] /api/admin/users
- GET /api/admin/users/stats
- GET /api/admin/users
- GET /api/admin/users/:role/:id
- PATCH /api/admin/users/:role/:id/suspend
- PATCH /api/admin/users/:role/:id/force-logout
- PATCH /api/admin/users/:role/:id/unsuspend

## [ai-studio\admin-ai-studio.controller.ts] /api/admin/ai-studio
- GET /api/admin/ai-studio/overview
- GET /api/admin/ai-studio/generations
- GET /api/admin/ai-studio/generations/:generationId
- GET /api/admin/ai-studio/wallets
- GET /api/admin/ai-studio/wallets/:storeId/ledger
- POST /api/admin/ai-studio/wallets/:storeId/adjust
- GET /api/admin/ai-studio/transactions
- POST /api/admin/ai-studio/platform/seo-booster/generate
- POST /api/admin/ai-studio/platform/email-campaigns/generate
- POST /api/admin/ai-studio/platform/image-enhancer/generate
- GET /api/admin/ai-studio/platform/image-enhancer/jobs/:jobId

## [ai-studio\ai-features.controller.ts] /api/ai
- GET /api/ai/features
- GET /api/ai/search
- POST /api/ai/assistant/chat
- GET /api/ai/reviews/summary/:productId
- POST /api/ai/voice-search

## [ai-studio\ai-features.controller.ts] /api/ai/seller/:storeId
- POST /api/ai/seller/:storeId/quiz
- POST /api/ai/seller/:storeId/sheet/html
- POST /api/ai/seller/:storeId/sheet/save-as-product
- POST /api/ai/seller/:storeId/quiz/audio
- GET /api/ai/seller/:storeId/insights/settings
- PUT /api/ai/seller/:storeId/insights/settings
- POST /api/ai/seller/:storeId/translate
- POST /api/ai/seller/:storeId/translate/batch
- POST /api/ai/seller/:storeId/products/:productId/translate
- PUT /api/ai/seller/:storeId/products/:productId/urdu
- GET /api/ai/seller/:storeId/orders/:orderId/cod-risk
- POST /api/ai/seller/:storeId/reviews/:ratingId/reply-draft
- POST /api/ai/seller/:storeId/insights/weekly
- GET /api/ai/seller/:storeId/insights/latest
- POST /api/ai/seller/:storeId/help
- POST /api/ai/seller/:storeId/products/:productId/cover
- POST /api/ai/seller/:storeId/image-check
- GET /api/ai/seller/:storeId/worksheets/