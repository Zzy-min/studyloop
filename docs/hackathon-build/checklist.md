# StudyLoop Build Checklist

## Build Preferences

- **Plan ownership:** Handed off to Codex; sequencing and verification design are autonomous.
- **Build mode:** Autonomous, locked once implementation starts.
- **Comprehension checks:** N/A during the build; final handoff explains architecture, commands, and remaining decisions.
- **Git:** Preserve any pre-existing work; after repository initialization, create a local checkpoint only after each green milestone, with no push or remote creation without explicit approval.
- **Verification:** Yes. Every item must pass its listed automated or manual checks before the next item begins.
- **Verification pauses:** None for ordinary local work. Codex runs continuously to the MVP; it stops only for an approval-gated external action, destructive conflict, missing secret/configuration, or a genuinely blocking choice.
- **Check-in cadence:** Speed-run. Report material scope changes or blockers, then provide one consolidated MVP handoff.
- **Available pace:** Approximately 18 hours per week. Prefer the English demo path and cut optional animation/localization before any core-loop behavior.
- **Primary wow moment:** A calm dog stays with the student while an overwhelming task becomes one visibly smaller, achievable action.
- **Secondary proof:** Honest reflections produce one evidence-bearing personal observation, while RevenueCat Pro unlocks longer-term value without blocking immediate help.

## Safety And Scope Gates

- Local scaffolding, code edits, generated Drift files, tests, builds, emulator runs, and APK creation are authorized only after the participant starts `$build-project`.
- Creating or changing a RevenueCat project, offering, entitlement, product, or Test Store setup is an external write and requires explicit approval at that item.
- Creating a remote repository, pushing code, uploading an APK/video, publishing, or submitting to Devpost requires separate explicit approval. A local Git repository and local commits are not permission to publish.
- Never put the RevenueCat API key, participant email, real study notes, or private academic material in source, fixtures, logs, screenshots, or public handoff files.
- If a checklist item fails verification, remain on that item, diagnose with the smallest relevant checks, and do not mark it complete until the behavior is proven or the blocker is recorded.

## Checklist

- [x] **1. Scaffold the Android-only Flutter foundation**
  Spec ref: `spec.md > Build Checklist Inputs > 1` and `spec.md > Stack`
  What to build: Confirm the Android package name before scaffolding; create the Flutter project without Web/iOS targets, pin compatible Riverpod, Drift, go_router, Rive, RevenueCat, test, and lint dependencies, add the four-layer directory skeleton, compile-time environment reader, light-blue theme shell, and handwritten router with placeholder routes. Initialize local Git only if needed, preserving unrelated files.
  Acceptance: The Android application launches without an account, permission prompt, backend, or network wait; no secret is committed; all declared routes compile; no Web/iOS application target is introduced.
  Verify: Run `flutter doctor -v`, `flutter pub get`, Drift code generation, `flutter analyze`, `flutter test`, and a debug Android APK build; inspect tracked files for secret-like Test Store values. Device launch and release APK remain item 11.

- [x] **2. Implement domain types, validation, and deterministic start cards**
  Spec ref: `spec.md > Data Model And Contracts > Domain Types` and `spec.md > Components And Responsibilities > Start Card Engine And Screen`
  What to build: Add immutable session/card entities, stable enums, draft validation, all exam/programming/paper reduction rules, deterministic tie-free card generation for levels 0–3, local start-date policy, and severe-discomfort/two-session rest policy using test-first pure Dart code.
  Acceptance: Every valid task type produces the same card for the same inputs; exam subtype rules are enforced; three reductions end at the smallest useful action; severe discomfort never produces a timer card; rest copy makes no diagnosis.
  Verify: Run targeted domain tests for every type/subtype and reduction level, invalid combinations, ordinary/severe tiredness, repeated deterioration, deterministic repeatability, and cross-midnight start-date grouping, then run `flutter test test/domain`.

- [x] **3. Build Drift persistence and repository contracts**
  Spec ref: `spec.md > Data Model And Contracts > Drift Tables` and `spec.md > Data Model And Contracts > Repository Contracts`
  What to build: Define `study_records` and singleton `active_timer`, enum text serialization, versioned draft JSON, explicit schema version/migration strategy, repository streams, transactional reflection commit, transactional delete, seven-day/full-history queries, and active snapshot read/upsert/clear behavior.
  Acceptance: Valid completed and interrupted records persist with second precision; only one timer snapshot exists; cross-midnight records retain their start-date key; deletion immediately changes watched results; a failed final commit cannot leave duplicate active and final state.
  Verify: Generate Drift code and run in-memory database tests for insert/query/window boundaries/singleton replacement/rollback/delete/migration, followed by `flutter analyze` and the full data test directory.

- [x] **4. Deliver entry, task capture, rest, and start-card UI**
  Spec ref: `spec.md > Components And Responsibilities > Entry, Task, And Rest Components` and `spec.md > Routes And State Ownership`
  What to build: Implement `/`, `/task`, `/card`, and `/rest` with handwritten Riverpod Notifiers and route guards; show five barriers and waiting dog placeholder, tiredness severity follow-up, course/project fallback input, task classification, standard durations, generated card, and three reductions without putting task text in route parameters.
  Acceptance: Fresh launch shows “Why can’t you study right now?” directly; ordinary tiredness defaults to 10 minutes; severe discomfort opens rest without a timer; invalid input cannot proceed; back navigation preserves the draft; the third reduction states that the smallest action is enough for today.
  Verify: Run widget tests for first launch, all validation branches, tiredness follow-up, rest routing, back-state preservation, deterministic card display, three reductions, semantics labels, and route URLs containing no task text; manually inspect the core screens at small and large Android sizes.

- [x] **5. Implement the foreground-only timer and recovery state machine**
  Spec ref: `spec.md > Components And Responsibilities > Timer And Lifecycle Coordinator` and `spec.md > Data Flow > Startup And Recovery`
  What to build: Add `/focus`, `TimerNotifier`, monotonic foreground tick source, pause/continue/early-exit behavior, periodic and lifecycle snapshot writes, process-start snapshot detection, mandatory continue-or-save recovery, and completed/interrupted outcomes. Keep background wall time excluded.
  Acceptance: Only foreground unpaused seconds count; backgrounding or process death cannot silently complete a session; returning always offers continue or save; early save uses neutral interrupted language and preserves actual seconds.
  Verify: Run unit/application/widget tests with a fake clock and lifecycle events, including pause, background, process restore, continue, save, dismissal prevention, and wall-clock jumps; run an Android lifecycle smoke test by backgrounding and force-stopping the app.

- [x] **6. Complete reflection, atomic commit, summary, and recent history**
  Spec ref: `spec.md > Components And Responsibilities > Reflection And Record Commit` and `spec.md > Components And Responsibilities > History Repository And Screens`
  What to build: Implement `/reflection`, `/summary`, `/history`, and `/history/:id`; capture difficulty, focus, exactly three mood choices, and optional next action; commit one record atomically; show empty/recent-seven-day/detail states; add neutral early-end wording and confirmed single-record deletion.
  Acceptance: Required reflection fields block incomplete saves; actual seconds/outcome are prefilled; records group wholly under local start date; free history works offline; deletion requires confirmation and immediately removes the record; no failure, punishment, or disappointed-dog copy appears.
  Verify: Run reflection/history widget tests, Drift integration tests for atomic commit and delete, cross-midnight display tests, empty-state tests, and an offline Android session from focus through saved history.

- [x] **7. Add honest free and Pro insight calculations**
  Spec ref: `spec.md > Components And Responsibilities > Insight Engine And Presentation` and `spec.md > Data Flow > History, Delete, And Insights`
  What to build: Implement read-time `InsightEngine`, `/insights`, exact zero/one/two collection progress, one deterministic seven-day free observation at three records, evidence-count fallback when comparison is weak, Pro full-history/multi-comparison/cross-dimension/trend results, and automatic recomputation from repository streams.
  Acceptance: No personal conclusion appears below three valid recent records; exactly one factual free observation appears at threshold; Pro content is distinguishable and lockable; every observation states its evidence basis; deleting a contributor changes/removes conclusions immediately; no causal or medical claim is generated.
  Verify: Run pure-Dart threshold/tie/fallback/Pro/delete-to-two tests and widget tests for empty, progress, free observation, locked Pro, and recomputation; manually inspect copy for evidence counts and noncausal wording.

- [x] **8. Establish the six-state dog abstraction and visual baseline**
  Spec ref: `spec.md > Components And Responsibilities > Dog Companion` and `spec.md > Risks And Verification > Asset Schedule And Rights`
  What to build: Define `DogCompanion` with only `DogState` and accessible text, create six original SVG fallback states first, wire waiting/prompting/focusing/completed/interrupted/resting across the flow, then add the original Rive state machine only if it fits the schedule without changing application/domain code.
  Acceptance: Every required state is visually distinct but nonpunitive; the dog never implies care debt or failure; all states remain understandable with animation disabled; assets have documented public-release rights; switching Rive to SVG changes no business behavior.
  Verify: Run dog mapping/widget tests, reduced-motion and semantics checks, render every state on representative Android sizes, visually inspect clipping/contrast/animation subtlety, and exercise the SVG fallback even if Rive is retained.

- [x] **9. Add debug-only synthetic demo data without release leakage**
  Spec ref: `spec.md > Components And Responsibilities > Debug Demo Data` and `spec.md > Risks And Verification > Release Leakage`
  What to build: Add idempotent, clearly labeled synthetic three-plus-record fixtures and debug-only seed/clear controls that exercise free and Pro insights. Exclude provider registration, routes/controls, and fixture imports from release compilation.
  Acceptance: Debug data can create and clear the two-minute insight setup predictably; it is never presented as the participant’s personal history; Release UI exposes no seed control and contains no participant email or real study content.
  Verify: Run seed idempotency/clear/recompute tests, build debug and release APKs, inspect release UI and APK strings for fixture labels/controls/email, and confirm the ordinary empty state remains reachable.

- [x] **10. Implement the RevenueCat boundary and fake entitlement lifecycle**
  Spec ref: `spec.md > Components And Responsibilities > Entitlement Repository, Notifier, And Paywall` and `spec.md > Entitlement Lifecycle`
  What to build: Implement domain result types, fake repository, `EntitlementNotifier`, asynchronous startup, `/paywall`, `/settings` restore entry, source-route preservation, locked presentation, retry states, and entitlement-loss handling. Keep the real SDK adapter configurable but do not create or modify a RevenueCat project without explicit approval.
  Acceptance: Unknown never blocks free features or falsely grants/denies a verified entitlement; purchase success/restore success unlock immediately; cancellation is quiet; technical failure is retryable in context; no-restorable is nonblocking; entitlement loss relocks presentation without deleting records.
  Verify: Run all fake repository contract and paywall widget tests, assert local database invariance across every entitlement result, launch offline with RevenueCat unavailable, and run the full free core flow while entitlement stays unknown.

- [x] **11. Pass Android, Test Store, accessibility, and release gates**
  Spec ref: `spec.md > Test Plan > Integration, Visual, And Release Verification` and `spec.md > Risks And Verification`
  What to build: With explicit approval before any RevenueCat Dashboard write, configure the minimum Test Store project/entitlement/offering/package and inject its key through a noncommitted `--dart-define`; connect the real SDK adapter, finish accessibility and error copy, run offline/device tests, scan release output, build/install the APK, and rehearse the 120-second demo. If approval is not granted, leave Test Store as a clearly recorded blocker while completing all local fake-based gates.
  Acceptance: Free core works offline; a real approved Test Store purchase is visible in-app and in the Dashboard; all six dog states and reduced-motion UI are understandable; release contains no debug controls/secrets; analyze/tests/release build/install smoke pass; rehearsed demo is at most 120 seconds.
  Verify: Local fake and release gates completed on 2026-08-21/22: analyze/tests, debug+release APKs, V2458A install/cold start, full typed study flow, rest path, empty history, paywall cancel, keyboard geometry, and release string scan. After explicit approval on 2026-08-22, configured RevenueCat project `StudyLoop`, `default` offering, `monthly` package, and `pro` entitlement; built a debug APK from a gitignored dart-define file; completed a valid Test Store purchase and restore on the physical device; cold-start Settings showed `PRO`; Dashboard showed the Monthly sandbox subscription, active Pro entitlement, and current `default` offering. The two-minute demo sequence is captured in the handoff; no upload or submission was performed.

- [x] **12. Prepare the Devpost handoff**
  Spec ref: `spec.md > Demo And Submission Flow` and `prd.md > Submission Proof Points`
  What to build: Gather the verified project story, architecture/AI disclosure, synthetic-data disclosure, setup and demo instructions, dependency/asset licenses, screenshots, APK evidence, public-video plan, repository-readiness checks, known limitations, test evidence, and exact next actions. Do not create a remote repository, upload media, publish, or submit in this item without separate explicit confirmation.
  Acceptance: Handoff material demonstrates the dog-guided shrinking moment, reflection-based evidence, free/Pro boundary, Test Store lifecycle or its explicit blocker, offline core, and public-source hygiene; the participant has enough verified material to run `$prepare-submission` without guessing.
  Verify: Cross-check every claimed feature against tests or captured app evidence, confirm no secrets/PII appear in planned public artifacts, rehearse the full demo script under 120 seconds, review links/placeholders, and confirm the next command is `$prepare-submission`.

## Definition Of Done

- Items are completed in order unless a documented blocker makes an independent later item safe to advance.
- Each checkbox is marked only after its listed verification succeeds; partial implementation stays unchecked with evidence recorded in `build-notes.md`.
- The MVP is not considered complete without the offline core loop, foreground-only recovery behavior, honest insight threshold, nonjudgmental dog states, and a tested RevenueCat entitlement boundary.
- Real Test Store proof remains required for final competition readiness, but inability to obtain external approval must not prevent local fake-based implementation and testing.
- Build completion hands off to `$prepare-submission`; it never implies that anything has been uploaded or submitted.
