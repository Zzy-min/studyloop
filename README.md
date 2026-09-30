# StudyLoop

A calm, offline-first Android companion for university students who know they need to study but cannot start.

StudyLoop asks why starting is hard, shrinks one task into a single observable action, keeps a small dog nearby, and later shows evidence-based patterns. The study loop and all local history stay free. Pro unlocks three-month and all-time pattern comparisons through RevenueCat, with the Test Store purchase and restore lifecycle verified on a physical Android device.

## Status

Next Gen Award entry with verified RevenueCat Test Store integration. The public repository, MIT license, image assets, and demo video are live. Submitted to RevenueCat Shipaton 2026 on Devpost.

## Run

```text
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

The core study loop runs without credentials. To exercise RevenueCat Test Store,
create a local `.revenuecat.local.json` from the documented configuration and
pass its test API key with `--dart-define`; never commit that file or key.

## Privacy

No account or cloud sync is required. Study notes stay in the on-device SQLite
database. The Next Gen demo uses deterministic local guidance. The repository
also contains an optional production-oriented AI gateway, but it is not deployed
or required for the submitted demo. Do not commit RevenueCat, DeepSeek, signing,
or service-account credentials.

## Next Gen Submission

StudyLoop is entering the RevenueCat Shipaton 2026 **Next Gen Award only**. This
category is evaluated through a public open-source repository and a demo video;
a Google Play production listing is not part of this submission path.

- App icon: `submission-assets/studyloop-app-icon-1024.png`
- Screenshots: `submission-assets/studyloop-*-1179x2556.png`
- Draft copy and checklist: `devpost-submission.md`
- License: `LICENSE`

See `docs/hackathon-build/handoff.md` for verification evidence and remaining gates.

Devpost project: https://devpost.com/software/studyloop-jnw4rv

Public demo (updated September 30, 93 seconds): https://www.youtube.com/watch?v=wFz6Qis-V9M

The edit combines real Android recordings and labeled September 28 device screenshots; its final restored-PRO screenshot is explicitly labeled historical August 22 evidence. It is not an uninterrupted new purchase/restore recording. See `docs/hackathon-build/acceptance-2026-09-30.md` for current checks and remaining store-release gaps.
