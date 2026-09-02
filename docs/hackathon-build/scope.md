# Project Scope

## Project Name Candidates

- StudyLoop (confirmed working name)
- StartSmall (fallback English name)
- QuietStep (fallback English name)

## One-Line Summary

StudyLoop is a calm, offline-first Flutter app that helps university students turn study paralysis into one small action, complete a short focus session with a gentle dog companion, and learn which approaches make starting easier.

## Target User

- Primary user: university students who know they need to study but struggle to begin.
- Initial study situations: final exam revision, programming practice, and academic paper writing.
- Primary emotional need: reduce the sense that starting is overwhelming or requires perfect readiness.
- Desired outcome after one session: “Starting was not as hard as I thought.”

## Problem

Many study tools assume the user is already ready to plan or focus. StudyLoop addresses the earlier moment when a student is overwhelmed, tired, distracted, uncertain where to begin, or stuck preparing perfectly instead of doing the work.

The product is not a medical or psychological diagnostic tool. It offers reflective study support and recommends rest when the user reports severe discomfort or repeatedly deteriorating focus and mood.

## Core Workflow

1. Open directly on “Why can’t you study right now?”
2. Choose one current barrier:
   - I do not know where to start.
   - There is too much to do.
   - I keep reaching for my phone.
   - I am too tired to think clearly.
   - I keep preparing perfectly instead of starting.
3. Enter the task. If the user cannot describe it, the dog asks only for a course or project name.
4. Choose a task type:
   - Final exam revision
     - Memory
     - Calculation
     - Understanding
   - Programming practice
   - Academic paper writing
5. Choose available time: 5, 10, 15, or 25 minutes.
6. Generate a deterministic start card with one concrete action.
7. If it still feels too hard, tap “Make it smaller.” After three reductions, offer the smallest useful action and explicitly allow the user to stop after it.
8. Run a Pomodoro-inspired focus interval while the dog quietly accompanies the student.
9. If the user exits early, save actual focused minutes without labeling the session a failure.
10. Reflect on actual difficulty, focus level, emotional change, and the next action.
11. Show recent history and patterns that reveal which starting approaches work best.

## Deterministic Task-Reduction Rules

### Final Exam Revision — Memory

- Locate one small section or concept.
- Recall what is known without notes.
- Check the source and record one missed point.
- Smallest action: open the material and name one concept to recall.

### Final Exam Revision — Calculation

- Choose one representative problem.
- Read the conditions and identify the first operation or formula.
- Complete only the first sub-step before expanding.
- Smallest action: copy the known values and write the likely formula.

### Final Exam Revision — Understanding

- Choose one concept.
- Explain it in one or two sentences from memory.
- Compare against the source and identify the unclear link.
- Smallest action: write one question about what is not understood.

### Programming Practice

- State the expected behavior.
- Open the relevant project, exercise, or file.
- Reproduce or define one tiny case.
- Make one testable change.
- Smallest action: open the project and write the expected input and output for one case.

### Academic Paper Writing

- Choose one section or claim.
- Write an intentionally rough sentence or bullet.
- Attach one supporting fact or source placeholder.
- Smallest action: write a single imperfect sentence describing the point.

## Focus And Rest Boundary

- Standard choices remain 5, 10, 15, and 25 minutes.
- Ordinary fatigue defaults to a 10-minute focus interval followed by a 5-minute break.
- Severe fatigue, headache, or clear physical discomfort leads to a rest suggestion rather than a timer.
- Two consecutive sessions with very low focus or worsening emotion trigger a suggestion to stop for the day or take a longer break.
- The app must not diagnose ADHD, depression, anxiety, sleep disorders, or other conditions.

## Dog Companion Scope

- One fixed small dog character.
- States:
  - Calmly waiting before the task begins.
  - Gently prompting for only a course or project name when input feels difficult.
  - Resting beside the user during focus.
  - Showing mild happiness after completion.
  - Remaining warm and neutral after interruption; never disappointed or punitive.
  - Resting together when the app recommends a break.
- The dog communicates companionship and emotional state only.
- No levels, currency, feeding, inventory, cosmetic store, health meter, streak punishment, or pet-care loop in the MVP.

## What We Are Building

- Flutter Android application.
- Offline-first local persistence.
- Six principal product surfaces:
  1. Barrier selection
  2. Task type, task input, and available time
  3. Start card and task reduction
  4. Focus timer with dog companion
  5. Reflection
  6. History, patterns, and Pro report
- Deterministic task generation with no external AI dependency.
- Free core study loop with no daily session limit.
- RevenueCat integration using Test Store for development and Next Gen demonstration.
- Purchase, cancellation, failure, restoration, entitlement activation, and entitlement-loss behavior.
- English demo-ready copy, with Chinese localization if time permits.
- Public open-source repository with license and reproducible setup instructions.

## Free And Pro Boundary

### Free

- Unlimited barrier selection, start cards, task reductions, focus sessions, and reflections.
- Recent seven-day history.
- Basic completion and focused-minute summaries.
- Dog companion in all core sessions.

### Pro

- Full history beyond seven days.
- Long-term pattern reports.
- Personalized comparisons across barriers, task types, focus duration, and emotional change.
- Custom starting templates if schedule permits.
- Data export if schedule permits.
- Additional visual themes if schedule permits.

The paywall must not block a student from starting or completing a basic study session.

## What We Are Not Building

- Generic AI chatbot or model-backed task generation.
- User accounts, authentication, backend, or cloud synchronization.
- Social feed, friends, leaderboards, group study, or public profiles.
- Website or application blocker.
- School timetable or educational-system integration.
- Push-notification platform integration.
- Complex gamification or pet raising.
- Medical or mental-health diagnosis.
- iOS release or ordinary-track store publication for the initial Next Gen submission.
- RevenueCat Ads, Stripe funnel, OneSignal, or other sponsor SDKs added solely to enter more categories.

## Inspiration And References

- Public student discussions repeatedly describe inability to start, task overload, phone distraction, exhaustion, and perfectionist preparation as distinct barriers.
- Pomodoro contributes a familiar focus/rest rhythm, but StudyLoop differentiates itself by intervening before the timer starts.
- The intended atmosphere is a fresh, bright, quiet study room with a light-blue palette.
- The dog provides emotional warmth without turning the product into a game.

## Demo Path

1. Open directly on the barrier question.
2. Choose “There is too much to do.”
3. Enter a final-exam calculation task and select 15 minutes.
4. Generate a start card, then demonstrate one “Make it smaller” reduction.
5. Show the dog resting beside the user during the focus timer.
6. End early or complete the interval and show nonjudgmental reflection.
7. Show the dog’s gentle response and a learned personal pattern.
8. Open the long-term insight screen, display the RevenueCat paywall, simulate purchase, and unlock Pro insights.
9. Briefly demonstrate restore-purchase behavior if time permits.

Primary demo highlight: the dog’s quiet companionship and emotional states.

Secondary demo highlight: accumulated reflections revealing a useful personal study pattern.

## Submission Story

Most productivity tools begin with plans and timers. StudyLoop begins one step earlier: the emotionally difficult moment before a student starts. It transforms a vague, intimidating task into one small action, stays beside the student without judgment, and turns honest reflection into personalized evidence about what helps them begin.

The monetization design preserves the complete core study loop for free. RevenueCat Pro unlocks longer-term value—history and pattern insight—rather than charging students for immediate help.

Primary award: Next Gen Award.

Secondary fit: RevenueCat Design Award and RevenueCat Peace Prize. HAMM should be targeted only if the final paywall and entitlement story are strong enough to justify it.

## Time Budget And Cut Order

- Available capacity: approximately 18 hours per week.
- Planning capacity through late September: about 90 reliable implementation hours after contingency.
- Feature freeze target: September 20, 2026.
- Internal submission-ready target: September 29, 2026 Beijing time.

If schedule slips, cut in this order:

1. Additional themes.
2. Data export.
3. Custom starting templates.
4. Nonessential animation.
5. Chinese localization beyond the English demo path.

Never cut the core task-reduction loop, reflection, nonjudgmental interruption handling, RevenueCat entitlement lifecycle, public repository hygiene, or the two-minute demo.

