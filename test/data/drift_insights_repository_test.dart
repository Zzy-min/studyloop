import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/data/repositories/drift_insights_repository.dart';
import 'package:studyloop/domain/insights_repository.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  late AppDatabase db;
  late DriftInsightsRepository repo;
  final now = DateTime(2026, 9, 1, 10, 0);

  setUp(() {
    db = AppDatabase.memory();
    repo = DriftInsightsRepository(database: db, clock: () => now);
  });

  tearDown(() async {
    await db.close();
  });

  StudyRecord record({
    required String id,
    required DateTime startedAt,
    required int actualSeconds,
    required int plannedSeconds,
    required TaskType taskType,
    int focus = 4,
  }) {
    return StudyRecord(
      id: id,
      startedAt: startedAt,
      endedAt: startedAt.add(Duration(seconds: actualSeconds)),
      startDate: DateTime(startedAt.year, startedAt.month, startedAt.day),
      barrier: StudyBarrier.overload,
      taskText: 'Task $id',
      taskType: taskType,
      plannedSeconds: plannedSeconds,
      actualSeconds: actualSeconds,
      outcome: SessionOutcome.completed,
      difficulty: 3,
      focus: focus,
      moodChange: MoodChange.moreAtEase,
    );
  }

  test(
    'empty database does not invent hours, charts, or peak windows',
    () async {
      final duration = await repo.getFocusDuration(
        InsightRange.all,
        isChinese: false,
      );
      expect(duration.totalHours, 0);
      expect(duration.changePercent, isNull);
      expect(duration.points, isEmpty);

      expect(await repo.getBestDuration(isChinese: false), isNull);
      expect(await repo.getBestTime(isChinese: false), isNull);

      final distribution = await repo.getTaskDistribution(
        InsightRange.all,
        isChinese: false,
      );
      expect(
        distribution.categories.every((item) => item.percentage == 0),
        isTrue,
      );
    },
  );

  test(
    'computes actual hours, best duration, peak window, and task mix from real sessions',
    () async {
      await db.saveRecord(
        record(
          id: 'a',
          startedAt: DateTime(2026, 8, 30, 9, 10),
          actualSeconds: 1800,
          plannedSeconds: 1800,
          taskType: TaskType.examRevision,
          focus: 5,
        ),
      );
      await db.saveRecord(
        record(
          id: 'b',
          startedAt: DateTime(2026, 8, 31, 9, 40),
          actualSeconds: 1800,
          plannedSeconds: 1800,
          taskType: TaskType.examRevision,
          focus: 5,
        ),
      );
      await db.saveRecord(
        record(
          id: 'c',
          startedAt: DateTime(2026, 8, 31, 21, 0),
          actualSeconds: 600,
          plannedSeconds: 900,
          taskType: TaskType.paperWriting,
          focus: 3,
        ),
      );

      final duration = await repo.getFocusDuration(
        InsightRange.month,
        isChinese: false,
      );
      expect(duration.totalHours, 1.2);
      expect(duration.changePercent, isNull);
      expect(duration.points, isNotEmpty);
      expect(duration.points.every((point) => point.value >= 0), isTrue);

      final bestDuration = await repo.getBestDuration(isChinese: false);
      expect(bestDuration, isNotNull);
      expect(bestDuration!.durationLabel, contains('30'));

      final bestTime = await repo.getBestTime(isChinese: false);
      expect(bestTime, isNotNull);
      expect(bestTime!.timeWindowLabel, contains('08:00'));
      expect(bestTime.sampleCount, 2);

      final mix = await repo.getTaskDistribution(
        InsightRange.all,
        isChinese: false,
      );
      expect(mix.categories.first.percentage, closeTo(2 / 3, 0.01));
    },
  );
}
