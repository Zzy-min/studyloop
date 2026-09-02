# Product Requirements Document

## Product Summary

StudyLoop is a calm, offline-first Android application for university students who know they need to study but cannot get started. It intervenes before a conventional timer: the student identifies the current barrier, describes one task, chooses the task type and available time, and receives one deterministic starting action. A small dog provides quiet, nonjudgmental companionship during the session. Reflection data later helps the student discover which approaches make starting easier.

The complete immediate-help loop remains free and unlimited. RevenueCat Pro unlocks complete history and long-term pattern reports rather than blocking a student from beginning a study session.

## Product Goals

- Help a university student move from avoidance or paralysis to one concrete study action in under one minute.
- Make interruption and incomplete sessions useful data rather than failure states.
- Provide credible personal patterns only after enough local evidence exists.
- Demonstrate a meaningful RevenueCat entitlement lifecycle without weakening the free core experience.
- Deliver a visually distinctive, two-minute Next Gen demonstration centered on the dog companion and learned study patterns.

## Non-Goals

- Diagnosing or treating mental-health, attention, sleep, or medical conditions.
- Providing a generic AI assistant or model-generated study advice.
- Requiring accounts, profiles, cloud synchronization, or a backend.
- Blocking other applications or monitoring device usage.
- Adding social features, competitive streaks, leaderboards, or pet-raising mechanics.
- Supporting ordinary-track store publication or iOS in the initial Next Gen build.

## Target User

- University student preparing for final exams, practising programming, or writing an academic paper.
- Understands what broadly needs to be done but is blocked by uncertainty, overload, phone distraction, tiredness, or perfectionist preparation.
- Wants a small, credible next step rather than a large plan or motivational speech.
- May stop early or struggle repeatedly and must not be shamed by the interface.

## Experience Principles

- Direct: open on the real problem, not onboarding or account creation.
- Small: show one action at a time and allow it to shrink further.
- Nonjudgmental: report facts such as focused minutes without success/failure labels.
- Calm: use a fresh, light-blue, quiet-study-room atmosphere.
- Honest: do not claim a personal pattern before at least three valid records exist.
- Resilient: preserve the free core experience when offline or when RevenueCat is unavailable.

## Core User Journey

1. The application opens directly on “Why can’t you study right now?”
2. The user selects one current barrier.
3. The user enters a task, selects its type, and chooses 5, 10, 15, or 25 minutes.
4. StudyLoop generates one deterministic start card.
5. The user may reduce the card up to three times.
6. The user starts a focus interval with the dog resting nearby, or receives a rest recommendation when severe discomfort is reported.
7. Completion or early exit records actual focused time.
8. The user records actual difficulty, focus level, emotional change, and next action.
9. Recent history is available for free; after three valid records the product shows one evidence-based starter observation from the recent seven-day window.
10. Opening complete history or long-term insights presents the RevenueCat Pro paywall to a free user.

## Product States

### Dog Companion States

- Waiting: calm posture on the barrier-selection screen.
- Prompting: gently asks only for a course or project name when the user cannot formulate a task.
- Focusing: rests beside the timer without distracting animation.
- Completed: shows mild happiness after a completed interval.
- Interrupted: remains warm and neutral after an early exit.
- Resting: rests with the user when StudyLoop recommends a break.

The dog never displays disappointment, declining health, lost streaks, or unmet care needs.

### Study Record Validity

A valid record is a saved session containing a start date, barrier, task type, planned duration, actual focused minutes, and reflection. Completed and interrupted sessions may both be valid. A draft abandoned before focus begins is not included in pattern calculations.

### Emotional Change

Reflection records exactly one of:

- More at ease
- No change
- Worse

## Epics And User Stories

### Epic 1: Immediate Entry And Barrier Selection

#### Story 1.1 — Start without setup

As a student who is already struggling to begin, I want to reach the barrier question immediately so that setup does not become another form of procrastination.

Acceptance criteria:

- A fresh install opens directly on “Why can’t you study right now?”
- No nickname, account, permission, tutorial carousel, or profile is required first.
- The screen shows the five barrier choices and the waiting dog.
- Closing and reopening before beginning a session returns to the same entry screen.

#### Story 1.2 — Choose one current barrier

As a student, I want to identify what is stopping me now so that the starting action responds to the actual obstacle.

Acceptance criteria:

- Exactly one barrier can be selected at a time: uncertain start, overload, phone distraction, tiredness, or perfectionist preparation.
- Selecting a barrier visibly marks it and enables the next action.
- Selecting tiredness opens one follow-up choice: ordinary tiredness or severe discomfort (including headache or clear physical discomfort).
- Ordinary tiredness continues to task entry; severe discomfort opens the rest experience and does not permit starting a timer from that branch.
- Returning from task entry preserves the selected barrier.
- Changing the barrier before focus begins updates the later start card when regenerated.

### Epic 2: Task Capture And Classification

#### Story 2.1 — Describe the task with minimal effort

As a student, I want to describe what I need to advance so that StudyLoop can produce a relevant first action.

Acceptance criteria:

- The user can enter a short free-text task.
- Blank input cannot generate a normal start card.
- If the user indicates that describing the task is too difficult, the dog switches to the prompting state and asks only for a course or project name.
- Supplying only that name is sufficient to continue with a generic smallest action for the chosen task type.
- Input remains available when navigating back before the timer begins.

#### Story 2.2 — Select task type

As a student, I want to classify the task so that deterministic guidance matches the work.

Acceptance criteria:

- Available top-level types are final-exam revision, programming practice, and academic paper writing.
- Final-exam revision requires one subtype: memory, calculation, or understanding.
- Programming practice and paper writing do not show exam subtypes.
- Changing the top-level type clears any incompatible subtype and requires a valid replacement before continuing.

#### Story 2.3 — Select available time

As a student, I want to choose a realistic session length so that the action fits my current capacity.

Acceptance criteria:

- The only standard choices are 5, 10, 15, and 25 minutes.
- One duration must be selected before generating a card.
- Choosing ordinary tiredness defaults to 10 minutes but still permits another standard choice.
- Severe discomfort bypasses card generation and leads to the rest experience.

### Epic 3: Start Card And Task Reduction

#### Story 3.1 — Receive one deterministic action

As a student, I want one concrete starting action so that I do not need to design a complete plan.

Acceptance criteria:

- The card is generated from the selected barrier, task type/subtype, task text, duration, and reduction level.
- The card contains one primary action, a short rationale, and the planned focus duration.
- The same inputs and reduction level produce the same card content.
- The card does not claim to use AI and does not require a network connection.
- Each supported task type follows the reduction rules defined in `scope.md`.

#### Story 3.2 — Make the action smaller

As a student who still feels blocked, I want to shrink the action so that beginning feels possible.

Acceptance criteria:

- “Make it smaller” is available at reduction levels zero through two.
- Each tap advances exactly one level and replaces the primary action with a smaller observable action.
- Previous actions are not presented as failures.
- After the third reduction, the control is replaced by language that this smallest useful action is enough for today.
- The user can start that action or return to edit the task.

### Epic 4: Focus And Rest

#### Story 4.1 — Focus with quiet companionship

As a student, I want a calm timer and companion so that I can work without additional information overload.

Acceptance criteria:

- Starting the card opens a timer for the selected duration.
- The screen shows the current action, remaining time, pause/exit controls, and the dog in focusing state.
- The dog animation, if present, remains subtle and does not require interaction.
- Completing the timer moves to reflection and uses the completed dog state.
- Core timer behavior works offline.

#### Story 4.2 — Return after the application was backgrounded

As a student, I want control over what happened while the application was away so that background time is not falsely counted as focus.

Acceptance criteria:

- Returning to an active session presents “Continue this session” and “Save focused time.”
- Background elapsed time is not added to actual focused minutes.
- Continue resumes from the remaining foreground-counted duration.
- Save ends the interval and opens reflection with the actual foreground-focused minutes.
- Dismissing the prompt cannot silently mark the interval complete.

#### Story 4.3 — Stop early without judgment

As a student who cannot continue, I want my effort recorded accurately without being labeled a failure.

Acceptance criteria:

- Exiting early asks whether to save the focused minutes or return to the timer.
- Saving uses the interrupted dog state and opens reflection.
- History displays actual minutes and neutral wording such as “Ended early.”
- No lost-streak, failure, disappointed-dog, or negative-score message appears.

#### Story 4.4 — Rest when studying is inappropriate

As a tired or unwell student, I want StudyLoop to permit rest so that it does not pressure me to continue through clear discomfort.

Acceptance criteria:

- Selecting severe fatigue, headache, or clear physical discomfort does not start a timer.
- The screen shows the resting dog, a nonmedical rest suggestion, and actions to return home or reconsider later.
- After two consecutive valid sessions with very low focus or worsening emotion, the next flow recommends a longer break or stopping for the day.
- The copy does not name or diagnose a condition and does not promise treatment.

### Epic 5: Reflection

#### Story 5.1 — Record an honest outcome

As a student, I want a short reflection so that future patterns use what actually happened.

Acceptance criteria:

- Reflection captures actual difficulty, focus level, emotional change, and next action.
- Emotional change uses only More at ease, No change, or Worse.
- Actual focused minutes and completion/interruption state are already populated and visible.
- Required reflection fields prevent saving until answered; the optional next-action text may be left blank.
- Saving creates one valid local record and opens the session summary.

#### Story 5.2 — Assign the record to a date

As a student reviewing history, I want consistent daily grouping so that sessions crossing midnight are understandable.

Acceptance criteria:

- A session is assigned entirely to its local start date.
- A session crossing midnight is not split into two records or two daily totals.
- The detail view may show actual start and end timestamps while keeping the start-date grouping.

### Epic 6: History And Personal Patterns

#### Story 6.1 — View recent history for free

As a student, I want to see recent effort so that I can recognize progress without subscribing.

Acceptance criteria:

- Free users can view all valid records from the most recent seven calendar days.
- Each row shows date, task label, task type, actual focused minutes, and completed/interrupted state using neutral language.
- An empty history shows a warm message, the waiting dog, and a direct action to begin the first session.
- History remains available offline.

#### Story 6.2 — Delete an incorrect record

As a student, I want to remove an incorrect record so that statistics and patterns remain meaningful.

Acceptance criteria:

- Record detail includes a delete action.
- Deletion requires explicit confirmation naming the irreversible local effect.
- Cancelling leaves the record unchanged.
- Confirming removes the record and immediately recalculates summaries, progress, and patterns.
- If deletion lowers valid-record count below three, the report returns to collection-progress state.

#### Story 6.3 — See collection progress before patterns

As a student with limited data, I want honest progress feedback so that the application does not overstate what it knows.

Acceptance criteria:

- With zero records, the report shows the history empty state rather than a personal conclusion.
- With one or two valid records, the report states the exact number collected and how many more are needed.
- The page may show a clearly labeled example report explaining future value.
- Example content is never phrased as the user’s own result.
- No deterministic personal conclusion appears before three valid records.

#### Story 6.4 — View evidence-based patterns

As a student with enough records, I want to see which approaches help me start so that I can choose better future sessions.

Acceptance criteria:

- At three valid records, the free report must show one starter observation calculated from records within the most recent seven calendar days.
- The starter observation uses a single dimension: the duration or barrier associated with the strongest factual difference in completion, focused minutes, or emotional improvement.
- If the recent records contain no meaningful comparison, the free report shows a factual observation such as the most-used duration and its evidence count instead of inventing a difference.
- Patterns compare only locally recorded facts such as barrier, task type, planned duration, actual focused minutes, completion state, focus level, and emotional change.
- Each displayed insight includes the evidence count or plain-language basis.
- The report avoids causal or medical claims.
- Deleting a contributing record immediately changes or removes affected insights.

The free report is limited to this single recent-window observation. Pro unlocks the complete history, multiple simultaneous comparisons, task-type and barrier cross-comparisons, and trends beyond seven days.

### Epic 7: RevenueCat Pro

#### Story 7.1 — Discover Pro without blocking immediate help

As a free user, I want to understand what Pro adds while retaining the complete study loop.

Acceptance criteria:

- Barrier selection, task reduction, timer, reflection, recent history, and dog companion never require Pro.
- Accessing history older than seven days, more than the single free starter observation, multi-dimensional comparisons, or trends beyond seven days opens the paywall.
- The paywall explains that Pro unlocks full history and long-term patterns.
- Closing the paywall returns to the originating page with its state preserved.

#### Story 7.2 — Purchase Pro

As a user, I want successful purchase to unlock Pro immediately.

Acceptance criteria:

- A successful RevenueCat purchase refreshes entitlement state without requiring an application restart.
- The originating locked content becomes available after entitlement activation.
- Existing local records are preserved before and after purchase.
- Test Store purchase behavior is visibly demonstrable in the Next Gen build.

#### Story 7.3 — Handle cancellation and errors differently

As a user, I want a cancelled purchase treated differently from a technical error so that I receive an accurate response.

Acceptance criteria:

- User cancellation returns to the paywall or originating page without an error banner.
- A purchase error keeps the same context and displays a retryable message.
- Neither case deletes records, changes the current study flow, or incorrectly grants Pro.
- RevenueCat unavailability does not block free functionality.

#### Story 7.4 — Restore purchases

As a returning purchaser, I want to restore Pro access.

Acceptance criteria:

- Restore is accessible from the paywall or settings.
- Successful restore refreshes entitlement state and unlocks Pro immediately.
- No restorable purchase produces a clear, nonblocking message.
- Restore errors preserve the current page and offer retry.

#### Story 7.5 — Handle entitlement loss

As a user whose entitlement is no longer active, I want my study data preserved while premium presentation is relocked.

Acceptance criteria:

- Entitlement loss never deletes or corrupts local records.
- Recent seven-day history and the complete free study loop remain available.
- Full-history and long-term-report views return to their locked presentation.
- Repurchase and restore remain available.

## Cross-Cutting Requirements

### Offline Behavior

- Barrier selection, task capture, deterministic cards, timer, reflection, recent history, deletion, and local report progress work without network access.
- Network failure is shown only where RevenueCat functionality is requested.
- No free workflow redirects to a generic connection-error screen.

### Accessibility And Tone

- Core actions have text labels and do not rely solely on color or dog expression.
- Focus, mood, and completion states remain understandable with animation disabled.
- Copy avoids “lazy,” “failed,” “bad,” punishment, streak loss, or moral judgment.
- Rest guidance remains clearly nonmedical.

### Privacy

- No nickname, email, school name, account, contacts, or social profile is required in the application.
- Study content and reflections remain local in the MVP.
- Public demo data must be synthetic and must not expose the participant’s academic email.

## What We Are Building

### Required For MVP

- All seven epics above, limited to their required acceptance criteria.
- English demo-ready experience.
- RevenueCat Test Store entitlement lifecycle.
- Public-repository-ready documentation and nonsecret configuration approach.

### Conditional If Schedule Allows

- Chinese localization beyond the English demonstration path.
- Custom start templates.
- Data export.
- Additional visual themes.
- Nonessential dog animation beyond the six required states.

## What We Would Add With More Time

- User-controlled template editing and additional deterministic task types.
- Optional encrypted backup or cross-device synchronization.
- More nuanced pattern confidence and longer time-window comparisons.
- Additional companion visual variants without care mechanics.
- Formal usability research with university students and accessibility testing across more devices.

## Submission Proof Points

- A fresh install reaches the barrier question immediately.
- One final-exam calculation task visibly shrinks into a smaller action.
- The dog changes from waiting to focusing to completed or interrupted without judgment.
- A completed reflection contributes to collection progress and, with seeded synthetic records, a personal pattern.
- A RevenueCat Test Store purchase unlocks the long-term report, while cancellation, failure, restore, and entitlement loss behave distinctly.
- The complete core workflow runs without an account, backend, external AI, or continuous network connection.

## Two-Minute Demo Acceptance

- Demonstrate the problem and direct first screen within the first 15 seconds.
- Show task selection and at least one reduction within 40 seconds.
- Show the dog companion during focus and the nonjudgmental reflection by 75 seconds.
- Show a three-record personal pattern by 95 seconds.
- Show the RevenueCat paywall and successful Pro unlock before 115 seconds.
- Reserve the remaining seconds for the Next Gen value statement; do not depend on restore-purchase footage if it threatens the two-minute limit.

## Product-Level Test Scenarios

- Fresh install opens directly on barrier selection.
- Task cannot proceed without a valid type, required subtype, duration, and minimum task/course input.
- Three reductions terminate at the smallest useful action.
- Background time is excluded and return presents the two explicit choices.
- Completed and interrupted sessions both save factual actual minutes.
- Emotional change accepts exactly the three defined states.
- Empty, one-record, two-record, and three-record report states render distinctly.
- Deleting a record recalculates summaries and can return the report below threshold.
- Cross-midnight session groups under its start date.
- Severe discomfort never starts the timer.
- Purchase success, cancellation, error, restore success, no-restorable-purchase, and entitlement loss each produce their specified visible outcome.
