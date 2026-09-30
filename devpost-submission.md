# Title

StudyLoop

## One-line Summary

A calm, offline-first Android companion that turns study-start friction into one small action, then helps students learn what actually works for them.

## Problem

Students often know what they need to study but still cannot begin. Conventional productivity tools start with plans, streaks, or long task lists, which can add pressure at the exact moment a student already feels overwhelmed, distracted, or exhausted.

## Solution

StudyLoop starts with one question: why can you not study right now? It then shrinks a real task into a specific, observable first action. A quiet study dog stays present while the student focuses, and a short, nonjudgmental reflection records what happened. After enough real sessions, StudyLoop reveals evidence-based patterns without turning the experience into a competition.

The complete study loop and all local history stay free. RevenueCat powers Pro access to three-month and all-time pattern comparisons. Purchase, entitlement activation, cold-start persistence, and restore were verified with RevenueCat Test Store on a physical Android device.

## Why This Matters

Starting is often the hardest part of studying. StudyLoop is designed for that narrow but high-impact moment. It avoids accounts, cloud sync, punitive streaks, and medical claims. Study notes remain on the device, while severe discomfort leads to a rest suggestion instead of another timer.

## How We Used AI

AI-assisted development supported product shaping, implementation, test design, debugging, and submission preparation. The submitted Next Gen demo uses deterministic local guidance, so the core study loop remains fast, private, explainable, and available without a cloud model. A protected DeepSeek gateway exists as production-oriented source code but is not deployed or required for the submitted demo.

## How We Used Codex

Codex helped convert the product scope into a Flutter architecture and test plan, implement the Android app, diagnose a device-specific keyboard regression, integrate RevenueCat behind a typed entitlement repository, verify the Test Store purchase and restore lifecycle, scan the release artifact for secrets, and prepare the submission materials.

Codex session ID: `019fe0c9-270f-7402-90bf-7c1371e41ccf`

## Key Features

- Five study-start barriers with deterministic task shrinking.
- Ordinary-fatigue and severe-discomfort paths with a clear safety boundary.
- Foreground-only focus timer with continue-or-save recovery.
- Nonjudgmental reflection covering difficulty, focus, and emotional change.
- Local SQLite history, deletion, and evidence-based insights after three records.
- Six original study-dog states with no reward economy or punitive mechanics.
- RevenueCat-powered Pro comparisons with verified Test Store purchase and restore.
- English and Chinese interface support.

## Architecture

StudyLoop is an Android-only Flutter app using Riverpod for state, Drift/SQLite for local persistence, `go_router` for navigation, and `purchases_flutter` behind a typed `EntitlementRepository`. Free functionality does not depend on RevenueCat availability. Test Store credentials are supplied only through an ignored local configuration and are not committed. The app has no account system, analytics SDK, or cloud sync.

## Testing Instructions

Prerequisites: Flutter 3.44.6, Dart 3.12.2, Android SDK 36, JDK 21, and an Android device or emulator.

```text
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

Verified again on September 30, 2026: analysis reports no issues and all 90 tests pass. The September 28 Test Store debug APK is at `build/app/outputs/flutter-apk/app-debug.apk`.

The free study loop can be tested without credentials. RevenueCat Test Store credentials are intentionally not committed. The updated public video shows the current Pro paywall and explicitly labeled historical restored-PRO evidence; it does not show a newly completed purchase transaction.

## Public Repository Link

https://github.com/Zzy-min/studyloop

## Demo Video

Public YouTube demo: https://www.youtube.com/watch?v=wFz6Qis-V9M (92.90 seconds, updated September 30). Maximum duration: 2:00. YouTube Studio confirmed public publication; Devpost now embeds this video.

Final local edit: `submission-assets/studyloop-demo-20260930.mp4` (720×1600, SHA-256 `3433E7821BB8EC82AA2C2E2EDF5B2E0E1909FE98F0C09A502160BF4F3C622665`). Real recordings are combined with labeled real-device screenshots, and the final August 22 restored-PRO image is labeled historical evidence. This is a captioned edit, not an uninterrupted new purchase/restore recording.

Local raw device capture: `submission-assets/studyloop-demo-raw.mp4` (57 seconds, 1260x2800, no narration; SHA-256 `8630E59AB7118517CFC4313FCFC7C06C9B085D1E5FFA5C2567D35537E64D9287`). This is source footage, not the final public video.

September 28 real-device captures (kept in the ignored `outputs/` folder, not committed):

- `outputs/studyloop-demo-20260928.mp4` - 109.97s, 720x1600, home → Busy barrier → task entry with the on-device keyboard, ends on the task screen.
- `outputs/studyloop-demo-part2-20260928.mp4` - 91.07s, 720x1600, Records → Insights.
- Still frames for the task, start card, focus timer, reflection, summary and Pro screens are incorporated into the new public edit with explicit screenshot labels. The interrupted core-recording transfer is not used.

### Published 93-second timeline

- 0:00-0:08: Home and study barrier, real Android recording.
- 0:08-0:26: Calculus task and one small start, labeled device screenshots.
- 0:26-0:52: Focus, reflection and summary, labeled device screenshots.
- 0:52-1:13: Saved history and honest insufficient-data insights, real recording.
- 1:13-1:25: Current Pro paywall with RevenueCat Test Store disclosure.
- 1:25-1:33: Restored `PRO` Settings screenshot, explicitly labeled historical August 22 evidence.

The edit uses explanatory captions and no soundtrack or third-party footage.

## Screenshot Shot List

- App icon: `submission-assets/studyloop-app-icon-1024.png` (1024x1024).
- Already-public gallery images (September 1): `studyloop-home-1179x2556.png`, `studyloop-history-1179x2556.png` (both 1179x2556, no device frame).
- September 28 real-device screenshots, all 1179x2556 and captured without a device frame:
  - `studyloop-home-20260928-1179x2556.png` - fresh launch, no barrier selected yet.
  - `studyloop-home-action-20260928-1179x2556.png` - Busy barrier selected, primary action enabled.
  - `studyloop-card-20260928-1179x2556.png` - one small start, reduced to a single observable step.
  - `studyloop-focus-20260928-1179x2556.png` - focus timer running with the companion present.
- Proof shots kept for the video edit, not yet in the gallery: `outputs/studyloop-final-reflect-check.png`, `studyloop-records-20260928.png`, `studyloop-insights-final.png`, `studyloop-pro-final.png`, `studyloop-restore-result-20260928.png`. Review each for personal information before any upload.

## Submission Readiness Notes

- Live hackathon status: registered and submissions open.
- Devpost project: https://devpost.com/software/studyloop-jnw4rv (published and submitted to RevenueCat Shipaton 2026 on September 10, 2026).
- Deadline: October 1, 2026 at 06:45 UTC / 14:45 China Standard Time.
- Target category: Next Gen Award.
- Award selection: **Next Gen Award only**. Leave Peace Prize, Design Award, and every other optional award unselected.
- Next Gen does not require a Google Play listing or paid Google Play developer account; judging uses the demo video and public open-source repository.
- Current automated verification (September 30): no analysis issues and 90/90 tests passed.
- Current Test Store debug APK (September 28, rebuilt after the reflection-card localization fix): 210,693,080 bytes; SHA-256 `9E87170A7FAE0B2B9A671629825C4907E7E7972FE3D1C04BBB02181D1753518E`.
- Latest Test Store debug APK (September 2): 210,688,389 bytes; SHA-256 `958E54B4CC8E64D0EA52656CABB847F27A9342DFDB824EB43A18366A0FF35A1D`.
- Overflow-fixed Test Store debug APK: 210,690,315 bytes; SHA-256 `879C8C78CE7FC696FDBF760979B1664E484AC46BA3BD9D52849611A2A983DCB8`.
- Latest APK was signature-verified and installed successfully on vivo V2458A via non-streaming ADB. Cold launch rendered correctly, the companion input opened the device keyboard, local guidance responded without a crash, and the existing Test Store entitlement was visible as `PRO`. Automated ADB navigation could not reliably complete the entire task-to-timer path, so that path remains pending a direct-touch recording.
- The debug APK is for local demonstration only, not public distribution. Google Play production signing and listing are outside this Next Gen submission gate.
- The public repository and Devpost submission are live. On September 30 the public gallery was verified to contain the three September 28 home-action, start-card, and focus-timer screenshots alongside the older home/history images. The video was replaced with `wFz6Qis-V9M` and the Pro feature description was corrected to match the paywall.

## Known Limitations

- Android only; no iOS or web build is included.
- No backend, account, or cross-device sync.
- RevenueCat status can be unknown while offline; free functionality continues.
- The production DeepSeek gateway and Google Play billing path are not deployed; neither is claimed as part of the Next Gen demo runtime.
- A legacy RevenueCat entitlement named `studyloop_pro` remains in the dashboard. StudyLoop uses `pro`; deleting the legacy entitlement is optional and outside this submission draft.

## TODO Official Form Fields

- [x] Project name: StudyLoop.
- [x] Tagline/summary drafted.
- [x] App type: Android.
- [x] Includes 1024x1024 app icon.
- [x] Includes at least one 1179x2556 screenshot without a device frame.
- [x] Includes an MIT open-source license for the public repository.
- [x] Public repository URL: `https://github.com/Zzy-min/studyloop`.
- [x] Public YouTube demo URL: `https://www.youtube.com/watch?v=wFz6Qis-V9M` (93 seconds).
- [x] Devpost submitted project: `https://devpost.com/software/studyloop-jnw4rv`.
- [ ] Confirm the private student/academic email answer in the submitted Devpost form; do not publish it in this repository.
- [ ] Minor consent checkbox, if applicable.
- [x] RevenueCat Project ID confirmed from the authenticated Dashboard: `2d675bce`.
- [x] Premium demonstration path: RevenueCat Test Store purchase and restore, permitted for Next Gen; no real charge.
- [x] Award selection: Next Gen Award only; leave every other award field blank.
- [ ] Confirm country field: China.
- [x] Codex session ID: `019fe0c9-270f-7402-90bf-7c1371e41ccf`.
- [x] Verify the final Devpost gallery and new video embed after the authorized update.
