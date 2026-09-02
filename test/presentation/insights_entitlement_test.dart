import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/entitlement_repository.dart';
import 'package:studyloop/domain/insights_repository.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/presentation/view_models/insights_view_model.dart';
import 'package:studyloop/providers.dart';

StudyRecord record({required String id, required DateTime startedAt}) {
  return StudyRecord(
    id: id,
    startedAt: startedAt,
    endedAt: startedAt.add(const Duration(minutes: 10)),
    startDate: DateTime(startedAt.year, startedAt.month, startedAt.day),
    barrier: StudyBarrier.overload,
    taskText: 'Task $id',
    taskType: TaskType.examRevision,
    examSubtype: ExamSubtype.calculation,
    plannedSeconds: 600,
    actualSeconds: 480,
    outcome: SessionOutcome.completed,
    difficulty: 3,
    focus: 4,
    moodChange: MoodChange.moreAtEase,
  );
}

void main() {
  test('free users cannot select long-term insight ranges', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final now = DateTime(2026, 9, 1, 10);
    for (var i = 0; i < 3; i++) {
      await db.saveRecord(
        record(
          id: '$i',
          startedAt: now.subtract(Duration(days: i)),
        ),
      );
    }
    final fake = FakeEntitlementRepository(state: EntitlementState.free);
    addTearDown(fake.dispose);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        entitlementRepositoryProvider.overrideWithValue(fake),
        entitlementProvider.overrideWith(
          () => _FixedEntitlement(EntitlementState.free),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(insightsControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    container
        .read(insightsControllerProvider.notifier)
        .selectRange(InsightRange.threeMonths);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(
      container.read(insightsControllerProvider).value!.selectedRange,
      InsightRange.month,
    );
    expect(
      container.read(insightsControllerProvider).value!.longTermInsights,
      isEmpty,
    );
  });

  test('pro users can select all-time insights', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final now = DateTime(2026, 9, 1, 10);
    for (var i = 0; i < 3; i++) {
      await db.saveRecord(
        record(
          id: '$i',
          startedAt: now.subtract(Duration(days: i)),
        ),
      );
    }
    final fake = FakeEntitlementRepository(state: EntitlementState.pro);
    addTearDown(fake.dispose);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        entitlementRepositoryProvider.overrideWithValue(fake),
        entitlementProvider.overrideWith(
          () => _FixedEntitlement(EntitlementState.pro),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(insightsControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    container
        .read(insightsControllerProvider.notifier)
        .selectRange(InsightRange.all);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final state = container.read(insightsControllerProvider).value!;
    expect(state.selectedRange, InsightRange.all);
    expect(state.longTermInsights, isNotEmpty);
  });

  test('free history still includes records older than seven days', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final now = DateTime(2026, 9, 1, 10);
    await db.saveRecord(
      record(id: 'old', startedAt: now.subtract(const Duration(days: 8))),
    );
    await db.saveRecord(record(id: 'new', startedAt: now));
    final records = await db.allRecords();
    expect(records.map((item) => item.id), containsAll(['old', 'new']));
  });
}

class _FixedEntitlement extends EntitlementNotifier {
  _FixedEntitlement(this._state);
  final EntitlementState _state;

  @override
  EntitlementState build() => _state;
}
