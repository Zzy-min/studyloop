enum StudyBarrier {
  uncertainStart,
  overload,
  phoneDistraction,
  tiredness,
  perfectionism,
}

enum FatigueSeverity { ordinary, severe }

enum TaskType {
  examRevision,
  homework,
  programmingPractice,
  paperWriting,
  reading,
  memorization,
  preview,
  project,
  other,
}

enum ExamSubtype { memory, calculation, understanding }

enum SessionOutcome { completed, interrupted }

enum MoodChange { moreAtEase, unchanged, worse }

enum DogState { waiting, prompting, focusing, completed, interrupted, resting }

enum EntitlementState { unknown, free, pro }

class StartCard {
  const StartCard({required this.action, required this.rationale});
  final String action;
  final String rationale;
}

class SessionDraft {
  const SessionDraft({
    this.barrier,
    this.fatigueSeverity,
    this.taskText = '',
    this.taskType,
    this.examSubtype,
    this.plannedSeconds = 900,
    this.reductionLevel = 0,
    this.card,
  });

  final StudyBarrier? barrier;
  final FatigueSeverity? fatigueSeverity;
  final String taskText;
  final TaskType? taskType;
  final ExamSubtype? examSubtype;
  final int plannedSeconds;
  final int reductionLevel;
  final StartCard? card;

  bool get isSevere =>
      barrier == StudyBarrier.tiredness &&
      fatigueSeverity == FatigueSeverity.severe;
  bool get isValid =>
      barrier != null &&
      taskText.trim().isNotEmpty &&
      taskType != null &&
      (taskType != TaskType.examRevision || examSubtype != null) &&
      plannedSeconds > 0 &&
      !isSevere;

  SessionDraft copyWith({
    StudyBarrier? barrier,
    FatigueSeverity? fatigueSeverity,
    bool clearFatigue = false,
    String? taskText,
    TaskType? taskType,
    ExamSubtype? examSubtype,
    bool clearSubtype = false,
    int? plannedSeconds,
    int? reductionLevel,
    StartCard? card,
    bool clearCard = false,
  }) => SessionDraft(
    barrier: barrier ?? this.barrier,
    fatigueSeverity: clearFatigue
        ? null
        : fatigueSeverity ?? this.fatigueSeverity,
    taskText: taskText ?? this.taskText,
    taskType: taskType ?? this.taskType,
    examSubtype: clearSubtype ? null : examSubtype ?? this.examSubtype,
    plannedSeconds: plannedSeconds ?? this.plannedSeconds,
    reductionLevel: reductionLevel ?? this.reductionLevel,
    card: clearCard ? null : card ?? this.card,
  );
}

class ActiveTimerSnapshot {
  const ActiveTimerSnapshot({
    required this.draft,
    required this.accumulatedSeconds,
    required this.remainingSeconds,
    required this.startedAt,
    required this.lastSavedAt,
  });
  final SessionDraft draft;
  final int accumulatedSeconds;
  final int remainingSeconds;
  final DateTime startedAt;
  final DateTime lastSavedAt;
}

class StudyRecord {
  const StudyRecord({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.startDate,
    required this.barrier,
    required this.taskText,
    required this.taskType,
    this.examSubtype,
    required this.plannedSeconds,
    required this.actualSeconds,
    required this.outcome,
    this.difficulty,
    this.focus,
    this.moodChange,
    this.nextAction = '',
    this.synthetic = false,
  });
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final DateTime startDate;
  final StudyBarrier barrier;
  final String taskText;
  final TaskType taskType;
  final ExamSubtype? examSubtype;
  final int plannedSeconds;
  final int actualSeconds;
  final SessionOutcome outcome;
  final int? difficulty;
  final int? focus;
  final MoodChange? moodChange;
  final String nextAction;
  final bool synthetic;
}

class Insight {
  const Insight(this.text, this.evidenceCount);
  final String text;
  final int evidenceCount;
}

TaskType parseTaskType(String name) {
  for (final type in TaskType.values) {
    if (type.name == name) return type;
  }
  return switch (name) {
    'examReview' => TaskType.examRevision,
    'coding' => TaskType.programmingPractice,
    'writing' => TaskType.paperWriting,
    _ => TaskType.other,
  };
}
