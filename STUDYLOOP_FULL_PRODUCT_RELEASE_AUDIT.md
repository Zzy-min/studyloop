# 1. Executive Summary

**当前阶段：BETA。最终结论：READY FOR CLOSED BETA。**

StudyLoop 的免费本地核心闭环成立：识别启动阻力、确定性生成最小行动、前台真实计时、可跳过反思、History 与确定性 Insights 均可离线运行。AI 已有 `AICompanionRepository`、上下文清洗、结构化回复和本地 fallback；但真实生产 AI Gateway 没有配置、部署或端到端验证，不能把云端 AI 当作已发布能力。

本轮移除了 Flutter 客户端直连 DeepSeek 和让用户输入模型 key 的路径，避免 Provider secret 进入 APK。仍存在公开发布 P0：APK/AAB 使用 Android Debug 证书、没有公开隐私政策 URL/支持入口、没有已验证的生产 Gateway/RevenueCat/商店配置。评分受制于这些可验证的发布事实，而不是测试数量。

# 2. Product Scorecard

| Dimension | Score |
|---|---:|
| Product Positioning | 92 |
| Core Value | 86 |
| Onboarding | 82 |
| Start Flow | 84 |
| Minimum Action | 82 |
| AI Companion | 72 |
| AI Workflow Integration | 68 |
| AI Safety | 76 |
| Focus | 79 |
| Reflection | 82 |
| History | 78 |
| Insights | 72 |
| Corgi Visual System | 78 |
| Navigation | 80 |
| UI/UX | 80 |
| Accessibility | 74 |
| Database | 82 |
| Migration | 78 |
| RevenueCat | 80 |
| Privacy | 74 |
| Security | 76 |
| Android Release | 40 |
| Stability | 80 |
| Long-term Value | 72 |
| Release Readiness | 55 |

# 3. Architecture

```text
Flutter UI / go_router / Riverpod
        ↓
Controllers and domain rules
        ↓
Repositories
 ├─ Drift SQLite (sessions, timer snapshot, insights source)
 ├─ RevenueCat entitlement adapter
 └─ AICompanionRepository
      ├─ optional product AI Gateway
      └─ deterministic Corgi fallback
```

AI does not call the database, timer, entitlement repository, or router directly. `ProposedAction` is an untrusted suggestion and requires user confirmation before it enters the ordinary task flow. No model Provider SDK or client Provider API key remains in the source.

# 4. Product Workflow

`Barrier → Task → optional AI suggestion → deterministic Minimum Action → Focus → Reflection → History → deterministic Insight → optional AI explanation`.

First value is normally reached in about three pages, five to seven taps, and one task text entry. There is no account, course setup, goal plan, or purchase step before the user can begin. Friction remains in task-type selection and in the separate chat surface: AI assists several nodes but is not yet seamlessly embedded into a confirmed action-edit flow on every surface.

# 5. AI Permission Matrix

| Capability | Actual status |
|---|---|
| Read current task, barrier, task type | Allowed, sanitized context |
| Read aggregate recent summary | Allowed, limited structured summary |
| Suggest barrier/action | Allowed as proposal only |
| Explain deterministic insight | Allowed as explanation only |
| Persist session or reflection | Forbidden by architecture |
| Alter actual duration, start/finish timer | Forbidden |
| Purchase/restore/change entitlement | Forbidden |
| Delete history/change settings | Forbidden |
| Read raw SQLite dump, IDs, RevenueCat data | Not included in AI context |

# 6. AI Workflow Review

Home and task breakdown can request supportive local or gateway-backed proposals. Focus uses short support; Reflection can provide language-only encouragement without assigning ratings; Insights passes deterministic text for explanation rather than raw records. Safety phrases are intercepted locally before any request and direct the user to stop studying and seek support when appropriate.

`AIContextSanitizer` and structured parsing exist. The parser clamps proposed minutes to 5–60 and rejects unknown enums by omitting them. Remaining gaps: no production gateway contract, authentication, rate limiting, observability, or real-provider response verification. Thus all cloud-AI latency, timeout, 429 and provider-safety claims are **NOT VERIFIED**.

# 7. Core Product Issues

## P0

- **Release is Debug-signed.** Both APK and AAB certificates are `CN=Android Debug`; official distribution is blocked.
- **No public privacy policy URL or validated support channel.** Store release is blocked, especially because optional AI can transmit an explicit message and minimal task context.
- **Production AI Gateway is absent/unverified.** The app has a gateway interface but no deployed endpoint, credentials, abuse controls or production test evidence. Do not market cloud AI as live.

## P1

- Timer uses wall-clock timestamps; changing the system clock remains a time-integrity risk.
- Gateway reply parsing caps duration but does not impose explicit reply/title/description length limits before rendering.
- Locale selection is not persisted across relaunches.
- No automated 50/100/500-record performance coverage or long-duration device stress run.

# 8. UI/UX Issues

- First-screen hierarchy is calm and start-oriented; it does not resemble a productivity dashboard.
- Five English short labels remain slightly ambiguous (`Busy`, `Prep`).
- Large-font 360×640 coverage passes. 360×800, 390×844, 412×915 visual checks are **NOT VERIFIED**.
- Corgi states exist for waiting/focusing/resting/completed, but a full multi-viewport asset sharpness audit is **REQUIRES REAL DEVICE**.
- Bottom-tab state/navigation tests exist; live rapid-tab and Android Back gesture checks remain **REQUIRES REAL DEVICE**.

# 9. Data Integrity

`actualSeconds` is persisted and used rather than planned time. Early ending is not described as failure. Reflection Skip now writes `difficulty`, `focus`, and `moodChange` as null; migration V1→V2 preserves existing rows and tests pass. Insights are calculated locally and data-insufficient states avoid invented patterns.

The migration is forward-only and preserves V1 data in its tested path; rollback/recovery for later schema changes is not documented. Enum `byName` parsing remains fragile if persisted enum names change.

# 10. AI Safety & Privacy

This audit removed the direct DeepSeek path and Settings API-key dialog. The Flutter client can only call `STUDYLOOP_AI_GATEWAY_URL`, with a local fallback when absent or failing. This prevents a model secret from being deliberately compiled into the app.

The app shows an AI privacy notice and describes local study data, RevenueCat boundaries, and non-medical intent. However, the public policy URL, gateway retention policy, request authentication, data-processing agreement, rate limits, and abuse monitoring are **REQUIRES PRODUCTION CREDENTIAL / NOT VERIFIED**.

# 11. RevenueCat

Free users can complete the full immediate-help loop. Pro is scoped to longer-term insight value; purchase/restore errors do not block core study features and duplicate taps are guarded. Test Store purchase/restore has historical physical-device evidence.

Live RevenueCat entitlement/offering/package configuration and production-store restore are **REQUIRES PRODUCTION CREDENTIAL**. No study content is sent to RevenueCat by the app’s repository boundary.

# 12. Android Release

Build outputs verified on 2026-09-02:

- APK: `app-release.apk`, 80.9 MB, builds successfully, **Debug-signed**.
- AAB: `app-release.aab`, 76.7 MB, builds successfully, **Debug-signed**.
- Package: `com.zzy.studyloop`; version `1.0.0+1`; minSdk 24; targetSdk 36.
- Merged manifest: INTERNET, ACCESS_NETWORK_STATE, BILLING, internal dynamic-receiver permission; `allowBackup=false`, `fullBackupContent=false`.

`android/key.properties` and a real upload keystore are absent. `purchases_flutter` and `rive_native` emit a future Built-in Kotlin compatibility warning.

# 13. Store Readiness

Name, icon, package ID, version, basic listing draft, and submission assets exist locally. A public policy URL, validated support email/website, final screenshots, category/content ratings, Data Safety disclosures, subscription disclosure, AI disclosure, production signing and live billing configuration are incomplete or **NOT VERIFIED**.

# 14. Golden Path

Automated path passes: task input → start card → Focus → finish → Reflection → History saves actual focused seconds. New-vs-returning state, pause separation and Recovery behavior are covered in unit/widget tests.

Real device: vivo V2458A / Android 16 / app `1.0.0 (1)` installed and rendered Home; language switching, barrier selection and text-field focus were observed. Full text-entry-to-insights path is **REQUIRES REAL DEVICE** because the device IME blocked ADB text injection and its ADB connection was unstable.

# 15. Bad Path

Automated coverage passes for duplicate start/finish/save/purchase protection, invalid AI fields, safety interception, gateway fallback, data-poor insights, migration, manual versus lifecycle pause, and reflection skip nulls.

Real-device tests for airplane mode, provider timeout/429, lock/unlock, force-stop recovery, 500 sessions, fast tab switching and AI request backgrounding are **NOT VERIFIED**.

# 16. Automated Tests

Actually executed after this audit's security change:

- `flutter analyze --no-pub`: PASS, no issues.
- `flutter test --no-pub`: PASS, 87 tests.
- `flutter build apk --release --no-pub`: PASS.
- `flutter build appbundle --release --no-pub`: PASS.

Coverage includes AI context/safety/fallback/workflow, nullable reflection skip, V1→V2 migration, timer semantics, RevenueCat failures, tabs, Golden Path and small-screen large-text resilience.

# 17. Manual Tests

**Executed:** Vivo V2458A, Android 16; release `1.0.0 (1)` installed; Home visual render, English/Chinese switch, barrier selection and task field focus observed.

**Not executed:** a stable full Golden Path; full Bad Path; 30–50 minute soak; complete responsive viewport series; production AI Gateway; production RevenueCat; production signing; store console submission.

# 18. Files Changed

- `lib/data/repositories/hybrid_ai_companion_repository.dart`: removed direct Provider request and Provider key environment variables.
- `lib/presentation/view_models/corgi_chat_view_model.dart`: removed client-side model-key notifier.
- `lib/presentation/screens/settings_screen.dart`: removed API-key configuration UI and clarified gateway/local privacy boundary.
- `test/domain/ai_companion_test.dart`, `test/domain/ai_workflow_integration_test.dart`: changed direct-Provider tests to Gateway fallback tests.

# 19. Remaining Blockers

1. Create and securely manage an Android upload key; build/sign a release AAB and verify its non-debug certificate.
2. Publish a real privacy policy and support URL; align it with AI Gateway and RevenueCat data flows.
3. Deploy an authenticated, rate-limited, observable AI Gateway with server-side Provider credentials; add contract, timeout, invalid-response and abuse tests.
4. Configure production RevenueCat/store products and run purchase/restore on a production test track.
5. Complete stable-device Golden/Bad Path acceptance and update version code/name for distribution.

# 20. Release Checklist

| Item | Status |
|---|---|
| Static analysis | PASS |
| Automated tests | PASS |
| SQLite V1→V2 migration test | PASS |
| Actual-duration persistence | PASS |
| Reflection skip null values | PASS |
| AI client has no direct Provider key path | PASS |
| AI local fallback | PASS |
| APK build | PASS |
| AAB build | PASS |
| Production upload signature | FAIL |
| Public privacy policy URL | FAIL |
| Real support contact | FAIL |
| Production AI Gateway | NOT TESTED |
| Production RevenueCat | REQUIRES PRODUCTION CREDENTIAL |
| Full real-device Golden Path | REQUIRES REAL DEVICE |
| Full real-device Bad Path | REQUIRES REAL DEVICE |
| Store listing/submission | NOT VERIFIED |

# 21. Final Verdict

**READY FOR CLOSED BETA**

1. **Core problem clear?** Yes: starting study when the user is stuck.
2. **Does AI enhance rather than replace it?** Architecturally yes; in production it is unverified because no Gateway is deployed.
3. **Is Corgi a useful AI companion?** It is a useful local companion; cloud-AI quality is unverified.
4. **Is first value fast?** Yes, with no account or purchase gate.
5. **Is AI in the Barrier→Focus workflow?** Partly; suggestions are available, but surface-by-surface confirmation flow needs real-user validation.
6. **Does AI have excessive permissions?** No direct write/timer/payment/delete capability is exposed.
7. **Does Minimum Action help users start?** Deterministic rules are specific and barrier-aware; real-user quality sampling remains needed.
8. **Is Focus timer trustworthy?** Foreground/pause semantics are tested; system-clock manipulation needs hardening.
9. **Does Reflection avoid fake ratings?** Yes, Skip persists null ratings.
10. **Are Insights real-data based?** Yes, deterministic local computation with data thresholds.
11. **Why not ChatGPT?** StudyLoop owns the verified task→timer→history loop and does not let AI invent records.
12. **Why not a normal timer?** It reduces start resistance before timing and preserves contextual learning evidence.
13. **Does free tier provide full core value?** Yes.
14. **Largest three release risks?** Debug signing, missing public privacy/support materials, unverified production AI/billing infrastructure.
15. **Should real users receive it now?** Yes, only as a closed Beta with clear local-fallback expectations; no public store release yet.
