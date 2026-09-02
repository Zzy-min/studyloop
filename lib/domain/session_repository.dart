import 'models.dart';

class StartFocusResult {
  const StartFocusResult({
    required this.sessionId,
    required this.plannedDuration,
    required this.startTime,
  });

  final String sessionId;
  final Duration plannedDuration;
  final DateTime startTime;
}

class FinishSessionResult {
  const FinishSessionResult({
    required this.sessionId,
    required this.actualDuration,
    required this.completedPlannedDuration,
  });

  final String sessionId;
  final Duration actualDuration;
  final bool completedPlannedDuration;
}

class StudyReflectionInput {
  const StudyReflectionInput({
    required this.difficulty,
    required this.focus,
    required this.mood,
    this.nextAction = '',
  });

  final int difficulty;
  final int focus;
  final MoodChange mood;
  final String nextAction;
}

abstract interface class FocusSessionRepository {
  Future<StartFocusResult> startSession(SessionDraft draft);
  Future<void> pauseSession();
  Future<void> resumeSession();
  Future<FinishSessionResult> finishSession();
  Future<StudyRecord> saveReflection(StudyReflectionInput input);
  Future<ActiveTimerSnapshot?> getActiveSnapshot();
  Future<void> clearActiveSession();
}
