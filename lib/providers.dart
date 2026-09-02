import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'application/navigation/paywall_origin.dart';
import 'data/database/app_database.dart';
import 'data/demo/synthetic_records.dart';
import 'domain/entitlement_repository.dart';
import 'domain/insight_engine.dart';
import 'domain/models.dart';
import 'domain/policies/rest_policy.dart';
import 'domain/policies/session_date_policy.dart';
import 'domain/start_card_engine.dart';
import 'l10n/app_strings.dart';

export 'application/navigation/paywall_origin.dart';
export 'l10n/app_strings.dart';

final databaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('Database not initialized'),
);
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final entitlementRepositoryProvider = Provider<EntitlementRepository>(
  (ref) => FakeEntitlementRepository(state: EntitlementState.unknown),
);

class LocaleNotifier extends Notifier<String> {
  LocaleNotifier([this._initialLocale = 'en']);
  final String _initialLocale;

  @override
  String build() => _initialLocale;

  void setLocale(String locale) => state = locale;
  void toggle() => state = state.startsWith('zh') ? 'en' : 'zh';
}

final localeProvider = NotifierProvider<LocaleNotifier, String>(
  LocaleNotifier.new,
);

final stringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings.ofLocale(locale);
});

class SessionNotifier extends Notifier<SessionDraft> {
  final _engine = const StartCardEngine();
  final _rest = const RestPolicy();

  @override
  SessionDraft build() => const SessionDraft(plannedSeconds: 900);

  void chooseBarrier(StudyBarrier barrier) {
    state = state.copyWith(
      barrier: barrier,
      clearFatigue: barrier != StudyBarrier.tiredness,
      plannedSeconds: barrier == StudyBarrier.tiredness
          ? 600
          : state.plannedSeconds,
      clearCard: true,
    );
  }

  void chooseFatigue(FatigueSeverity severity) {
    state = state.copyWith(
      fatigueSeverity: severity,
      plannedSeconds: severity == FatigueSeverity.ordinary
          ? 600
          : state.plannedSeconds,
      clearCard: true,
    );
  }

  void setTask(String value) =>
      state = state.copyWith(taskText: value, clearCard: true);
  void chooseType(TaskType type) => state = state.copyWith(
    taskType: type,
    clearSubtype: type != TaskType.examRevision,
    clearCard: true,
  );
  void chooseSubtype(ExamSubtype type) =>
      state = state.copyWith(examSubtype: type, clearCard: true);
  void chooseDuration(int seconds) =>
      state = state.copyWith(plannedSeconds: seconds, clearCard: true);

  bool get shouldRestNow => _rest.isSevereDiscomfort(state);

  bool generateCard() {
    if (!state.isValid) return false;
    final locale = ref.read(localeProvider);
    state = state.copyWith(
      reductionLevel: 0,
      card: _engine.generate(state.copyWith(reductionLevel: 0), locale: locale),
    );
    return true;
  }

  void reduce() {
    if (!state.isValid || state.reductionLevel >= 3) return;
    final locale = ref.read(localeProvider);
    final next = state.copyWith(reductionLevel: state.reductionLevel + 1);
    state = next.copyWith(card: _engine.generate(next, locale: locale));
  }

  void reset() => state = const SessionDraft(plannedSeconds: 900);
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionDraft>(
  SessionNotifier.new,
);

class TimerState {
  const TimerState({
    this.snapshot,
    this.running = false,
    this.outcome,
    this.needsRecovery = false,
    this.pausedByUser = false,
  });
  final ActiveTimerSnapshot? snapshot;
  final bool running;
  final SessionOutcome? outcome;
  final bool needsRecovery;
  final bool pausedByUser;

  TimerState copyWith({
    ActiveTimerSnapshot? snapshot,
    bool? running,
    SessionOutcome? outcome,
    bool? needsRecovery,
    bool? pausedByUser,
    bool clearOutcome = false,
  }) => TimerState(
    snapshot: snapshot ?? this.snapshot,
    running: running ?? this.running,
    outcome: clearOutcome ? null : outcome ?? this.outcome,
    needsRecovery: needsRecovery ?? this.needsRecovery,
    pausedByUser: pausedByUser ?? this.pausedByUser,
  );
}

class TimerNotifier extends Notifier<TimerState> {
  Timer? _ticker;
  AppDatabase get _db => ref.read(databaseProvider);
  DateTime get _now => ref.read(clockProvider)();

  @override
  TimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const TimerState();
  }

  Future<bool> restore() async {
    final snapshot = await _db.readSnapshot();
    if (snapshot == null) return false;
    _ticker?.cancel();
    final now = _now;
    final recovered = ActiveTimerSnapshot(
      draft: snapshot.draft,
      accumulatedSeconds: snapshot.accumulatedSeconds,
      remainingSeconds: snapshot.remainingSeconds,
      startedAt: snapshot.startedAt,
      lastSavedAt: now,
    );
    await _db.saveSnapshot(recovered);
    state = TimerState(snapshot: recovered, needsRecovery: true);
    return true;
  }

  Future<void> start(SessionDraft draft) async {
    final current = state.snapshot;
    if (current != null && state.outcome == null) return;
    final now = _now;
    final snapshot = ActiveTimerSnapshot(
      draft: draft,
      accumulatedSeconds: 0,
      remainingSeconds: draft.plannedSeconds,
      startedAt: now,
      lastSavedAt: now,
    );
    state = TimerState(snapshot: snapshot, running: true, pausedByUser: false);
    await _db.saveSnapshot(snapshot);
    _beginTicks();
  }

  void _beginTicks() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  ActiveTimerSnapshot _advance(ActiveTimerSnapshot current, DateTime now) {
    final elapsed = now.difference(current.lastSavedAt).inSeconds;
    final added = elapsed < 0 ? 0 : elapsed;
    final accumulated = current.accumulatedSeconds + added;
    final remaining = current.draft.plannedSeconds - accumulated;
    return ActiveTimerSnapshot(
      draft: current.draft,
      accumulatedSeconds: accumulated,
      remainingSeconds: remaining < 0 ? 0 : remaining,
      startedAt: current.startedAt,
      lastSavedAt: now,
    );
  }

  Future<void> tick() async {
    final current = state.snapshot;
    if (!state.running || current == null || state.outcome != null) return;
    final next = _advance(current, _now);
    final completed = next.remainingSeconds <= 0;
    state = TimerState(
      snapshot: next,
      running: !completed,
      outcome: completed ? SessionOutcome.completed : null,
    );
    if (completed) _ticker?.cancel();
    if (completed || next.accumulatedSeconds % 5 == 0) {
      await _db.saveSnapshot(next);
    }
  }

  Future<void> pauseForLifecycle() async {
    _ticker?.cancel();
    final current = state.snapshot;
    if (current != null && state.running) {
      final next = _advance(current, _now);
      state = state.copyWith(snapshot: next, running: false);
      await _db.saveSnapshot(next);
      return;
    }
    state = state.copyWith(running: false);
    if (current != null) await _db.saveSnapshot(current);
  }

  Future<void> pauseByUser() async {
    await pauseForLifecycle();
    state = state.copyWith(pausedByUser: true);
  }

  void continueSession() {
    if (state.outcome != null || state.snapshot == null) return;
    final current = state.snapshot!;
    final now = _now;
    final resumed = ActiveTimerSnapshot(
      draft: current.draft,
      accumulatedSeconds: current.accumulatedSeconds,
      remainingSeconds: current.remainingSeconds,
      startedAt: current.startedAt,
      lastSavedAt: now,
    );
    state = state.copyWith(
      snapshot: resumed,
      running: true,
      needsRecovery: false,
      pausedByUser: false,
      clearOutcome: true,
    );
    _beginTicks();
  }

  Future<void> finishEarly() async {
    if (state.outcome == SessionOutcome.interrupted || state.snapshot == null) {
      return;
    }
    await pauseForLifecycle();
    if (state.outcome == SessionOutcome.completed) return;
    state = state.copyWith(
      outcome: SessionOutcome.interrupted,
      needsRecovery: false,
    );
  }

  void clear() {
    _ticker?.cancel();
    state = const TimerState();
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
  TimerNotifier.new,
);
final recordsProvider = FutureProvider<List<StudyRecord>>(
  (ref) => ref.watch(databaseProvider).allRecords(),
);

final recentRecordsProvider = Provider<List<StudyRecord>>((ref) {
  final records = ref.watch(recordsProvider).value ?? const <StudyRecord>[];
  final now = ref.watch(clockProvider)();
  const policy = SessionDatePolicy();
  return records
      .where((record) => policy.isInRecentWindow(record, now))
      .toList();
});

final freeInsightProvider = Provider<Insight?>((ref) {
  final records = ref.watch(recordsProvider).value ?? const <StudyRecord>[];
  final locale = ref.watch(localeProvider);
  return const InsightEngine().freeInsight(
    records,
    ref.watch(clockProvider)(),
    locale: locale,
  );
});

final restRecommendationProvider = Provider<bool>((ref) {
  final records = [
    ...(ref.watch(recordsProvider).value ?? const <StudyRecord>[]),
  ]..sort((a, b) => a.endedAt.compareTo(b.endedAt));
  return const RestPolicy().recommendsRestAfter(records);
});

class EntitlementNotifier extends Notifier<EntitlementState> {
  EntitlementRepository get _repo => ref.read(entitlementRepositoryProvider);
  PurchaseResult? lastResult;
  String message = '';

  @override
  EntitlementState build() {
    Future.microtask(refresh);
    return EntitlementState.unknown;
  }

  Future<EntitlementState> refresh() async {
    try {
      state = await _repo.refresh();
      message = '';
    } catch (_) {
      state = EntitlementState.unknown;
      message = 'Pro status cannot be verified right now.';
    }
    return state;
  }

  Future<PurchaseResult> purchase() async {
    final result = await _repo.purchase();
    lastResult = result;
    await _apply(result, quietCancel: true);
    return result;
  }

  Future<PurchaseResult> restore() async {
    final result = await _repo.restore();
    lastResult = result;
    await _apply(result, quietCancel: false);
    return result;
  }

  Future<void> _apply(
    PurchaseResult result, {
    required bool quietCancel,
  }) async {
    switch (result) {
      case PurchaseActivated():
        state = await _repo.refresh();
        message = '';
      case PurchaseCancelled():
        if (!quietCancel) message = '';
      case PurchaseFailed(:final message):
        this.message = message;
      case NothingToRestore():
        message = 'No previous StudyLoop Pro purchase was found.';
    }
  }
}

final entitlementProvider =
    NotifierProvider<EntitlementNotifier, EntitlementState>(
      EntitlementNotifier.new,
    );

class PaywallOriginNotifier extends Notifier<String> {
  @override
  String build() => '/insights';
  void setOrigin(String origin) => state = normalizePaywallOrigin(origin);
}

final paywallOriginProvider = NotifierProvider<PaywallOriginNotifier, String>(
  PaywallOriginNotifier.new,
);

Future<StudyRecord> commitReflection({
  required WidgetRef ref,
  int? difficulty,
  int? focus,
  MoodChange? mood,
  required String nextAction,
}) async {
  final timer = ref.read(timerProvider);
  final snapshot = timer.snapshot!;
  final started = snapshot.startedAt;
  final record = StudyRecord(
    id: const Uuid().v4(),
    startedAt: started,
    endedAt: ref.read(clockProvider)(),
    startDate: const SessionDatePolicy().startDate(started),
    barrier: snapshot.draft.barrier!,
    taskText: snapshot.draft.taskText,
    taskType: snapshot.draft.taskType!,
    examSubtype: snapshot.draft.examSubtype,
    plannedSeconds: snapshot.draft.plannedSeconds,
    actualSeconds: snapshot.accumulatedSeconds,
    outcome: timer.outcome ?? SessionOutcome.interrupted,
    difficulty: difficulty,
    focus: focus,
    moodChange: mood,
    nextAction: nextAction,
  );
  await ref.read(databaseProvider).commit(record);
  ref.invalidate(recordsProvider);
  ref.read(timerProvider.notifier).clear();
  ref.read(sessionProvider.notifier).reset();
  return record;
}

Future<void> seedDemoData(WidgetRef ref) async {
  if (!kDebugMode) return;
  final db = ref.read(databaseProvider);
  await db.clearSynthetic();
  for (final record in labeledSyntheticRecords(ref.read(clockProvider)())) {
    await db.saveRecord(record);
  }
}

void openPaywall(WidgetRef ref, String origin) {
  ref.read(paywallOriginProvider.notifier).setOrigin(origin);
}
