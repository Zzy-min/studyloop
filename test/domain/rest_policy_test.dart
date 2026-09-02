import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/domain/policies/rest_policy.dart';

void main() {
  const policy = RestPolicy();

  StudyRecord record({required int focus, required MoodChange mood}) =>
      StudyRecord(
        id: '$focus-${mood.name}',
        startedAt: DateTime(2026, 8, 14),
        endedAt: DateTime(2026, 8, 14, 1),
        startDate: DateTime(2026, 8, 14),
        barrier: StudyBarrier.tiredness,
        taskText: 'Task',
        taskType: TaskType.paperWriting,
        plannedSeconds: 600,
        actualSeconds: 300,
        outcome: SessionOutcome.interrupted,
        difficulty: 4,
        focus: focus,
        moodChange: mood,
      );

  test('severe discomfort never yields a timer path', () {
    const draft = SessionDraft(
      barrier: StudyBarrier.tiredness,
      fatigueSeverity: FatigueSeverity.severe,
      taskText: 'Exam',
      taskType: TaskType.examRevision,
      examSubtype: ExamSubtype.memory,
    );
    expect(policy.isSevereDiscomfort(draft), isTrue);
    expect(draft.isValid, isFalse);
  });

  test('two consecutive low-focus or worse-mood records recommend rest', () {
    expect(
      policy.recommendsRestAfter([
        record(focus: 2, mood: MoodChange.unchanged),
      ]),
      isFalse,
    );
    expect(
      policy.recommendsRestAfter([
        record(focus: 2, mood: MoodChange.unchanged),
        record(focus: 1, mood: MoodChange.unchanged),
      ]),
      isTrue,
    );
    expect(
      policy.recommendsRestAfter([
        record(focus: 4, mood: MoodChange.worse),
        record(focus: 5, mood: MoodChange.worse),
      ]),
      isTrue,
    );
    expect(policy.restCopy().toLowerCase(), contains('not making a diagnosis'));
  });
}
