import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/providers.dart';

void main() {
  const draft = SessionDraft(
    barrier: StudyBarrier.overload,
    taskText: 'Calculus',
    taskType: TaskType.examRevision,
    examSubtype: ExamSubtype.calculation,
    plannedSeconds: 5,
  );

  test('timer ticks only while running and never adds paused time', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    var now = DateTime(2026, 9, 1, 10, 0, 0);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    await container.read(timerProvider.notifier).start(draft);
    now = now.add(const Duration(seconds: 2));
    await container.read(timerProvider.notifier).tick();
    expect(container.read(timerProvider).snapshot!.accumulatedSeconds, 2);

    await container.read(timerProvider.notifier).pauseForLifecycle();
    now = now.add(const Duration(seconds: 10));
    await container.read(timerProvider.notifier).tick();
    expect(container.read(timerProvider).snapshot!.accumulatedSeconds, 2);
    expect(container.read(timerProvider).running, isFalse);

    container.read(timerProvider.notifier).continueSession();
    now = now.add(const Duration(seconds: 1));
    await container.read(timerProvider.notifier).tick();
    expect(container.read(timerProvider).snapshot!.accumulatedSeconds, 3);
  });

  test('start is idempotent while a session is already active', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    var now = DateTime(2026, 9, 1, 10, 0, 0);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    await container.read(timerProvider.notifier).start(draft);
    now = now.add(const Duration(seconds: 2));
    await container.read(timerProvider.notifier).tick();
    await container
        .read(timerProvider.notifier)
        .start(draft.copyWith(taskText: 'Duplicate'));

    final snapshot = container.read(timerProvider).snapshot!;
    expect(snapshot.draft.taskText, 'Calculus');
    expect(snapshot.accumulatedSeconds, 2);
  });

  test('finishEarly is idempotent and keeps actual elapsed seconds', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    var now = DateTime(2026, 9, 1, 10, 0, 0);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    await container.read(timerProvider.notifier).start(draft);
    now = now.add(const Duration(seconds: 3));
    await container.read(timerProvider.notifier).tick();
    await container.read(timerProvider.notifier).finishEarly();
    await container.read(timerProvider.notifier).finishEarly();
    await container.read(timerProvider.notifier).tick();

    final state = container.read(timerProvider);
    expect(state.running, isFalse);
    expect(state.outcome, SessionOutcome.interrupted);
    expect(state.snapshot!.accumulatedSeconds, 3);
  });

  test('restore does not add time away from the app', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    var now = DateTime(2026, 9, 1, 10, 0, 0);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    await container.read(timerProvider.notifier).start(draft);
    now = now.add(const Duration(seconds: 4));
    await container.read(timerProvider.notifier).tick();
    await container.read(timerProvider.notifier).pauseForLifecycle();
    now = now.add(const Duration(minutes: 20));
    await container.read(timerProvider.notifier).restore();
    await container.read(timerProvider.notifier).tick();
    expect(container.read(timerProvider).needsRecovery, isTrue);
    expect(container.read(timerProvider).running, isFalse);
    expect(container.read(timerProvider).snapshot!.accumulatedSeconds, 4);
  });

  test(
    'finishEarly keeps the timer stopped after a later resume attempt',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      var now = DateTime(2026, 9, 1, 10, 0, 0);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);

      await container.read(timerProvider.notifier).start(draft);
      now = now.add(const Duration(seconds: 2));
      await container.read(timerProvider.notifier).tick();
      await container.read(timerProvider.notifier).finishEarly();
      container.read(timerProvider.notifier).continueSession();
      now = now.add(const Duration(seconds: 5));
      await container.read(timerProvider.notifier).tick();
      expect(container.read(timerProvider).running, isFalse);
      expect(container.read(timerProvider).outcome, SessionOutcome.interrupted);
      expect(container.read(timerProvider).snapshot!.accumulatedSeconds, 2);
    },
  );

  test(
    'a user-initiated pause stays distinct from a lifecycle pause',
    () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await container.read(timerProvider.notifier).start(draft);
      await container.read(timerProvider.notifier).pauseByUser();
      expect(container.read(timerProvider).running, isFalse);
      expect(container.read(timerProvider).pausedByUser, isTrue);

      await container.read(timerProvider.notifier).pauseForLifecycle();
      expect(container.read(timerProvider).pausedByUser, isTrue);

      container.read(timerProvider.notifier).continueSession();
      expect(container.read(timerProvider).running, isTrue);
      expect(container.read(timerProvider).pausedByUser, isFalse);
    },
  );
}
