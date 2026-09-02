import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/insights_repository.dart';
import 'package:studyloop/domain/entitlement_repository.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/presentation/view_models/focus_view_model.dart';
import 'package:studyloop/presentation/view_models/home_view_model.dart';
import 'package:studyloop/presentation/view_models/insights_view_model.dart';
import 'package:studyloop/presentation/view_models/paywall_view_model.dart';
import 'package:studyloop/providers.dart';

void main() {
  group('HomeViewModel & HomeController Tests', () {
    test(
      'Initial HomeViewState has greetings, barriers and companion state',
      () {
        final database = AppDatabase.memory();
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(database)],
        );
        addTearDown(container.dispose);
        addTearDown(database.close);

        final state = container.read(homeControllerProvider);
        expect(state.greeting, isNotEmpty);
        expect(state.barriers.length, equals(5));
        expect(state.selectedBarrier, isNull);
        expect(state.companionState, equals(DogState.waiting));
        expect(state.suggestedAction, isNotNull);
        expect(state.suggestedAction!.canStart, isFalse);
        expect(
          state.suggestedAction!.title.toLowerCase(),
          isNot(contains('linear algebra')),
        );
        expect(
          state.suggestedAction!.description.toLowerCase(),
          isNot(contains('section 2.1')),
        );
      },
    );

    test('Selecting barrier updates selectedBarrier in HomeViewState', () {
      final database = AppDatabase.memory();
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);

      container
          .read(homeControllerProvider.notifier)
          .selectBarrier(StudyBarrier.uncertainStart);
      final state = container.read(homeControllerProvider);

      expect(state.selectedBarrier, equals(StudyBarrier.uncertainStart));
      final selectedBarriers = state.barriers.where((b) => b.selected).toList();
      expect(selectedBarriers.length, equals(1));
      expect(
        selectedBarriers.first.barrier,
        equals(StudyBarrier.uncertainStart),
      );
    });
  });

  group('FocusViewModel & FocusController Tests', () {
    test('Idle state when no active session snapshot exists', () {
      final database = AppDatabase.memory();
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);

      final state = container.read(focusControllerProvider);
      expect(state.hasActiveSession, isFalse);
      expect(state.status, equals(FocusStatus.idle));
      expect(state.formattedRemaining, equals('00:00'));
    });

    test('Maps active session snapshot accurately to FocusViewState', () async {
      final database = AppDatabase.memory();
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);

      const draft = SessionDraft(
        taskText: 'Linear Algebra',
        plannedSeconds: 900,
        barrier: StudyBarrier.uncertainStart,
      );

      await container.read(timerProvider.notifier).start(draft);
      final state = container.read(focusControllerProvider);

      expect(state.hasActiveSession, isTrue);
      expect(state.taskTitle, equals('Linear Algebra'));
      expect(state.plannedMinutes, equals(15));
      expect(state.remainingSeconds, equals(900));
      expect(state.formattedRemaining, equals('15:00'));
      expect(state.status, equals(FocusStatus.running));
      expect(state.companionState, equals(DogState.focusing));
    });
  });

  group('InsightsViewModel & InsightsController Tests', () {
    test(
      'Loads deterministic insights and updates on range selection',
      () async {
        final database = AppDatabase.memory();
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(database)],
        );
        addTearDown(container.dispose);
        addTearDown(database.close);

        // Read initial state
        final initialAsync = container.read(insightsControllerProvider);
        expect(initialAsync, isA<AsyncLoading<InsightsViewState>>());

        // Wait for next tick or selectRange
        container
            .read(insightsControllerProvider.notifier)
            .selectRange(InsightRange.week);

        // Let microtasks run
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final state = container.read(insightsControllerProvider).value;
        expect(state, isNotNull);
        expect(state!.selectedRange, equals(InsightRange.week));
        expect(state.focusDuration.points, isEmpty);
        expect(state.taskDistribution.categories.length, equals(4));
        expect(state.hasEnoughData, isFalse);
      },
    );
  });

  test('PaywallController blocks duplicate purchase requests', () async {
    final repository = _BlockingEntitlementRepository();
    final container = ProviderContainer(
      overrides: [entitlementRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    addTearDown(repository.dispose);

    final controller = container.read(paywallControllerProvider.notifier);
    final first = controller.purchase();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(paywallControllerProvider).isBusy, isTrue);
    expect(await controller.purchase(), isNull);
    expect(repository.purchaseCalls, 1);

    repository.purchaseCompleter.complete(const PurchaseCancelled());
    await first;
    expect(container.read(paywallControllerProvider).isBusy, isFalse);
  });
}

class _BlockingEntitlementRepository implements EntitlementRepository {
  final purchaseCompleter = Completer<PurchaseResult>();
  final _changes = StreamController<EntitlementState>.broadcast();
  int purchaseCalls = 0;

  @override
  Stream<EntitlementState> get changes => _changes.stream;

  @override
  Future<PurchaseResult> purchase() {
    purchaseCalls++;
    return purchaseCompleter.future;
  }

  @override
  Future<EntitlementState> refresh() async => EntitlementState.free;

  @override
  Future<PurchaseResult> restore() async => const NothingToRestore();

  Future<void> dispose() => _changes.close();
}
