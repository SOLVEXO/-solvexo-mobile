# Deep-link files for the web team (R2) - NOT deployed

Host both files on **edudeen.com and www.edudeen.com**, over HTTPS, with no
redirects, `Content-Type: application/json`:

| File | URL |
|---|---|
| `assetlinks.json` | `https://edudeen.com/.well-known/assetlinks.json` (and `www.`) |
| `apple-app-site-association` (no extension) | `https://edudeen.com/.well-known/apple-app-site-association` (and `www.`) |

## Values to fill / update
- **Android `sha256_cert_fingerprints`**: Play Console -> Setup -> App integrity ->
  App signing -> "SHA-256 certificate fingerprint" (app signing key) **and** the upload
  key (`keytool -list -v -keystore upload-keystore.jks`). Add the debug key only on a
  staging domain.
- **iOS `appIDs`**: `<TeamID>.<bundle id>`. Today `B43H8KM3XZ.com.solvexo.ios`. When the
  ids switch to Edudeen (see RELEASE_CHECKLIST R6) list **both** during the overlap.
- `package_name` / bundle id change the same way (R6).

## Paths the app opens (DeepLinkRouter)
`/product/:slug`, `/shop/:slug`, `/course/:slug`, `/certificates/:code`,
`/account/orders[/:id]`, `/wishlist/shared/:token`, `/bundles/:slug`, `/picks/:slug`,
`/learning-paths[/:slug]`, `/?category=`, `/?campaign=`.
Android cannot match on query strings, so `/` is claimed and the app falls back to Home
when there is no `category`/`campaign`. Any other path the app does not know returns
`false` from the router (the app stays where it is).

## Verify after hosting
- Android: `adb shell pm verify-app-links --re-verify com.solvexo.app` then
  `adb shell pm get-app-links com.solvexo.app` (expect `verified`).
- iOS: install a build, long-press a link in Notes -> "Open in Edudeen"; or
  `swcutil dl -d edudeen.com` on a Mac.
- Cold start: kill the app, tap `https://edudeen.com/course/<slug>` -> splash -> course.
