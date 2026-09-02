import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/drift_insights_repository.dart';
import '../../domain/insight_engine.dart';
import '../../domain/insights_repository.dart';
import '../../domain/models.dart';
import '../../domain/policies/session_date_policy.dart';
import '../../providers.dart';

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final clock = ref.watch(clockProvider);
  return DriftInsightsRepository(database: db, clock: clock);
});

bool isLongTermInsightRange(InsightRange range) =>
    range == InsightRange.threeMonths || range == InsightRange.all;

class InsightsViewState {
  const InsightsViewState({
    required this.selectedRange,
    required this.focusDuration,
    this.bestDuration,
    this.bestTime,
    required this.taskDistribution,
    required this.explanation,
    required this.longTermInsights,
    required this.isPro,
    required this.isChinese,
    required this.hasEnoughData,
    required this.recentRecordCount,
  });

  final InsightRange selectedRange;
  final FocusDurationInsight focusDuration;
  final BestDurationInsight? bestDuration;
  final BestTimeInsight? bestTime;
  final TaskDistributionInsight taskDistribution;
  final InsightExplanation explanation;
  final List<Insight> longTermInsights;
  final bool isPro;
  final bool isChinese;
  final bool hasEnoughData;
  final int recentRecordCount;
}

class InsightsController extends Notifier<AsyncValue<InsightsViewState>> {
  InsightRange _selectedRange = InsightRange.month;

  @override
  AsyncValue<InsightsViewState> build() {
    _load();
    return const AsyncValue.loading();
  }

  InsightRange _effectiveRange(bool isPro) {
    if (!isPro && isLongTermInsightRange(_selectedRange)) {
      return InsightRange.month;
    }
    return _selectedRange;
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(insightsRepositoryProvider);
      final strings = ref.read(stringsProvider);
      final entitlement = ref.read(entitlementProvider);
      final records = await ref.read(recordsProvider.future);
      final now = ref.read(clockProvider)();
      final recentRecords = records
          .where(
            (record) => const SessionDatePolicy().isInRecentWindow(record, now),
          )
          .toList();
      final isChinese = strings.isChinese;
      final isPro = entitlement == EntitlementState.pro;
      final range = _effectiveRange(isPro);
      _selectedRange = range;

      final duration = await repo.getFocusDuration(range, isChinese: isChinese);
      final bestDur = await repo.getBestDuration(isChinese: isChinese);
      final bestTime = await repo.getBestTime(isChinese: isChinese);
      final taskDist = await repo.getTaskDistribution(
        range,
        isChinese: isChinese,
      );
      final explanation = await repo.getExplanation(isChinese: isChinese);
      final longTerm = isPro
          ? const InsightEngine().proInsights(
              records,
              locale: isChinese ? 'zh' : 'en',
            )
          : const <Insight>[];

      state = AsyncValue.data(
        InsightsViewState(
          selectedRange: range,
          focusDuration: duration,
          bestDuration: bestDur,
          bestTime: bestTime,
          taskDistribution: taskDist,
          explanation: explanation,
          longTermInsights: longTerm,
          isPro: isPro,
          isChinese: isChinese,
          hasEnoughData: recentRecords.length >= 3,
          recentRecordCount: recentRecords.length,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void selectRange(InsightRange range) {
    final isPro = ref.read(entitlementProvider) == EntitlementState.pro;
    if (!isPro && isLongTermInsightRange(range)) {
      return;
    }
    _selectedRange = range;
    _load();
  }

  void reload() {
    _load();
  }
}

final insightsControllerProvider =
    NotifierProvider<InsightsController, AsyncValue<InsightsViewState>>(
      InsightsController.new,
    );
