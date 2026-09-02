import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/domain/insight_engine.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  StudyRecord record({
    required String id,
    required DateTime now,
    int plannedSeconds = 600,
    SessionOutcome outcome = SessionOutcome.completed,
    StudyBarrier barrier = StudyBarrier.overload,
    MoodChange mood = MoodChange.moreAtEase,
    DateTime? startDate,
  }) => StudyRecord(
    id: id,
    startedAt: now,
    endedAt: now,
    startDate: startDate ?? DateTime(now.year, now.month, now.day),
    barrier: barrier,
    taskText: 'Task $id',
    taskType: TaskType.paperWriting,
    plannedSeconds: plannedSeconds,
    actualSeconds: 480,
    outcome: outcome,
    difficulty: 3,
    focus: 4,
    moodChange: mood,
  );

  test('free insight requires three recent records and includes evidence', () {
    final now = DateTime(2026, 8, 14);
    const engine = InsightEngine();
    expect(
      engine.freeInsight([
        record(id: '0', now: now),
        record(id: '1', now: now),
      ], now),
      isNull,
    );
    final insight = engine.freeInsight([
      record(id: '0', now: now),
      record(id: '1', now: now),
      record(id: '2', now: now, plannedSeconds: 900),
    ], now)!;
    expect(insight.evidenceCount, 3);
    expect(insight.text.toLowerCase(), contains('feeling overloaded'));
  });

  test('old records outside the seven-day window do not count', () {
    final now = DateTime(2026, 8, 21);
    const engine = InsightEngine();
    final records = [
      record(id: 'old', now: now, startDate: DateTime(2026, 8, 10)),
      record(id: 'a', now: now),
      record(id: 'b', now: now),
    ];
    expect(engine.freeInsight(records, now), isNull);
  });

  test('pro insights include more than one comparison', () {
    final now = DateTime(2026, 8, 14);
    const engine = InsightEngine();
    final insights = engine.proInsights([
      record(id: '0', now: now),
      record(
        id: '1',
        now: now,
        barrier: StudyBarrier.uncertainStart,
        mood: MoodChange.unchanged,
      ),
      record(id: '2', now: now, outcome: SessionOutcome.interrupted),
    ]);
    expect(insights.length, greaterThanOrEqualTo(2));
    expect(insights.every((item) => item.evidenceCount >= 1), isTrue);
  });

  test(
    'fallback insight reports honest totals instead of inventing a preferred duration',
    () {
      final now = DateTime(2026, 8, 14);
      const engine = InsightEngine();
      final insight = engine.freeInsight([
        record(
          id: '0',
          now: now,
          plannedSeconds: 300,
          barrier: StudyBarrier.overload,
        ),
        record(
          id: '1',
          now: now,
          plannedSeconds: 600,
          barrier: StudyBarrier.phoneDistraction,
        ),
        record(
          id: '2',
          now: now,
          plannedSeconds: 900,
          barrier: StudyBarrier.perfectionism,
        ),
      ], now)!;

      expect(insight.evidenceCount, 3);
      expect(insight.text, contains('3 honest focus sessions'));
      expect(insight.text, isNot(contains('most-used')));
    },
  );
}
