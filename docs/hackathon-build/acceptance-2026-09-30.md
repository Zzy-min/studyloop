# StudyLoop acceptance and update record — September 30, 2026

The user authorized fixes and updates to the existing GitHub repository and Devpost project after the original read-only checklist. This record separates current observations from historical device evidence.

## Next Gen competition path

| Item | Status and evidence | Failure condition / remaining uncertainty |
| --- | --- | --- |
| Official entry | Devpost API reports `published`, submitted to RevenueCat Shipaton 2026 at `2026-09-10T00:13:23.183-04:00`; https://devpost.com/software/studyloop-jnw4rv | A draft or missing submission would fail. Existing submission confirmed; private award/form answers are not returned by this API. |
| Deadline | Live Devpost dates: `2026-10-01T06:45:00Z`, October 1 at 14:45 China Standard Time; phase `submissions_open` | Missing the official deadline would fail. |
| Student route | Live requirements permit video plus public source instead of a store listing for Next Gen. Authenticated additional-info form now confirms the owner-supplied academic email, public repository, Android selection and existing minor-consent checkbox. | Email is retained only in the private Devpost form. Inbox ownership and organizer eligibility review are not independently verified. |
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

- Local signing: owner authorized a new upload key. A release AAB was built and its signer verified against that key; see `docs/SIGNING_PREPARATION_2026-09-30.md`. This is not Play App Signing enrollment or store publication.
- Play/RevenueCat production mapping: not live. RevenueCat's authenticated Apps screen has only Test Store; Play Console requires developer identity and phone verification before app creation. These are future store-release gates, not Next Gen competition requirements. The owner explicitly reaffirmed the student-only scope.
- Protected AI gateway: source exists under `services/ai-gateway`; deployment is not verified. The demonstrated guidance is deterministic and local.
- Public privacy/support URLs: https://qling.it.com/studyloop/privacy/ and https://qling.it.com/studyloop/support/ now render the real bilingual StudyLoop pages. Source is under `docs/public/studyloop/`; matching copies are in the website's `nextjs/public/studyloop/`. After owner approval, Caddy received a matcher scoped to `/studyloop/*` and a reload. Browser screenshots are in ignored `outputs/studyloop-privacy-live-20260930.jpg` and `outputs/studyloop-support-live-20260930.jpg`. Public support email replaces the app placeholder; inbox delivery has not been tested.
- Play-track golden/bad paths: acceptance script exists in `docs/REAL_DEVICE_ACCEPTANCE.md`; no new Play-track evidence is claimed.

## Media provenance and handling

Use actual Android screen captures only. Trimming waits, cropping system status bars and adding explanatory captions do not create an App UI. Keep raw captures and private identifiers in ignored `outputs/`. Check the finished video for notifications, keyboard stalls, missing steps, duration and readability before public upload. A failed transfer is resumed locally; no partial file is publishable evidence.

The finished local edit decodes without errors and was visually checked at every shot. It uses September 28 home/history/insights recordings and task/card/timer/reflection/summary/Pro device screenshots. The final restored-PRO Settings screenshot is dated August 22 and labeled as historical evidence. The original core recording could not be fully transferred because of repeated USB/ADB disconnects; no partial capture is used. SHA-256 of the reviewed edit: `3433E7821BB8EC82AA2C2E2EDF5B2E0E1909FE98F0C09A502160BF4F3C622665`.

Current paywall copy confirms that all local history stays free. README and submission copy were corrected to describe Pro as three-month/all-time pattern comparisons, rather than paid access to history.

## Follow-up verification

- Authenticated Devpost submission `1176502` shows `SUBMITTED`, `5/5 steps done`, and a disabled `Project submitted!` button. The additional-info form's academic email matches the value supplied by the owner. No new rules or consent terms were accepted. Private email is omitted from GitHub.
- The project-details form still held the older video URL despite the public API update. Saved the latest `wFz6Qis-V9M` URL into that form; the public API confirms the same current URL afterward.
- After the support-copy change: `flutter analyze --no-pub` reports no issues; Chinese localization and product resilience tests pass, 7 total. The initial guessed settings-test path did not exist; the actual affected tests were located and run.
- Review corrected an unsupported claim that all remote AI entrypoints enforce disclosure acceptance. The policy now explicitly describes the limitation. Remote AI remains unconfigured; implement and verify a consistent consent gate before enabling a gateway.
- Flutter review approved the corrected public copy with no critical/high findings. The signed AAB is a credential-free build with local guidance; it does not demonstrate a fresh Test Store or production purchase.
