import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/domain/insight_engine.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/domain/policies/rest_policy.dart';

void main() {
  group('Reflection Skip & Null Ratings Logic Tests', () {
    test(
      'Skipped reflection yields null difficulty, focus, and moodChange',
      () {
        final skipped = StudyRecord(
          id: 'skip-1',
          startedAt: DateTime(2026, 9, 1, 10, 0),
          endedAt: DateTime(2026, 9, 1, 10, 15),
          startDate: DateTime(2026, 9, 1),
          barrier: StudyBarrier.uncertainStart,
          taskText: 'Reading chapter 1',
          taskType: TaskType.reading,
          plannedSeconds: 900,
          actualSeconds: 900,
          outcome: SessionOutcome.completed,
          difficulty: null,
          focus: null,
          moodChange: null,
          nextAction: '',
        );

        expect(skipped.difficulty, isNull);
        expect(skipped.focus, isNull);
        expect(skipped.moodChange, isNull);
      },
    );

    test('Partial reflection preserves only provided fields', () {
      final partial = StudyRecord(
        id: 'partial-1',
        startedAt: DateTime(2026, 9, 1, 10, 0),
        endedAt: DateTime(2026, 9, 1, 10, 15),
        startDate: DateTime(2026, 9, 1),
        barrier: StudyBarrier.overload,
        taskText: 'Solving equations',
        taskType: TaskType.homework,
        plannedSeconds: 900,
        actualSeconds: 900,
        outcome: SessionOutcome.completed,
        difficulty: 4,
        focus: null,
        moodChange: MoodChange.moreAtEase,
        nextAction: 'Take 5 min break',
      );

      expect(partial.difficulty, equals(4));
      expect(partial.focus, isNull);
      expect(partial.moodChange, equals(MoodChange.moreAtEase));
      expect(partial.nextAction, equals('Take 5 min break'));
    });

    test(
      'InsightEngine counts reflections accurately when some sessions skipped reflection',
      () {
        const engine = InsightEngine();
        final now = DateTime(2026, 9, 2, 12, 0);

        final records = [
          // Session 1: completed, skipped reflection
          StudyRecord(
            id: 'r1',
            startedAt: now.subtract(const Duration(days: 1)),
            endedAt: now
                .subtract(const Duration(days: 1))
                .add(const Duration(minutes: 15)),
            startDate: now.subtract(const Duration(days: 1)),
            barrier: StudyBarrier.uncertainStart,
            taskText: 'Task 1',
            taskType: TaskType.programmingPractice,
            plannedSeconds: 900,
            actualSeconds: 900,
            outcome: SessionOutcome.completed,
            difficulty: null,
            focus: null,
            moodChange: null,
          ),
          // Session 2: completed, skipped reflection
          StudyRecord(
            id: 'r2',
            startedAt: now.subtract(const Duration(days: 2)),
            endedAt: now
                .subtract(const Duration(days: 2))
                .add(const Duration(minutes: 15)),
            startDate: now.subtract(const Duration(days: 2)),
            barrier: StudyBarrier.uncertainStart,
            taskText: 'Task 2',
            taskType: TaskType.programmingPractice,
            plannedSeconds: 900,
            actualSeconds: 900,
            outcome: SessionOutcome.completed,
            difficulty: null,
            focus: null,
            moodChange: null,
          ),
          // Session 3: completed, filled reflection with moreAtEase
          StudyRecord(
            id: 'r3',
            startedAt: now.subtract(const Duration(days: 3)),
            endedAt: now
                .subtract(const Duration(days: 3))
                .add(const Duration(minutes: 15)),
            startDate: now.subtract(const Duration(days: 3)),
            barrier: StudyBarrier.uncertainStart,
            taskText: 'Task 3',
            taskType: TaskType.programmingPractice,
            plannedSeconds: 900,
            actualSeconds: 900,
            outcome: SessionOutcome.completed,
            difficulty: 3,
            focus: 4,
            moodChange: MoodChange.moreAtEase,
          ),
        ];

        final pro = engine.proInsights(records, locale: 'zh');
        expect(pro.length, greaterThanOrEqualTo(2));
        // First insight is completion rate: 3 of 3 completed
        expect(pro[0].text, contains('3 次专注会话中有 3 次顺利到达预定终点'));
        // Second insight is reflection mood: exactly 1 reflection exists, not 3!
        expect(pro[1].text, contains('1 次复盘中有 1 次在专注后感到更加轻松'));
      },
    );

    test(
      'RestPolicy ignores skipped reflection when evaluating consecutive low focus',
      () {
        const policy = RestPolicy();
        final records = [
          StudyRecord(
            id: 's1',
            startedAt: DateTime.now().subtract(const Duration(hours: 2)),
            endedAt: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 45),
            ),
            startDate: DateTime.now(),
            barrier: StudyBarrier.tiredness,
            taskText: 'Task A',
            taskType: TaskType.reading,
            plannedSeconds: 900,
            actualSeconds: 900,
            outcome: SessionOutcome.completed,
            difficulty: null,
            focus: null, // Skipped
            moodChange: null,
          ),
          StudyRecord(
            id: 's2',
            startedAt: DateTime.now().subtract(const Duration(minutes: 40)),
            endedAt: DateTime.now().subtract(const Duration(minutes: 25)),
            startDate: DateTime.now(),
            barrier: StudyBarrier.tiredness,
            taskText: 'Task B',
            taskType: TaskType.reading,
            plannedSeconds: 900,
            actualSeconds: 900,
            outcome: SessionOutcome.completed,
            difficulty: 2,
            focus: 2, // Low focus
            moodChange: MoodChange.unchanged,
          ),
        ];

        // Since s1 was skipped (focus is null), it must NOT be counted as low focus
        expect(policy.recommendsRestAfter(records), isFalse);
      },
    );
  });
}
