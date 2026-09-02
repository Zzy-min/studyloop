import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/domain/start_card_engine.dart';

void main() {
  const engine = StartCardEngine();
  SessionDraft draft(TaskType type, {ExamSubtype? subtype, int level = 0}) =>
      SessionDraft(
        barrier: StudyBarrier.overload,
        taskText: 'Calculus',
        taskType: type,
        examSubtype: subtype,
        plannedSeconds: 900,
        reductionLevel: level,
      );

  test(
    'all task families generate deterministic cards at levels 0 through 3',
    () {
      final variants = [
        draft(TaskType.examRevision, subtype: ExamSubtype.memory),
        draft(TaskType.examRevision, subtype: ExamSubtype.calculation),
        draft(TaskType.examRevision, subtype: ExamSubtype.understanding),
        draft(TaskType.homework),
        draft(TaskType.programmingPractice),
        draft(TaskType.paperWriting),
        draft(TaskType.reading),
        draft(TaskType.memorization),
        draft(TaskType.preview),
        draft(TaskType.project),
        draft(TaskType.other),
      ];
      for (final variant in variants) {
        for (var level = 0; level <= 3; level++) {
          final input = variant.copyWith(reductionLevel: level);
          expect(engine.generate(input).action, engine.generate(input).action);
          expect(engine.generate(input).action, isNotEmpty);
        }
      }
    },
  );

  test('severe discomfort cannot generate a timer card', () {
    final severe = draft(TaskType.programmingPractice).copyWith(
      barrier: StudyBarrier.tiredness,
      fatigueSeverity: FatigueSeverity.severe,
    );
    expect(() => engine.generate(severe), throwsArgumentError);
  });

  test(
    'the selected barrier changes the starting action deterministically',
    () {
      final actions = {
        for (final barrier in StudyBarrier.values)
          barrier: engine
              .generate(
                draft(TaskType.programmingPractice).copyWith(barrier: barrier),
              )
              .action,
      };

      expect(actions.values.toSet(), hasLength(StudyBarrier.values.length));
      expect(
        actions[StudyBarrier.phoneDistraction],
        contains('phone out of reach'),
      );
      expect(
        actions[StudyBarrier.perfectionism],
        contains('imperfect version'),
      );
    },
  );
}
