# Deep-link files for the web team (R2) - NOT deployed

Host both files on **edudeen.com and www.edudeen.com**, over HTTPS, with no
redirects, `Content-Type: application/json`:

| File | URL |
|---|---|
| `assetlinks.json` | `https://edudeen.com/.well-known/assetlinks.json` (and `www.`) |
| `apple-app-site-association` (no extension) | `https://edudeen.com/.well-known/apple-app-site-association` (and `www.`) |

**Redirect warning (checked 2026-11-23):** `https://edudeen.com/*` answers `308 -> https://www.edudeen.com/*`.
Apple does not follow redirects for `apple-app-site-association` and Android App Links
verification fails on redirects too. Either serve both `.well-known` files on the apex
**without** the redirect, or the apex entries (`applinks:edudeen.com` / host `edudeen.com`)
will simply not verify; `www` links still work.

## Values to fill / update
- **Android `sha256_cert_fingerprints`**: Play Console -> Setup -> App integrity ->
  App signing -> "SHA-256 certificate fingerprint" (app signing key) **and** the upload
  key (`keytool -list -v -keystore upload-keystore.jks`). Add the debug key only on a
  staging domain.
- **iOS `appIDs`**: `<TeamID>.<bundle id>`. `B43H8KM3XZ.com.edudeen.app` (team `B43H8KM3XZ`).
- `package_name` is `com.edudeen.app`.
- TODO: replace the `TODO_REPLACE_WITH_...` SHA-256 values in `assetlinks.json` with the release/Play app-signing SHA-256.

## Paths the app opens (DeepLinkRouter)
`/product/:slug`, `/shop/:slug`, `/course/:slug`, `/certificates/:code`,
`/account/orders[/:id]`, `/wishlist/shared/:token`, `/bundles/:slug`, `/picks/:slug`,
`/learning-paths[/:slug]`, `/?category=`, `/?campaign=`.
Android cannot match on query strings, so `/` is claimed and the app falls back to Home
when there is no `category`/`campaign`. Any other path the app does not know returns
`false` from the router (the app stays where it is).

## Verify after hosting
- Android: `adb shell pm verify-app-links --re-verify com.edudeen.app` then
  `adb shell pm get-app-links com.edudeen.app` (expect `verified`).
- iOS: install a build, long-press a link in Notes -> "Open in Edudeen"; or
  `swcutil dl -d edudeen.com` on a Mac.
- Cold start: kill the app, tap `https://edudeen.com/course/<slug>` -> splash -> course.
