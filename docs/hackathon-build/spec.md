# StudyLoop Technical Spec

## Overview

StudyLoop is an offline-first Flutter Android application for university students who are stuck before studying. This specification translates all seven PRD epics into an implementation that can be built without a backend, account, or external AI. The technical priorities are deterministic behavior, foreground-only timing, honest local insights, graceful RevenueCat failure handling, and a two-minute Next Gen demonstration.

The first release produces an Android APK, public source, and a public demo video. It does not target Web, iOS, or an application-store release. Android package name, signing identity, and RevenueCat Project ID remain explicit setup decisions for the build stage.

## Stack

### Toolchain

- Flutter 3.44.6 and Dart 3.12.2.
- Android SDK 36 and JDK 21.
- Android is the only runtime target for the hackathon build.

### Application Dependencies

- [Riverpod](https://pub.dev/packages/flutter_riverpod) 3.x for dependency injection and application state. Providers use handwritten `Notifier` and `AsyncNotifier` classes; legacy `StateNotifier` and Riverpod annotation/code generation are excluded.
- [Drift](https://pub.dev/packages/drift) 2.x with SQLite for local persistence. Drift table and database code is the only generated application code and uses `build_runner`.
- [go_router](https://pub.dev/packages/go_router) with a handwritten route table and no route generator.
- [Rive](https://pub.dev/packages/rive) for the original six-state dog animation. `DogCompanion` isolates the rendering implementation so six original SVG assets can replace Rive without changing product logic.
- [RevenueCat purchases_flutter](https://www.revenuecat.com/docs/getting-started/installation/flutter) at a stable 10.x version verified against Flutter 3.44.6 when implementation begins, and never below 9.8.0 because the [RevenueCat Test Store](https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store) requires that minimum.

Exact dependency versions are pinned in `pubspec.lock` during implementation after `flutter pub get`, analyze, test, and Android build verification. The Test Store API key is supplied with `--dart-define=REVENUECAT_API_KEY=...`; source, fixtures, screenshots, logs, and public repository files must not contain it.

## Architecture

### Presentation Layer

Owns screens, widgets, handwritten `go_router` routes, theme, accessibility semantics, localized copy, dialogs, and the dog renderer. It observes application providers and emits user intentions. It never calls Drift or RevenueCat directly.

Implements: PRD Epics 1–7 presentation and screen-observable acceptance criteria.

### Application Layer

Owns session-draft transitions, timer lifecycle, reflection submission, history queries, insight presentation, entitlement refresh, paywall return context, and debug demo-data commands. Handwritten Riverpod `Notifier`/`AsyncNotifier` providers coordinate domain services and repositories.

Implements: PRD Epics 1–7 orchestration, navigation-safe state, and failure states.

### Domain Layer

Contains enums, immutable entities, repository interfaces, deterministic `StartCardEngine`, insight calculations, date grouping, and rest-policy rules. It imports neither Flutter, Drift, Rive, nor RevenueCat, allowing fast pure-Dart testing.

Implements: PRD Epics 1–6 rules and the entitlement contract needed by Epic 7.

### Data Layer

Contains Drift tables and queries, repository implementations, the single active-timer snapshot, the RevenueCat adapter, and debug-only synthetic data. The SQLite database is unencrypted and remains inside the Android application sandbox; no account or network synchronization exists.

Implements: PRD Epics 4–7 persistence and external-service boundaries.

## File Structure

```text
studyl_loop/
├── android/                              # Generated Flutter Android host and release configuration
├── assets/
│   ├── rive/study_dog.riv                # Original six-state dog state machine
│   └── dog_svg/                          # Original six-state static fallback assets
├── lib/
│   ├── main.dart                         # Flutter binding, database open, app bootstrap
│   ├── app.dart                          # MaterialApp.router, theme, localization wiring
│   ├── bootstrap/
│   │   ├── app_bootstrap.dart            # Ordered local startup and async RevenueCat launch
│   │   └── app_environment.dart          # Compile-time keys and debug/release feature flags
│   ├── domain/
│   │   ├── models/
│   │   │   ├── study_enums.dart          # Barrier, severity, task, outcome, mood, dog, entitlement enums
│   │   │   ├── session_draft.dart        # Pre-focus user choices and generated card
│   │   │   ├── active_timer_snapshot.dart# Persistable foreground timer state
│   │   │   ├── study_record.dart         # Completed/interrupted reflected session
│   │   │   └── insight.dart              # Evidence-bearing free and Pro insight value objects
│   │   ├── engines/
│   │   │   ├── start_card_engine.dart    # Deterministic task reduction levels 0–3
│   │   │   └── insight_engine.dart       # Read-time threshold, fallback, and Pro comparisons
│   │   ├── policies/
│   │   │   ├── rest_policy.dart          # Severe discomfort and two-session deterioration rules
│   │   │   └── session_date_policy.dart  # Assigns a record to local start date
│   │   └── repositories/
│   │       ├── study_repository.dart      # Records/history/delete/timer snapshot contract
│   │       └── entitlement_repository.dart# Configure, purchase, restore, refresh contract
│   ├── application/
│   │   ├── session/session_notifier.dart # Draft validation, card generation, reduction, reset
│   │   ├── timer/timer_notifier.dart      # Foreground ticks, pause, background save, restore choice
│   │   ├── reflection/reflection_notifier.dart # Validates reflection and commits one record
│   │   ├── history/history_provider.dart  # Seven-day/full-history streams and record deletion
│   │   ├── insights/insights_provider.dart# Recomputes free/Pro insights from current records
│   │   ├── entitlement/entitlement_notifier.dart # unknown/free/pro lifecycle and operations
│   │   ├── navigation/paywall_origin.dart # Non-sensitive origin identifier for return navigation
│   │   └── demo/demo_data_notifier.dart   # Debug-only synthetic seed/clear commands
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart          # Drift database, schema version, migrations
│   │   │   ├── tables/study_records.dart  # Final valid records table
│   │   │   └── tables/active_timer.dart   # Single-row pending timer table
│   │   ├── repositories/drift_study_repository.dart # Transactional local implementation
│   │   ├── revenuecat/revenuecat_entitlement_repository.dart # SDK error/result translation
│   │   └── demo/synthetic_records.dart    # Clearly labeled nonpersonal fixtures, debug only
│   ├── presentation/
│   │   ├── routing/app_router.dart        # Handwritten routes and redirect guards
│   │   ├── theme/study_loop_theme.dart    # Light-blue calm study-room design tokens
│   │   ├── dog/
│   │   │   ├── dog_companion.dart         # Rendering interface accepting only DogState
│   │   │   ├── rive_dog_companion.dart    # Rive state-machine adapter
│   │   │   └── svg_dog_companion.dart     # Accessible static fallback
│   │   ├── common/                        # Shared buttons, cards, errors, progress and semantics
│   │   ├── entry/entry_screen.dart        # Barrier and tiredness severity selection
│   │   ├── task/task_screen.dart          # Task/course input, type/subtype, duration
│   │   ├── card/start_card_screen.dart    # Card and three reductions
│   │   ├── focus/focus_screen.dart        # Timer and interruption/background dialogs
│   │   ├── reflection/reflection_screen.dart # Difficulty, focus, mood, next action
│   │   ├── summary/summary_screen.dart    # Neutral session result
│   │   ├── history/                       # Empty/list/detail/delete-confirmation surfaces
│   │   ├── insights/insights_screen.dart  # Collection, free observation, and locked Pro sections
│   │   ├── paywall/paywall_screen.dart    # Purchase/restore/cancel/error UI
│   │   ├── settings/settings_screen.dart  # Restore and debug-only seed entry
│   │   └── rest/rest_screen.dart          # Nonmedical severe-discomfort rest path
│   └── l10n/                              # English source copy; optional Chinese localization
├── test/
│   ├── domain/                            # Engines and policy unit tests
│   ├── data/                              # In-memory Drift and migration tests
│   ├── application/                       # Notifier state-transition tests
│   ├── presentation/                      # Widget and accessibility tests
│   └── fakes/fake_entitlement_repository.dart # Deterministic RevenueCat contract fake
├── integration_test/                      # Android offline, lifecycle, and smoke journeys
└── docs/hackathon-build/                  # Scope, PRD, Spec, checklist, and journal
```

## Data Flow

### Startup And Recovery

1. `main.dart` initializes Flutter bindings and opens Drift.
2. Bootstrap reads the optional `active_timer` row before rendering.
3. The application renders immediately from local state. If a snapshot exists, it presents a mandatory continue-or-save prompt; it never derives elapsed focus from wall-clock time.
4. RevenueCat initialization starts asynchronously. Until verified, entitlement is `unknown`; free routes remain usable while Pro content shows “temporarily unable to verify” with retry.

### Session Lifecycle

1. Entry and task screens write barrier, optional `FatigueSeverity`, task text, type/subtype, and planned seconds into `SessionDraft` held by `SessionNotifier`.
2. Severe discomfort invokes `RestPolicy` and routes to `/rest` without calling `StartCardEngine` or creating a timer.
3. Valid ordinary input goes to `StartCardEngine`. Inputs plus reduction level 0–3 deterministically produce the card; navigation carries no task text.
4. Starting focus creates `ActiveTimerSnapshot`. `TimerNotifier` increments actual seconds only while foregrounded, unpaused, and active, then periodically and on lifecycle pause writes the one permitted snapshot row.
5. Completion, early-save, or restore-save freezes actual seconds and routes to reflection. Background and process-absence wall time is excluded.
6. Reflection validation creates one `StudyRecord`; `SessionDatePolicy` derives local `startDate` from the original start timestamp. A transaction inserts the record and removes the active snapshot.
7. Summary/history observe repository streams. Display converts seconds to friendly minutes without discarding stored precision.

### History, Delete, And Insights

1. History requests either the latest seven local calendar days or complete history based on entitlement.
2. `InsightsProvider` reads current records and calls `InsightEngine`; derived insights are never stored.
3. Fewer than three valid recent records yields exact collection progress. At three or more, free users receive exactly one seven-day, single-dimension observation; when comparison evidence is insufficient, the engine returns a factual sample-count fallback.
4. Pro adds complete-history results, multiple comparisons, task/barrier cross-comparisons, and trends beyond seven days.
5. Confirmed deletion runs in a Drift transaction. Repository streams emit the new record set, so totals and insights immediately recompute and can return below the three-record threshold.

### Entitlement Lifecycle

1. `EntitlementNotifier` requests configuration/refresh through `EntitlementRepository` and maps verified customer information to `free` or `pro`.
2. Purchase success and restore success force a fresh customer-information read before unlocking content.
3. User cancellation is a typed non-error result and returns without a banner. Technical failure preserves the paywall and origin with a retry action. No-restorable-purchase is a separate nonblocking result.
4. Entitlement loss changes only the presentation gate; local records remain untouched.

## Components And Responsibilities

### Entry, Task, And Rest Components

`EntryScreen`, `TaskScreen`, `SessionNotifier`, and `RestPolicy` enforce the five barriers, the tiredness severity follow-up, minimum task/course input, task classification, standard durations, and severe-discomfort bypass. `RestScreen` uses nonmedical copy and `DogState.resting`.

Implements: `prd.md > Epic 1`, `Epic 2`, and `Epic 4 > Story 4.4`.

### Start Card Engine And Screen

`StartCardEngine` is a total, deterministic mapping over supported task type/subtype, barrier, input, duration, and reduction level. `StartCardScreen` exposes reductions 0–2 and replaces the reducer after level 3 with the smallest-action-is-enough message.

Implements: `prd.md > Epic 3`.

### Timer And Lifecycle Coordinator

`TimerNotifier` owns foreground seconds, remaining seconds, pause state, lifecycle observations, snapshot persistence, completion, and interrupted outcomes. It uses a monotonic tick source while active and persists integer seconds; wall-clock timestamps are metadata, never a source for adding background time.

Implements: `prd.md > Epic 4 > Stories 4.1–4.3` and offline requirements.

### Reflection And Record Commit

`ReflectionNotifier` requires difficulty, focus, and one of exactly three `MoodChange` values, permits blank next action, and atomically replaces the active timer with one final record. Stable IDs are generated locally.

Implements: `prd.md > Epic 5`.

### History Repository And Screens

`StudyRepository` exposes record streams, seven-day queries, full-history queries, detail lookup, transactional delete, and optional active-timer storage. History widgets provide warm empty state, neutral completion wording, start-date grouping, detail timestamps, and explicit irreversible-local-delete confirmation.

Implements: `prd.md > Epic 6 > Stories 6.1–6.3` and `Epic 5 > Story 5.2`.

### Insight Engine And Presentation

`InsightEngine` computes evidence-bearing results at read time. Free selection compares eligible single dimensions using a fixed ordering for deterministic ties and returns one strongest factual observation; insufficient comparison returns the most-used duration plus sample count. Pro calculations can return several comparisons and longer trends. Presentation never uses causal or medical language.

Implements: `prd.md > Epic 6 > Story 6.4` and all threshold/deletion behavior.

### Entitlement Repository, Notifier, And Paywall

The repository hides RevenueCat SDK types behind domain results: configured customer info, purchase success, user cancellation, technical failure, restore success, no restorable purchase, and entitlement loss. `PaywallOrigin` contains only a route identifier; the session draft remains in Riverpod state. The notifier starts as `unknown`, never infers Pro or free on network failure, and never blocks core features.

Implements: `prd.md > Epic 7` and RevenueCat-related offline/error requirements.

### Dog Companion

`DogCompanion` accepts only `DogState` and accessible text. The Rive implementation maps the six enum values to six state-machine inputs; the SVG implementation maps them to six original static assets. With animation disabled, labels and screen copy still communicate every state.

Implements: dog states across `prd.md > Epics 1–7`, accessibility, and nonjudgmental tone.

### Debug Demo Data

`DemoDataNotifier` inserts and clears clearly labeled synthetic records only when `kDebugMode` is true. Release builds do not register the provider, route, control, or fixture import. Seed insertion is idempotent and never mixes synthetic content with claimed personal data.

Implements: `prd.md > Submission Proof Points` without weakening privacy requirements.

### Navigation

The handwritten route table defines `/`, `/task`, `/card`, `/focus`, `/reflection`, `/summary`, `/history`, `/history/:id`, `/insights`, `/paywall`, `/settings`, and `/rest`. Redirects prevent focus/reflection routes without their required application state. Paywall close/cancel/error returns to a validated origin route while retaining its provider state.

Implements: navigation and context-preservation criteria across `prd.md > Epics 1–7`.

## Data Model And Contracts

### Domain Types

- `StudyBarrier`: `uncertainStart`, `overload`, `phoneDistraction`, `tiredness`, `perfectionism`.
- `FatigueSeverity`: `ordinary`, `severe`; valid only when barrier is `tiredness`.
- `TaskType`: `examRevision`, `programmingPractice`, `paperWriting`.
- `ExamSubtype`: `memory`, `calculation`, `understanding`; required only for exam revision.
- `SessionOutcome`: `completed`, `interrupted`.
- `MoodChange`: `moreAtEase`, `unchanged`, `worse`.
- `DogState`: `waiting`, `prompting`, `focusing`, `completed`, `interrupted`, `resting`.
- `EntitlementState`: `unknown`, `free`, `pro`.
- `SessionDraft`: barrier, nullable fatigue severity, task/course text, task type, nullable exam subtype, planned seconds, reduction level 0–3, and generated card.
- `ActiveTimerSnapshot`: draft, accumulated foreground seconds, remaining seconds, start timestamp, and last-saved timestamp.
- `StudyRecord`: stable ID, start/end timestamps, local start-date key, task fields, planned/actual seconds, outcome, difficulty, focus, mood, and optional next action.

### Drift Tables

`study_records` stores all scalar `StudyRecord` fields. Enums are stored as stable textual keys rather than ordinal positions. `actual_seconds >= 0`, `planned_seconds > 0`, required reflection fields are non-null, and `start_date` is an ISO local calendar-date key computed once at commit.

`active_timer` uses a constant primary key (for example `singleton = 1`) to enforce at most one row. It stores the draft as versioned JSON plus timing fields. Repository writes replace that row transactionally; final record commit deletes it in the same transaction.

Schema migrations are explicit by version, covered by upgrade tests, and must preserve existing records. No destructive migration is permitted for release builds.

### Repository Contracts

`StudyRepository` supports watching seven-day records, watching all records, fetching detail, committing a reflected session, deleting by stable ID, reading/upserting/clearing the active snapshot, and debug-only seed/clear operations.

`EntitlementRepository` supports configure, refresh, purchase the configured Pro package, and restore. Results are typed so user cancellation cannot be rendered as a technical error. SDK exceptions are translated inside the data layer and do not escape into UI code.

## External APIs And Dependencies

RevenueCat is the only networked runtime dependency. It receives the anonymous RevenueCat application user identity managed by its SDK and purchase metadata; StudyLoop does not send task text or reflection content. The Pro entitlement identifier and offering/package identifiers are injected as nonsecret compile-time configuration, while the platform API key is injected through `--dart-define` and excluded from version control.

RevenueCat initialization is best-effort after local UI startup. The adapter listens for customer-information updates to handle purchase, restore, and entitlement loss. Test Store is used for the Next Gen demonstration; production store configuration is outside this release scope.

SQLite, Riverpod, go_router, and Rive operate locally. The original `.riv` or SVG assets must be owned or licensed for public repository and video distribution, with attribution included if a compatible license requires it.

## AI Usage

The product runtime uses no generative AI, model API, remote recommendation service, or prompt containing student data. Start cards and insights are deterministic local algorithms.

AI-assisted coding may be used to create implementation, tests, documentation, and development assets. All generated output must be reviewed, run locally, and disclosed accurately in the Devpost submission. No participant email, real study reflection, API key, or private academic material may be placed into prompts, fixtures, the public repository, or demo footage.

## Routes And State Ownership

| Route | Required state | Owner | Invalid-state behavior |
| --- | --- | --- | --- |
| `/` | none | `SessionNotifier` reset/entry | Always available |
| `/task` | selected barrier; severity if tiredness | `SessionNotifier` | Redirect to `/` |
| `/card` | valid task/type/subtype/duration and card | `SessionNotifier` | Redirect to `/task` |
| `/focus` | active snapshot | `TimerNotifier` | Redirect to `/` |
| `/reflection` | frozen completed/interrupted result | `ReflectionNotifier` | Redirect to `/` |
| `/summary` | newly committed record ID | repository/detail provider | Redirect to `/history` if absent |
| `/history` | none | history provider | Always available; free window applied |
| `/history/:id` | existing record | detail provider | Show not-found and return action |
| `/insights` | current records | insights provider | Collection/free state; Pro areas locked |
| `/paywall` | validated origin identifier | entitlement notifier | Default origin `/insights` |
| `/settings` | none | entitlement/demo providers | Always available |
| `/rest` | severe discomfort or deterioration recommendation | session/rest policy | Redirect to `/` if absent |

Session text and reflection data never appear in route URLs, query strings, logs, or RevenueCat attributes.

## Test Plan

### Pure Dart Unit Tests

- Cover every task type/subtype and each reduction level 0–3, deterministic repeatability, invalid draft rejection, and severe discomfort producing a rest decision rather than a timer card.
- Cover exactly-three-record threshold, one/two-record progress, deterministic tie ordering, no-significant-comparison fallback with sample count, Pro multidimensional output, and deletion-driven recomputation.
- Cover second-precision accumulation, pause behavior, excluded background duration, completion/interruption, and local start-date grouping across midnight.
- Cover two consecutive very-low-focus or worsening-mood records triggering nonmedical rest advice.

### Drift Tests

- Use an in-memory database for insert/read, seven-calendar-day boundaries, full history, stable enum serialization, transactional commit/delete, active-timer singleton replacement, and schema migration fixtures.
- Verify a failed commit does not leave both a final record and active snapshot, and deleting a missing ID is a controlled result.

### Application And Widget Tests

- Cover fresh first screen, five barriers, tiredness severity follow-up, ordinary 10-minute default, task validation, three reductions, and severe rest routing.
- Cover lifecycle pause persistence, process-recovery prompt, continue/save choices, three mood values, empty history, delete confirmation/cancel/recompute, fewer-than-three collection state, and three-record free observation.
- Cover paywall origin return for close, cancellation, and error; locked content for unknown/free; and immediate content refresh for Pro.
- Verify semantics labels, animation-disabled comprehension, neutral interrupted copy, and no color-only state communication.

### RevenueCat Contract Tests

A fake `EntitlementRepository` covers initialization remaining `unknown`, verified free, purchase success, explicit user cancellation, technical error with retry, restore success, no restorable purchase, restore error, customer-information update to Pro, and entitlement loss. Every case asserts that local study data is unchanged.

### Integration, Visual, And Release Verification

- Run the complete Android core loop offline on an emulator and at least one physical-device/API combination if available.
- Use RevenueCat Test Store for an actual test purchase and verify the resulting entitlement and Dashboard event before recording the final demo.
- Inspect all six Rive states, reduced-motion behavior, and the six-state SVG fallback on representative Android screen sizes; verify no clipping, illegible contrast, or content-only animation dependency.
- Confirm the debug seed controls and fixture strings are absent from a release build.
- Run `flutter analyze`, `flutter test`, `flutter build apk --release`, install the APK, and complete a launch/focus/reflection/history smoke test.
- Rehearse and time the final public video at no more than 120 seconds.

## Risks And Verification

### Timer Correctness

Risk: Android lifecycle changes or process death can inflate focus time. Mitigation: persist accumulated foreground seconds immediately on pause, never add timestamp deltas after resume, and require an explicit recovery choice. Verify with lifecycle widget tests, forced process termination, and wall-clock manipulation scenarios.

### RevenueCat Availability And Configuration

Risk: invalid Test Store configuration, network loss, or SDK changes can block the demo. Mitigation: asynchronous initialization, typed `unknown` state, fake contract coverage, no free-flow dependency, and a pre-recording real Test Store rehearsal. Never infer free or Pro from an exception.

### Insight Credibility

Risk: three records are a small sample and deletion can invalidate conclusions. Mitigation: one factual free observation, visible evidence count, deterministic fallback, no causal wording, and read-time recomputation. Verify zero/one/two/three records plus delete-to-two.

### Local Privacy

Risk: unencrypted local task/reflection content may be accessible on a compromised or backed-up device. Mitigation for MVP: application sandbox, no account/cloud/analytics, no sensitive route/log content, synthetic demos, and transparent documentation. Encryption and backup controls are deferred and must not be implied.

### Asset Schedule And Rights

Risk: an original Rive state machine may exceed the solo schedule or use unclear assets. Mitigation: freeze the `DogCompanion` interface early, require original/licensed public-release rights, and switch to six original SVG states without changing domain/application code. Cut nonessential motion before product behavior.

### Release Leakage

Risk: API keys or debug fixtures reach the public repository or APK. Mitigation: `--dart-define`, ignored local launch configuration, release compile-time exclusion, secret scanning, and APK string inspection. RevenueCat public SDK keys are still treated as configuration and never embedded in committed source.

## PRD Epic Traceability

| PRD epic | Components | Providers/repositories | Primary verification |
| --- | --- | --- | --- |
| Epic 1: Immediate entry | Entry screen, dog waiting state, router | Session notifier | Fresh-install and severity widget tests |
| Epic 2: Task capture | Task screen, validators | Session notifier | Type/subtype/duration validation tests |
| Epic 3: Start card | Start card screen/engine | Session notifier | Pure-Dart level 0–3 tests |
| Epic 4: Focus/rest | Focus/rest screens, timer, rest policy | Timer notifier, study repository | Lifecycle, process recovery, offline tests |
| Epic 5: Reflection | Reflection/summary screens, date policy | Reflection notifier, study repository | Mood, commit, cross-midnight tests |
| Epic 6: History/patterns | History/insight screens and engine | History/insight providers, study repository | Threshold, delete, fallback, Pro tests |
| Epic 7: RevenueCat Pro | Paywall/settings and gate | Entitlement notifier/repository | Fake contract and Test Store tests |

## Build Checklist Inputs

The next checklist must order work in independently verifiable slices:

1. Flutter Android scaffold and quality gates, after confirming package name.
2. Domain types, card engine, rest/date policies, and unit tests.
3. Drift schema/repository/migrations and database tests.
4. Entry → task → card UI with Riverpod and handwritten routing.
5. Foreground-only timer, lifecycle recovery, reflection, and history.
6. Insight threshold/free/Pro calculations and deletion recomputation.
7. Dog abstraction with SVG baseline, then Rive upgrade if time allows.
8. RevenueCat adapter, fake contract tests, Test Store setup, and paywall.
9. Accessibility, offline, release leakage, APK, and two-minute demo verification.

No checklist item may configure an external service, publish, push, or submit without its own explicit user confirmation. Local scaffold and implementation likewise begin only after the participant advances to and confirms the build checklist.

## Demo And Submission Flow

The two-minute demo uses a debug build with clearly labeled synthetic history but the real Test Store entitlement path:

1. 0–15 seconds: launch directly into the barrier question and show the waiting dog.
2. 15–40 seconds: choose overload, enter an exam-calculation task, select 15 minutes, generate a card, and reduce it once.
3. 40–75 seconds: start focus, show the focusing dog, then use a shortened demo interval or controlled early save and complete the nonjudgmental reflection.
4. 75–95 seconds: show synthetic-record labeling, three-record evidence, and the single free observation.
5. 95–115 seconds: open locked long-term insights, show the paywall, complete a real Test Store purchase, and reveal Pro comparisons.
6. 115–120 seconds: state the Next Gen value: no account, backend, external AI, or network is needed for immediate study help.

Public source includes reproducible setup instructions, dependency licenses, nonsecret configuration names, a synthetic-data disclosure, and the Rive/SVG asset rights. The APK is supplementary evidence; whether Devpost permits a direct APK link must be checked against the live submission form during submission preparation.

