# StudyLoop UI / UX Audit

Date: 2026-09-01
Device: vivo V2458A (`PD2415M`), 1260 x 2800, package `com.zzy.studyloop`
Locales captured: Chinese (primary live path), English (Home / Focus / History / Reflection / Task)
Source of truth: live screenshots and UI dumps under `work/`, plus current source after this round's copy/visual fixes.

Live captures were taken from the currently installed APK. Several source-only polish items below are **not yet on the device**. The report distinguishes `live` vs `source-fixed`.

---

## Executive Summary

| Dimension | Score |
| --- | --- |
| UI 完成度 | 82 |
| Interaction 完成度 | 84 |
| Responsive | 74 |
| Accessibility | 72 |
| Visual Consistency | 78 |
| Product Fit | 86 |

StudyLoop already feels like a calm start companion rather than a KPI dashboard. Welcome, Home, Focus, Reflection, History, Insights empty, Profile, and Paywall all exist and can be completed on a real Android phone. The core path is short, the tone is non-punitive, and Pro stays off the first screen.

It is not yet visually finished. English barrier labels still truncate on a 5-column row, Home always shows a waiting Corgi even after a session, Focus's end CTA was too red on the installed APK, and there are no golden tests for 360 / 390 layouts. None of those block starting or ending a session.

**Final recommendation: READY WITH MINOR POLISH**

Reason: no P0 interaction dead-ends were found on device. Remaining issues are copy truncation, companion-state honesty, leftover blue in chat, and missing visual regression coverage.

---

## P0 Issues

None found on the live path.

- Welcome CTA is tappable.
- Home can select a barrier and enter Task.
- Focus can pause, resume, and end.
- End dialog does not use failure language.
- Paywall can be dismissed with Back / 暂不需要.
- Bottom navigation reaches Home / Records / Insights / Profile.

---

## P1 Issues

### P1-1 English barrier labels truncate on Home

- Page: Home
- Repro: English locale, first viewport.
- Live: `Overlo…`, `Prepar…` on the five compact chips (`work/device-home.png`).
- Impact: the first decision on Home is unreadable in English.
- Suggestion: shorter labels. Source now uses `Too much` / `Prep` (`lib/l10n/app_strings.dart`). Not on the installed APK yet.

### P1-2 Home empty state still looks like a ready action

- Page: Home
- Repro: cold start, no task written.
- Live: empty card still shows `预计专注 15 分钟` and `难度预估 中等`, plus a disabled `继续` (`work/device-home-zh.png`, `work/device-resume.png`).
- Impact: looks like a generated micro-action before the user named anything.
- Suggestion: hide duration/difficulty until `canStart` is true; CTA should say `写下任务` / `Write a task`.
- Source-fixed: chips are gated on `canStartSuggested`; CTA uses `writeTaskCta`. Device still shows the old APK.

### P1-3 Task title overflows the AppBar in English

- Page: Task
- Repro: open `/task` in English.
- Live: `Name one thing to move fo…` (`work/device-task.png`, `work/device-ready-card.png`).
- Impact: the page identity is cut off.
- Source-fixed: AppBar title is now `Name one task` / `写下任务`, with ellipsis on `PageFrame`.

### P1-4 Companion card ignores session state

- Page: Home, Task, Reflection, Summary
- Live: Home always says `等待中` / `Waiting` even after a completed session (`work/device-home-zh.png`). Reflection after an early end still shows waiting copy plus a completed-looking Corgi (`work/device-reflection.png`). Summary also keeps `Waiting` (`work/device-summary.png`).
- Impact: the companion stops matching the product moment.
- Source-fixed: `DogCompanion` now uses `companionCushionMessage(state)` / `companionStatus(state)`. Home still hardcodes `DogState.waiting` in `entry_screen.dart`, so Home honesty is not fully done.

### P1-5 Focus end CTA reads as a danger action on device

- Page: Focus
- Live: full-width salmon `End & Save` (`work/device-focus-before.png`).
- Impact: ending early looks like quitting / failing, against the product tone.
- Dialog copy is already good: `End this session?` / `You can save the focused time without calling it a failure.` (`work/device-end-dialog.xml`).
- Source-fixed: bottom CTA is now `SecondaryButton`, not salmon `PrimaryButton`.

### P1-6 Keyboard covers Task duration and CTA

- Page: Task
- Live: focused name field, IME covers `Available time` and `Create my start card` (`work/device-task.png`).
- Impact: first-run users may not see the primary action until they dismiss the keyboard.
- Suggestion: keep `resizeToAvoidBottomInset`, auto-scroll the CTA into view on focus, and use `keyboardDismissBehavior.onDrag`.

### P1-7 No 360 / large-font live pass

- Scope: Welcome, Focus, Paywall, Reflection.
- Evidence: live device is 1260 x 2800. Requested 360 x 800, 390 x 844, 412 x 915, and 1.3x / 1.5x font were not run on hardware this round.
- Impact: English truncation and Task title overflow already appear on a large phone; small screens will be tighter.
- Suggestion: golden tests at 360 and 390 before calling UI done.

---

## P2 Issues

### P2-1 History puts a primary Insights CTA above the list

- Live: `View patterns` is the first, largest button (`work/device-history.png`).
- Impact: Records looks like a gateway to Insights, not a scannable log.
- Suggestion: demote to text/tonal, keep the list first.

### P2-2 Paywall still uses a sales-card treatment

- Live: blue gradient hero, white feature cards, green subscribe (`work/device-paywall-live.png`).
- Copy is aligned with the product boundary: core loop and history stay free; Pro unlocks 3-month / all-time comparisons.
- Source-fixed: hero is now sage `primaryDark`, not blue gradient. Feature cards remain.

### P2-3 Settings preview buttons compete with restore

- Live APK: two giant bilingual green buttons, `查看欢迎与起步页 (Welcome Screen)` (`work/device-profile-zh.png`).
- Source-fixed: they are `TextButton.icon` (`查看欢迎页` / `Preview welcome`). Device not rebuilt.

### P2-4 Focus task card showed a dead chevron

- Live: task card has `>` but no tap (`work/device-focus-before.png`).
- Source-fixed: `StudyCard.onTap` now opens `/task`.

### P2-5 Barrier selected state is weak

- Live: selected chip uses a thicker green border, no checkmark (`work/device-home.png`).
- Hit area is compact. Tests rely on a 1px invisible full-label overlay.
- Suggestion: add a check or stronger fill; keep the accessible label.

### P2-6 Reflection still has mixed-language residue on device

- Live: `3分 · Moderate` (`work/device-reflection.png`).
- Source-fixed: Chinese is `3 分 · 中等`; English shows the descriptor only.

### P2-7 Chat UI still uses leftover blue

- Files: `corgi_chat_dialog.dart`, `corgi_chat_screen.dart`, unused `circular_timer.dart`.
- Impact: chat feels like a second design system.
- Not changed this round to keep chat behavior untouched.

### P2-8 White-noise control is a dead end with a snackbar

- Live: music icon on Focus.
- Source: tooltip added; tap still shows "coming soon".
- Suggestion: hide until the feature exists, or keep it clearly secondary.

### P2-9 Insights empty state is good, but first screen is sparse

- Live: empty card, rule accordion, Pro CTA (`work/device-insights-live.png`).
- No fake 0% donut. That is correct.
- 3-month / All are locked with a lock icon, not color-only.

---

## P3 Issues

- Greeting uses a waving emoji; otherwise emoji use is light.
- Companion chat badge was `💬 和小狗聊聊`; source now uses `聊聊` / `Chat`.
- Focus timer digits are large enough; the inner Corgi is a bit busy but not covering the time.
- History cards are scannable. Dates are missing; subtitle is duration + outcome.
- No confetti, no streak shame, no "you failed".
- System status bar is light and matches the cream background.
- WeChat / fund banners overlayed Welcome and Home during capture; that is the OS, not the app.

---

## Page Review

### Welcome

Calm, one primary CTA (`开始你的学习之旅`), secondary language, quiet privacy line. Logo was covered by a system banner in `work/device-welcome-zh.png`, but dump shows `StudyLoop` at the top. Corgi is the visual center, which is acceptable on Welcome. Not a login or ad page.

### Home

Hierarchy is right: greeting, barrier question, five chips, micro-action, companion, nav. First-run still over-promises a 15-minute medium action. English chips truncate. CTA `继续` on the live APK is the worst copy issue; source now says `写下任务`. Companion is correctly secondary.

### Task

Simple form: name, type, duration chips, one primary CTA. Keyboard overlap is the main interaction bug. English AppBar overflow is the main visual bug. Corgi on this page is larger than needed.

### Start card

Clear one-action card, `Make it smaller` is secondary, `Start focusing` is primary. Fits the product.

### Focus

Quiet enough. Timer is the center. Pause is inside the ring and readable. Foreground-only caption is present. Installed APK's salmon end button is the tone problem; source is now a secondary button. Close and music icons now have tooltips in source.

### End dialog

Copy is non-punitive. Actions are `Return to timer` and `Save focused time`, not OK / Cancel. Good.

### Reflection

3-5 choice pills, skip exists (below the fold). Corgi waiting copy after an early end is dishonest. Next-action field is optional and should stay that way.

### Summary

Light completion, no XP. `You recorded what actually happened. No score, no judgment.` matches the product. Companion status still says Waiting on live.

### History

Easy to scan. Synthetic demo rows are labeled. Primary `View patterns` is too strong. Empty state exists in source with a start CTA.

### Insights

Empty state is honest and calm. Locked long ranges are explicit. Pro CTA is one secondary button, not a blocking modal. Good product-fit.

### Profile / Settings

Language segmented control is clear. Restore is present and secondary. Live preview buttons were too loud; source is quieter. Debug seed stays behind `kDebugMode`.

### Paywall

Value is now long-term insights, not history. Dismiss path is obvious. Blue hero is the remaining visual mismatch; source uses sage.

---

## Design System Review

- Colors: sage / cream / white is the intended system (`StudyLoopColors`). Live Paywall, chat, and a few cards still used blue (`#1d68eb`, `#dbeafe`, `#eff6ff`). This round migrated Paywall hero, start card, summary, history empty, mood chips, settings language, and rating shadow.
- Type: page / section / card / body / caption exist. Timer digits are tabular.
- Radius: pills for CTA, ~16-20 for cards. Generally consistent.
- Shadows: subtle. Paywall live shadow was too sales-like.
- Buttons: one primary per page is mostly true. History and live Settings were the exceptions.
- Icons: Material rounded, 14 / 18 / 20 / 22 / 24. A few 10.5 / 12.5 font sizes remain.
- Corgi: Welcome large, Home medium, Focus inside the ring. Correct scale. State mapping is the remaining honesty issue.

---

## Interaction Review

- Clicks: Material ripple on buttons and nav. Compact barrier chips have no ripple, only border change.
- Scroll: Home / Insights / History / Settings scroll under the nav. Insights empty does not fight nested chart gestures.
- Navigation: 4-tab bar, active state is clear.
- Back: Focus uses `PopScope` and opens the end dialog. Paywall dump shows a Back affordance. Bottom sheets / dialogs were not fully Back-tested this round.
- Animation: 180-200ms on chips and range pills. No 600ms transitions observed.
- Loading: Insights uses a centered spinner. Buttons do not show in-button loading on purchase/save.
- Empty: Insights empty is the best in the app. History empty exists in source. Home empty is the weakest.

Shortest start path on device:

1. Welcome CTA
2. Choose barrier
3. Write task
4. Pick type / duration
5. Create card
6. Start focusing

That is longer than "tap start", but it is the product: name one thing, then begin. Not a blocker.

---

## Responsive Review

| Viewport | Evidence | Result |
| --- | --- | --- |
| Live 1260 x 2800 | Welcome, Home, Focus, History, Insights, Paywall, Settings | No overflow except Task title and English chips |
| 360 x 800 | not captured | unknown; English chips will be worse |
| 390 x 844 | not captured | unknown |
| 412 x 915 | closest to live | usable |
| English | Home, Focus, History, Reflection, Task | truncation on Home chips and Task title |
| Large font | not captured | unknown; `textScaleFactor` is not locked |

---

## Fixes Applied

This round, in source:

- Home empty CTA: `Continue` / `继续` -> `Write a task` / `写下任务`
- Home duration/difficulty chips hidden until a real action can start
- Home language / settings tooltips
- Focus close / music tooltips
- Focus end CTA changed from salmon primary to secondary
- Focus task card chevron now opens `/task`
- Task AppBar shortened; `PageFrame` titles ellipsize
- Companion copy follows `DogState` (prompting / focusing / completed / interrupted / resting)
- Chat badge on the card shortened to `聊聊` / `Chat`
- Settings preview buttons demoted to text buttons
- Rating labels no longer mix `3分 · Moderate`
- Paywall hero moved off blue gradient
- Start card / summary / history empty / mood / language selection moved off leftover blue
- Tests updated for the new Home / Task / companion copy

Not rebuilt onto the vivo APK in this pass. Live screenshots still show the previous build.

---

## Residual Risk

- Home companion is still hardcoded to `DogState.waiting`.
- Chat screens remain blue.
- No golden tests.
- No 360 / font-scale hardware pass.
- Installed APK != current source.

---

## Final Recommendation

**READY WITH MINOR POLISH**

The Android UI is usable, calm, and complete enough for a local demo. Rebuild the APK, confirm English Home chips and the quieter Focus end button on device, then add 360-wide goldens. Do not block the learning loop on remaining polish.
