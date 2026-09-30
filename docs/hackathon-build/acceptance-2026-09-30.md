# StudyLoop acceptance and update record — September 30, 2026

The user authorized fixes and updates to the existing GitHub repository and Devpost project after the original read-only checklist. This record separates current observations from historical device evidence.

## Next Gen competition path

| Item | Status and evidence | Failure condition / remaining uncertainty |
| --- | --- | --- |
| Official entry | Devpost API reports `published`, submitted to RevenueCat Shipaton 2026 at `2026-09-10T00:13:23.183-04:00`; https://devpost.com/software/studyloop-jnw4rv | A draft or missing submission would fail. Existing submission confirmed; private award/form answers are not returned by this API. |
| Deadline | Live Devpost dates: `2026-10-01T06:45:00Z`, October 1 at 14:45 China Standard Time; phase `submissions_open` | Missing the official deadline would fail. |
| Student route | Live submission requirements explicitly permit video plus public source instead of a store listing for Next Gen | Student/academic email and applicable consent remain private form checks; do not invent or publish these values. |
| Source and license | Public `main` verified at `c835e095d85665fbbf20d6ce01c3c6892d512a5b`; repository https://github.com/Zzy-min/studyloop; tracked `LICENSE` | Missing public source or license would fail. |
| Static analysis | September 30 `flutter analyze --no-pub`: no issues | Analyzer errors would fail. Raw local log: `outputs/analyze-20260930.log`. |
| Tests | September 30 `flutter test --no-pub -r compact`: 90 passed | Any failing test would fail. Raw local log: `outputs/tests-20260930.log`. |
| Real screenshots | Public gallery directly shows September 28 home-action, start-card and focus-timer images, alongside older home/history images; local files in `submission-assets/` are 1179×2556 | Synthetic HTML screenshots, missing dimensions or device frames would fail. Public evidence screenshot: `outputs/devpost-gallery-20260930.jpg`. |
| App icon | `submission-assets/studyloop-app-icon-1024.png`, 1024×1024 | Missing icon or wrong dimensions would fail. |
| Public demo | YouTube Studio confirmed September 30 public publication of https://www.youtube.com/watch?v=wFz6Qis-V9M (1:33). Devpost API and visible iframe confirm this replacement. Local edit: `submission-assets/studyloop-demo-20260930.mp4` | Direct YouTube watch-page retrieval hit an unusual-traffic screen. Publication is confirmed; the edit combines recordings and labeled screenshots, not an uninterrupted new recording. |
| Secret hygiene | No tracked or historical `.revenuecat.local.json`, `.env`, `key.properties`, JKS or keystore paths; current tracked-content scan found zero matches for selected secret patterns | This is a scoped scan, not a proof that every possible credential format is absent. |

## Product and RevenueCat evidence

| Item | Evidence | Remaining uncertainty / failure condition |
| --- | --- | --- |
| Five barriers and minimum action | Real device home/card screenshots; domain and widget tests included in the passing suite | The earlier long recording stalled during task entry and is not a complete demonstration. |
| Honest timer and reflection | September 28 device screenshots `studyloop-final-focus-check.png`, `studyloop-final-reflect-check.png`, `studyloop-final-summary-check.png`; timer and persistence tests | Current full uninterrupted device recording still needs completion. |
| Skip reflection | `lib/presentation/screens/reflection_screen.dart` passes null difficulty, focus and mood; `test/domain/reflection_skip_and_null_ratings_test.dart` passes | Fabricating scores on skip would fail. This is code/test evidence, not a fresh database dump. |
| Local insights | `DriftInsightsRepository` reads persisted records, calculates date ranges and filters nullable ratings; recorded device Insights shows an honest insufficient-data state | Do not claim that this recording demonstrates an unlocked statistical pattern. |
| Free loop without credentials | Test suite exercises fake/unknown entitlement paths; README documents a credential-free debug build | A fresh credential-free device installation was not performed in this continuation. |
| SDK and Test Store | `purchases_flutter` integration; historical device purchase, PRO persistence and restore evidence in `handoff.md` | September 28 Pro screenshots show the paywall and Test Store disclosure, not proof of a successful new purchase or restore. No production billing is claimed. |
| Current installed UI | September 30 vivo screenshot `outputs/current-valid-20260930.png` shows StudyLoop home; ADB identifies vivo V2458A | USB repeatedly disconnects; a connected device alone does not prove the complete flow. |

## Separate store-release path

The official Next Gen requirements do not require a paid developer account or production store listing. The following remain store-release gates, independent of the verified competition entry:

- Production signing: `android/key.properties` is absent. Do not manufacture a signing identity or publish a debug-signed release.
- Play/RevenueCat production mapping: not verified; Test Store evidence does not establish production purchases.
- Protected AI gateway: source exists under `services/ai-gateway`; deployment is not verified. The demonstrated guidance is deterministic and local.
- Public privacy/support URLs: direct HTTP retrieval returned 200 for both proposed URLs, but both returned the identical personal-site fallback HTML (title `张子阳 的个人网站`), without StudyLoop text. HTTP 200 is not evidence that these policy/support pages are deployed. This remains a store-release gap.
- Play-track golden/bad paths: acceptance script exists in `docs/REAL_DEVICE_ACCEPTANCE.md`; no new Play-track evidence is claimed.

## Media provenance and handling

Use actual Android screen captures only. Trimming waits, cropping system status bars and adding explanatory captions do not create an App UI. Keep raw captures and private identifiers in ignored `outputs/`. Check the finished video for notifications, keyboard stalls, missing steps, duration and readability before public upload. A failed transfer is resumed locally; no partial file is publishable evidence.

The finished local edit decodes without errors and was visually checked at every shot. It uses September 28 home/history/insights recordings and task/card/timer/reflection/summary/Pro device screenshots. The final restored-PRO Settings screenshot is dated August 22 and labeled as historical evidence. The original core recording could not be fully transferred because of repeated USB/ADB disconnects; no partial capture is used. SHA-256 of the reviewed edit: `3433E7821BB8EC82AA2C2E2EDF5B2E0E1909FE98F0C09A502160BF4F3C622665`.

Current paywall copy confirms that all local history stays free. README and submission copy were corrected to describe Pro as three-month/all-time pattern comparisons, rather than paid access to history.
