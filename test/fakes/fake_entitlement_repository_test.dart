import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/entitlement_repository.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  test('purchase success unlocks without mutating local records', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await db.saveRecord(
      StudyRecord(
        id: 'kept',
        startedAt: DateTime(2026, 8, 14),
        endedAt: DateTime(2026, 8, 14, 1),
        startDate: DateTime(2026, 8, 14),
        barrier: StudyBarrier.overload,
        taskText: 'Kept',
        taskType: TaskType.paperWriting,
        plannedSeconds: 600,
        actualSeconds: 300,
        outcome: SessionOutcome.completed,
        difficulty: 3,
        focus: 4,
        moodChange: MoodChange.moreAtEase,
      ),
    );
    final repo = FakeEntitlementRepository(
      state: EntitlementState.free,
      purchaseResult: const PurchaseActivated(),
    );
    addTearDown(repo.dispose);
    expect(await repo.refresh(), EntitlementState.free);
    expect(await repo.purchase(), isA<PurchaseActivated>());
    expect(await repo.refresh(), EntitlementState.pro);
    expect((await db.allRecords()).single.id, 'kept');
  });

  test(
    'cancellation, failure, nothing-to-restore, and loss leave data intact',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final repo = FakeEntitlementRepository(
        state: EntitlementState.free,
        purchaseResult: const PurchaseCancelled(),
        restoreResult: const NothingToRestore(),
      );
      addTearDown(repo.dispose);
      expect(await repo.purchase(), isA<PurchaseCancelled>());
      expect(await repo.refresh(), EntitlementState.free);
      repo.purchaseResult = const PurchaseFailed('network');
      expect(await repo.purchase(), isA<PurchaseFailed>());
      expect(await repo.restore(), isA<NothingToRestore>());
      repo.emit(EntitlementState.free);
      expect(await repo.refresh(), EntitlementState.free);
      expect(await db.allRecords(), isEmpty);
    },
  );
}
