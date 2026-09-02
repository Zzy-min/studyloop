# StudyLoop Android Real-Device Acceptance

Run this on an Android device installed from the internal or closed Play track.
Capture a screenshot or screen recording and the relevant non-sensitive console
event for every passing item.

## Golden Path

- Fresh install reaches the study entry screen and an actual text field opens the
  system keyboard.
- A learner selects a barrier, enters a task, creates a start card, starts a
  focus session, completes a reflection, and sees the saved history record.
- The AI companion returns a protected gateway reply when the Play Integrity
  verdict is valid; turn off network and confirm the local fallback still works.
- The monthly Pro purchase grants entitlement `pro`; after force-stop, launch and
  explicit restore both keep the entitlement.

## Bad Path

- Invalid Play Integrity, expired session, 401, 429, network failure, DeepSeek
  timeout, malformed model JSON, and unavailable product each preserve the core
  study flow and show a recoverable state.
- Cancelled purchase and failed restore do not grant Pro.
- Reopen text fields after navigating between entry, task, chat, and reflection;
  confirm no keyboard/input regression.

## Release Record

Record device model, Android version, Play track/build version, AAB SHA-256,
timestamp, and evidence path in `STUDYLOOP_PRODUCTION_RELEASE_BLOCKERS.md`.
