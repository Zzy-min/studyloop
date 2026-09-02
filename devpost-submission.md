# Title

StudyLoop

## One-line Summary

A calm, offline-first Android companion that turns study-start friction into one small action, then helps students learn what actually works for them.

## Problem

Students often know what they need to study but still cannot begin. Conventional productivity tools start with plans, streaks, or long task lists, which can add pressure at the exact moment a student already feels overwhelmed, distracted, or exhausted.

## Solution

StudyLoop starts with one question: why can you not study right now? It then shrinks a real task into a specific, observable first action. A quiet study dog stays present while the student focuses, and a short, nonjudgmental reflection records what happened. After enough real sessions, StudyLoop reveals evidence-based patterns without turning the experience into a competition.

The complete immediate-help loop stays free. RevenueCat powers Pro access to longer history and deeper comparisons. Purchase, entitlement activation, cold-start persistence, and restore were verified with RevenueCat Test Store on a physical Android device.

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
- RevenueCat-powered Pro history with verified Test Store purchase and restore.
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

Current verified result: analysis reports no issues, all 88 tests pass, and the debug APK is created at `build/app/outputs/flutter-apk/app-debug.apk`.

The free study loop can be tested without credentials. RevenueCat Test Store credentials are intentionally not committed; the public demo video will show the verified purchase and restore lifecycle. The public repository will document how judges can review the billing integration without exposing a credential.

## Public Repository Link

https://github.com/Zzy-min/studyloop

## Demo Video

TODO: upload an unlisted or public YouTube/Vimeo video and add the URL. Maximum duration: 2:00.

Local raw device capture: `submission-assets/studyloop-demo-raw.mp4` (57 seconds, 1260x2800, no narration; SHA-256 `8630E59AB7118517CFC4313FCFC7C06C9B085D1E5FFA5C2567D35537E64D9287`). This is source footage, not the final public video.

### 120-second shot plan

- 0:00-0:12: Introduce the problem on the first screen and show the waiting study dog.
- 0:12-0:35: Choose an overload barrier, enter an exam calculation task, generate a start card, and reduce it once.
- 0:35-1:02: Start a focus session, end early, and complete the reflection without a failure label.
- 1:02-1:22: Show recent history and the transition from collecting records to one evidence-based observation.
- 1:22-1:50: Open Pro, complete a RevenueCat Test Store purchase, show the `PRO` state, then restore purchases.
- 1:50-2:00: Show the matching RevenueCat sandbox entitlement and close on the privacy-first value proposition.

Voiceover should be concise and factual. Use no copyrighted music, trademarks, or third-party footage.

## Screenshot Shot List

- App icon: `submission-assets/studyloop-app-icon-1024.png` (1024x1024).
- Primary screenshot: `submission-assets/studyloop-home-1179x2556.png` (1179x2556, no device frame).
- Secondary screenshot: `submission-assets/studyloop-history-1179x2556.png` (1179x2556, no device frame).
- Optional proof shots: start card, focus timer, reflection, Pro state, and RevenueCat sandbox transaction. Review each for personal information before upload.

## Submission Readiness Notes

- Live hackathon status: registered and submissions open.
- Deadline: October 1, 2026 at 06:45 UTC / 14:45 China Standard Time.
- Target category: Next Gen Award.
- Award selection: **Next Gen Award only**. Leave Peace Prize, Design Award, and every other optional award unselected.
- Next Gen does not require a Google Play listing or paid Google Play developer account; judging uses the demo video and public open-source repository.
- Current automated verification: no analysis issues and 88/88 tests passed.
- Current debug APK: 210,689,070 bytes; SHA-256 `3FFB4E239646198CCD8F7208936978C41F53E67469896543ACC4382DA5CAED5B`.
- Latest Test Store debug APK (September 2): 210,688,389 bytes; SHA-256 `958E54B4CC8E64D0EA52656CABB847F27A9342DFDB824EB43A18366A0FF35A1D`.
- Overflow-fixed Test Store debug APK: 210,690,315 bytes; SHA-256 `879C8C78CE7FC696FDBF760979B1664E484AC46BA3BD9D52849611A2A983DCB8`.
- Latest APK was signature-verified and installed successfully on vivo V2458A via non-streaming ADB. Cold launch rendered correctly, the companion input opened the device keyboard, local guidance responded without a crash, and the existing Test Store entitlement was visible as `PRO`. Automated ADB navigation could not reliably complete the entire task-to-timer path, so that path remains pending a direct-touch recording.
- The debug APK is for local demonstration only, not public distribution. Google Play production signing and listing are outside this Next Gen submission gate.
- Public repository, video upload, and Devpost submission have not been performed.

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
- [ ] Public YouTube/Vimeo demo URL, maximum 2:00.
- [x] Student or academic email for Next Gen eligibility: `542513390653@zzuli.edu.cn`.
- [ ] Minor consent checkbox, if applicable.
- [ ] Confirm RevenueCat project ID. Provisional value from the dashboard URL: `2d675bce`.
- [x] Premium demonstration path: RevenueCat Test Store purchase and restore, permitted for Next Gen; no real charge.
- [x] Award selection: Next Gen Award only; leave every other award field blank.
- [ ] Confirm country field: China.
- [x] Codex session ID: `019fe0c9-270f-7402-90bf-7c1371e41ccf`.
- [ ] Final proofread and explicit approval before any Devpost submission.
