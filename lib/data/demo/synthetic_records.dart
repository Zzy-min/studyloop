import '../../domain/models.dart';

const syntheticDemoPrefix = 'demo-';

List<StudyRecord> labeledSyntheticRecords(DateTime now) {
  return [
    for (var i = 0; i < 4; i++)
      StudyRecord(
        id: '$syntheticDemoPrefix$i',
        startedAt: now.subtract(Duration(days: i, minutes: 15)),
        endedAt: now.subtract(Duration(days: i, minutes: 7 - i)),
        startDate: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: i)),
        barrier: i.isEven ? StudyBarrier.overload : StudyBarrier.uncertainStart,
        taskText: 'Synthetic exam session ${i + 1}',
        taskType: TaskType.examRevision,
        examSubtype: ExamSubtype.calculation,
        plannedSeconds: i.isEven ? 600 : 900,
        actualSeconds: (8 + i) * 60,
        outcome: i == 3 ? SessionOutcome.interrupted : SessionOutcome.completed,
        difficulty: 3,
        focus: 4,
        moodChange: i == 3 ? MoodChange.unchanged : MoodChange.moreAtEase,
        nextAction: 'Synthetic next step',
        synthetic: true,
      ),
  ];
}
