# StudyLoop local handoff

StudyLoop is a local-first Flutter Android companion that turns study-start friction into one deterministic action, then records an honest reflection. The complete immediate-help loop is free. RevenueCat Test Store now verifies the Pro purchase and restore lifecycle on a physical Android device.

## Verified story

- Immediate entry: launch asks “Why can’t you study right now?” with a waiting dog and no account.
- Task shrinking: five barriers, ordinary/severe tiredness, deterministic start cards, three reductions, then a smallest-action-is-enough message.
- Focus and rest: foreground-only timer with continue-or-save recovery; severe discomfort never starts a timer.
- Honest evidence: reflections store difficulty, focus, and three mood states; free insights appear only after three recent records.
- RevenueCat lifecycle: unknown never blocks free help; cancellation returns quietly; a real Test Store Monthly purchase and restore activate `pro`.

## How to run

```text
cd studyloop
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --release --no-pub
flutter install --release -d <android-serial>
```

For local Test Store verification only, create a gitignored `.revenuecat.local.json` with `REVENUECAT_API_KEY` and `REVENUECAT_ENTITLEMENT`, then run `flutter build apk --debug --dart-define-from-file=.revenuecat.local.json`. Never ship the Test Store key in a release build.

## Evidence

- Analyze: no issues.
- Tests: 38 passed, covering cards, rest/date policy, Drift singleton, timer pause, insights threshold, fake and real-adapter entitlement mapping, localization, Corgi chat, task-field focus, and first-run/rest/reduction/paywall widgets.
- Test Store debug APK: `build/app/outputs/flutter-apk/app-debug.apk` (211,216,700 bytes, SHA-256 63DE05B510831F9C56DEF0924139852AF9F00D026ACBDA94265B60A09EA2F7AC).
- Release APK: `build/app/outputs/flutter-apk/app-release.apk` (84,513,279 bytes, SHA-256 E2911C9CB3CA4DF6A77426AAC1058EDF998BD8AA656C289B652487D9B8B16493).
- Device: vivo V2458A / Android 16. Release install succeeded. The device serial is intentionally omitted from public materials.
- Screenshots: `outputs/device-home.png`, `outputs/device-settings.png`, `outputs/studyloop_release_keyboard_final.png`, `outputs/studyloop_history.png`.
- Release string scan: the exact local Test Store key, API-key environment name, emails, debug seed copy, and synthetic fixture labels are absent.
- Device flow: task entry, start-card generation and reduction, focus, early save, reflection, and history persistence completed on the physical device.
- Test Store flow: Monthly valid purchase completed; cold-start Settings showed `PRO`; restore retained `PRO`; Dashboard recorded the sandbox subscription and active `Pro` entitlement under offering `default`.
- Test Store screenshots: `outputs/device-revenuecat-purchased.png`, `outputs/device-settings-pro.png`, and `outputs/device-settings-restored.png`.

## AI and synthetic-data disclosure

- Runtime uses no generative AI. Start cards and insights are deterministic local rules.
- AI-assisted coding was used to implement and test the app.
- Debug builds may insert clearly labeled synthetic records. Release Settings does not expose seed/clear controls.

## Asset and dependency notes

- Dog states are original SVGs in `assets/dog_svg/`. Rive was scheduled as an upgrade and is not required for the current visual baseline.
- Application dependencies are pinned in `pubspec.lock`: Flutter 3.44.6, Dart 3.12.2, Riverpod, Drift, go_router, purchases_flutter, flutter_svg.
- No LICENSE file has been added yet; add one before a public repository is created.

## 120-second demo plan

1. 0–15s: cold start into the barrier question and waiting dog.
2. 15–40s: choose overload, enter one exam-calculation task, generate a card, reduce it.
3. 40–75s: start focus, end early, complete a nonjudgmental reflection.
4. 75–95s: show empty-to-three-record collection, then one free observation from labeled synthetic data in a debug build.
5. 95–120s: open Pro, complete the Test Store purchase, show the `PRO` badge, then briefly show the matching Dashboard sandbox transaction.

The vivo WeType process once reported a visible IME while rendering a transparent surface. Restarting only the input-method process recovered it without clearing keyboard data; the final Release verification shows the keyboard and correctly resized task page.

Local demo source footage is available at `submission-assets/studyloop-demo-raw.mp4` (57 seconds, 1260x2800). It is not uploaded and still needs narration/editing against the 120-second plan.

## Repository readiness

- A local Git repository has been initialized on `main`; no commit or remote exists yet.
- Do not push, create a remote, upload media, or submit to Devpost without a separate explicit confirmation.
- Public-source hygiene now excludes the local RevenueCat configuration, device outputs/XML, participant profile, build diary, and Devpost plugin state. A LICENSE choice and first-commit review remain pending.

## Known limitations

- The RevenueCat account email still needs confirmation; current Test Store SDK purchase and Dashboard evidence are functional.
- RevenueCat onboarding also created a legacy `studyloop_pro` entitlement. The app reads the separately configured `pro` entitlement; both currently reference Monthly. Removing the legacy entitlement is optional cleanup and requires a separately confirmed destructive Dashboard change.
- WeType may require an input-method process restart if the device again reports a visible IME without rendering its surface; the app now retries after route settlement and on field tap.
