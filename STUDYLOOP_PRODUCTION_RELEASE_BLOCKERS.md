# StudyLoop Production Release Blockers

Historical baseline: 2026-09-02. Current follow-up: 2026-09-30.

## Current scope and superseding observations

The owner reaffirmed the **Next Gen student competition only** scope. Live official requirements permit a demo video plus public source instead of a store listing and require no paid developer account. The production gates below must not be treated as competition failures.

- Academic email and repository were verified in the authenticated private Devpost submission; it remains `SUBMITTED`, 5/5 steps done. The email is not published in the repository.
- Owner-authorized upload key generation and local signed AAB verification are complete; see `docs/SIGNING_PREPARATION_2026-09-30.md`. Play App Signing enrollment is not claimed.
- Public bilingual privacy/support pages now render at `https://qling.it.com/studyloop/privacy/` and `https://qling.it.com/studyloop/support/`. App support text uses the existing public Gmail contact. Delivery of a support email is not verified.
- Production payment is not live: RevenueCat shows Test Store only; Play Console requires identity and phone verification and disables app creation. No production console writes or purchase were performed; these remain outside current competition scope.
- Remote AI is not configured. Review identified that disclosure acceptance is not enforced across every AI entrypoint; public policy now states this limitation. A consistent consent gate is required before enabling remote AI.
- Current analysis is clean; the earlier September 30 full suite passed 90 tests, and 7 affected localization/resilience tests passed after this support-copy edit.

Everything below is the retained September 2 store-release baseline, superseded where the current observations above differ.

## Release verdict

**FAIL - do not publish to production.** The local implementation and automated
checks are ready for account-backed verification, but an upload key, deployed
gateway, public site deployment, Google Play/RevenueCat production mapping, and
real-device evidence are still absent.

## P0 status

| Gate | Status | Evidence |
| --- | --- | --- |
| Non-Debug distributable signing | FAIL | `flutter build appbundle --release --no-pub` stops at `android/app/build.gradle.kts:41` because `android/key.properties` is absent. The release task now refuses Debug fallback. |
| Public privacy and support URLs | NOT VERIFIED | Source pages exist at `/studyloop/privacy/` and `/studyloop/support/`; deployment to `https://qling.it.com` was intentionally not performed. |
| Protected production AI gateway | NOT VERIFIED | Cloud Run source, tests and local type check pass; no Cloud Run service, Secret Manager secret, Play Integrity project link, service account, Firestore TTL policy, or production endpoint has been created. |
| Google Play and RevenueCat production billing | NOT VERIFIED | Target is monthly CNY 12.00, entitlement `pro`, offering `default`, package `$rc_monthly`; no external console write or Play test purchase was performed. |
| Real-device Golden/Bad Path | NOT VERIFIED | Acceptance script exists; no current device, Play-track build, purchase, or screen evidence was captured. |

## Local implementation

- `android/app/build.gradle.kts` requires every upload-keystore property for a
  release task and declares the official Play Integrity library. The ignored
  `android/play-integrity.properties` supplies only the linked Cloud project
  number; `android/play-integrity.properties.example` is safe to commit.
- The Android MethodChannel obtains a Play Integrity Standard API token. Flutter
  requests a short-lived gateway session before it calls `/v1/companion`; failure
  returns to the existing deterministic local companion.
- `services/ai-gateway` validates constrained request data, integrity verdicts,
  Play app certificate, licensed account and device integrity; it issues 15-minute
  sessions, rate-limits installation and IP hashes through Firestore, calls
  DeepSeek only from the server, and logs no request bodies or credentials.
- The existing personal website has source pages for the public policy and
  support email `zzy19812007@gmail.com`. The site build no longer relies on
  Google Fonts at build time.

## Automated evidence

| Check | Status | Result |
| --- | --- | --- |
| `flutter analyze` | PASS | No issues. |
| `flutter test` | PASS | 87 tests passed. |
| `flutter build apk --debug --no-pub` | PASS | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| Debug APK SHA-256 | INFO | Latest Test Store build: `958E54B4CC8E64D0EA52656CABB847F27A9342DFDB824EB43A18366A0FF35A1D` (210,688,389 bytes). This Debug artifact is not distributable. |
| `flutter build appbundle --release --no-pub` without key | PASS | Failed as designed: no `android/key.properties`; no Debug-signed release artifact produced. |
| Gateway `npm run build` | PASS | TypeScript check passed. |
| Gateway `npm test` | PASS | 3 tests passed: valid session, rejected integrity, session/rate-limit enforcement. |
| Website `npm test` | PASS | 15 tests passed. |
| Website `npm run build` | PASS | Static export produced both StudyLoop routes after removing build-time remote font fetches. |
| Source credential scan | PASS | No real provider, RevenueCat, session-signing, or keystore values found. Only `android/key.properties.example` placeholders remain. |

## Required owner inputs and approvals

1. Provide a secure location and recovery process for the upload-keystore
   passwords, then approve local upload-key generation and the first signed AAB.
2. Approve the target Google Cloud project, creation of the two Secret Manager
   secrets, required service-account IAM grants, Firestore TTL policy, and Cloud
   Run deployment.
3. Approve the website deployment that makes the two policy URLs public.
4. Approve Google Play App Signing enrollment, internal/closed track setup, and
   creation or mapping of `studyloop_pro_monthly` at CNY 12.00.
5. Approve the corresponding RevenueCat production app/product mapping and the
   controlled Play test purchase.

## Next verification commands

```powershell
flutter build appbundle --release --no-pub `
  --dart-define=REVENUECAT_API_KEY=... `
  --dart-define=STUDYLOOP_AI_GATEWAY_URL=https://YOUR_CLOUD_RUN_URL

keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

Follow `docs/PRODUCTION_CONSOLE_CONFIGURATION.md` for approved external steps
and `docs/REAL_DEVICE_ACCEPTANCE.md` for the final device evidence.

## Traceability note

`git status --short` shows every project file as untracked. Establish a reviewed
source-control baseline before handing a release artifact to another party.
