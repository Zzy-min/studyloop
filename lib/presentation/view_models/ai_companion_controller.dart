import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ai_companion_repository.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import 'corgi_chat_view_model.dart';

class AICompanionState {
  const AICompanionState({
    this.status = AIRequestStatus.idle,
    this.activeProposal,
    this.inferredBarrier,
    this.lastReplyText,
    this.errorMessage,
  });

  final AIRequestStatus status;
  final ProposedAction? activeProposal;
  final StudyBarrier? inferredBarrier;
  final String? lastReplyText;
  final String? errorMessage;

  AICompanionState copyWith({
    AIRequestStatus? status,
    ProposedAction? activeProposal,
    bool clearActiveProposal = false,
    StudyBarrier? inferredBarrier,
    String? lastReplyText,
    String? errorMessage,
  }) => AICompanionState(
    status: status ?? this.status,
    activeProposal: clearActiveProposal
        ? null
        : (activeProposal ?? this.activeProposal),
    inferredBarrier: inferredBarrier ?? this.inferredBarrier,
    lastReplyText: lastReplyText ?? this.lastReplyText,
    errorMessage: errorMessage,
  );
}

class AICompanionController extends Notifier<AICompanionState> {
  AICompanionRepository get _repository =>
      ref.read(aiCompanionRepositoryProvider);

  @override
  AICompanionState build() => const AICompanionState();

  void clearProposal() {
    state = state.copyWith(clearActiveProposal: true);
  }

  void setExternalProposal(
    ProposedAction proposal, {
    StudyBarrier? barrier,
  }) {
    state = state.copyWith(
      activeProposal: proposal,
      inferredBarrier: barrier,
      status: AIRequestStatus.success,
    );
  }

  AICompanionContext _buildContext({
    required CompanionSurface surface,
    String? taskText,
    StudyBarrier? barrier,
    Duration? currentFocusDuration,
    int? actualMinutes,
    String? insightText,
  }) {
    final draft = ref.read(sessionProvider);
    final timer = ref.read(timerProvider);
    final records = ref.read(recordsProvider).value ?? const <StudyRecord>[];
    final now = DateTime.now();

    final recentRecords = records
        .where((r) => now.difference(r.startedAt).inDays <= 7)
        .toList();

    final completedCount = recentRecords
        .where((r) => r.outcome == SessionOutcome.completed)
        .length;
    final totalActualSec = recentRecords.fold<int>(
      0,
      (sum, r) => sum + r.actualSeconds,
    );
    final avgMinutes = recentRecords.isEmpty
        ? 0
        : (totalActualSec / recentRecords.length / 60).round();

    final typeCounts = <TaskType, int>{};
    for (final r in recentRecords) {
      typeCounts.update(r.taskType, (val) => val + 1, ifAbsent: () => 1);
    }
    TaskType? primaryType;
    if (typeCounts.isNotEmpty) {
      final sortedTypes = typeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      primaryType = sortedTypes.first.key;
    }

    final recentSummary = RecentLearningSummary(
      sessionCount7Days: recentRecords.length,
      completedCount7Days: completedCount,
      avgActualMinutes: avgMinutes,
      primaryTaskType: primaryType,
      primaryBarrier: barrier ?? draft.barrier,
    );

    final isFocusing = timer.snapshot != null && timer.running;
    final compState = timer.snapshot != null
        ? (timer.running
              ? DogState.focusing
              : timer.outcome == SessionOutcome.completed
              ? DogState.completed
              : DogState.resting)
        : DogState.waiting;

    return AICompanionContext(
      surface: surface,
      barrier: barrier ?? draft.barrier,
      taskType: draft.taskType,
      currentTask: taskText ?? draft.taskText,
      state: compState,
      isFocusing: isFocusing,
      currentFocusDuration:
          currentFocusDuration ??
          (timer.snapshot != null
              ? Duration(seconds: timer.snapshot!.accumulatedSeconds)
              : null),
      recentSummary: recentSummary,
      deterministicInsightText: insightText,
      actualDurationMinutes: actualMinutes,
    );
  }

  /// Surface 2: Proposes a bite-sized micro action (5-15 mins) for a daunting task.
  Future<ProposedAction?> proposeMicroAction(
    String taskText, {
    StudyBarrier? barrier,
  }) async {
    if (state.status == AIRequestStatus.sending) return state.activeProposal;

    state = state.copyWith(status: AIRequestStatus.sending, errorMessage: null);
    final locale = ref.read(localeProvider);
    final context = _buildContext(
      surface: CompanionSurface.taskBreakdown,
      taskText: taskText,
      barrier: barrier,
    );

    try {
      final reply = await _repository.sendMessage(
        userMessage: taskText,
        context: context,
        locale: locale,
      );

      final proposal = reply.suggestedAction;
      state = state.copyWith(
        status: reply.isLocalFallback
            ? AIRequestStatus.fallback
            : AIRequestStatus.success,
        activeProposal: proposal,
        inferredBarrier: reply.detectedBarrier,
        lastReplyText: reply.text,
      );
      return proposal;
    } catch (e) {
      state = state.copyWith(
        status: AIRequestStatus.failed,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Surface 1: Clarifies why user is blocked on Home, infers barrier & proposes start.
  Future<AICompanionReply?> clarifyBarrier(String userExpression) async {
    if (state.status == AIRequestStatus.sending) return null;

    state = state.copyWith(status: AIRequestStatus.sending, errorMessage: null);
    final locale = ref.read(localeProvider);
    final context = _buildContext(
      surface: CompanionSurface.home,
      taskText: userExpression,
    );

    try {
      final reply = await _repository.sendMessage(
        userMessage: userExpression,
        context: context,
        locale: locale,
      );

      state = state.copyWith(
        status: reply.isLocalFallback
            ? AIRequestStatus.fallback
            : AIRequestStatus.success,
        activeProposal: reply.suggestedAction,
        inferredBarrier: reply.detectedBarrier,
        lastReplyText: reply.text,
      );
      return reply;
    } catch (e) {
      state = state.copyWith(
        status: AIRequestStatus.failed,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Surface 3: Accompanying during Focus. Concise, 1-2 sentence reassurance.
  Future<String> accompanyFocus(Duration elapsed) async {
    if (state.status == AIRequestStatus.sending) {
      return state.lastReplyText ?? '柯基在安静陪着你呢。';
    }

    state = state.copyWith(status: AIRequestStatus.sending);
    final locale = ref.read(localeProvider);
    final context = _buildContext(
      surface: CompanionSurface.focus,
      currentFocusDuration: elapsed,
    );

    try {
      final reply = await _repository.sendMessage(
        userMessage: '有点学累了/有点想放弃',
        context: context,
        locale: locale,
      );
      state = state.copyWith(
        status: reply.isLocalFallback
            ? AIRequestStatus.fallback
            : AIRequestStatus.success,
        lastReplyText: reply.text,
      );
      return reply.text;
    } catch (_) {
      const fallback = '柯基安静趴在旁边陪你。觉得累了可以随时保存现在的学习时间去休息哦。';
      state = state.copyWith(
        status: AIRequestStatus.fallback,
        lastReplyText: fallback,
      );
      return fallback;
    }
  }

  /// Surface 4: Light reflection companion. Never fabricates scores.
  Future<String> reflectWithCorgi(String userThought, int actualMinutes) async {
    if (state.status == AIRequestStatus.sending) {
      return state.lastReplyText ?? '做得很棒！';
    }

    state = state.copyWith(status: AIRequestStatus.sending);
    final locale = ref.read(localeProvider);
    final context = _buildContext(
      surface: CompanionSurface.reflection,
      actualMinutes: actualMinutes,
    );

    try {
      final reply = await _repository.sendMessage(
        userMessage: userThought.isEmpty ? '完成了一次专注' : userThought,
        context: context,
        locale: locale,
      );
      state = state.copyWith(
        status: reply.isLocalFallback
            ? AIRequestStatus.fallback
            : AIRequestStatus.success,
        lastReplyText: reply.text,
      );
      return reply.text;
    } catch (_) {
      const fallback = '辛苦啦！每一次主动迈出第一步都是很棒的进展。';
      state = state.copyWith(
        status: AIRequestStatus.fallback,
        lastReplyText: fallback,
      );
      return fallback;
    }
  }

  /// Surface 5: Natural language explanation of deterministic insights.
  Future<String> explainInsight(String insightSummary) async {
    if (state.status == AIRequestStatus.sending) {
      return state.lastReplyText ?? '柯基正在为你解读规律...';
    }

    state = state.copyWith(status: AIRequestStatus.sending);
    final locale = ref.read(localeProvider);
    final context = _buildContext(
      surface: CompanionSurface.insights,
      insightText: insightSummary,
    );

    try {
      final reply = await _repository.sendMessage(
        userMessage: insightSummary,
        context: context,
        locale: locale,
      );
      state = state.copyWith(
        status: reply.isLocalFallback
            ? AIRequestStatus.fallback
            : AIRequestStatus.success,
        lastReplyText: reply.text,
      );
      return reply.text;
    } catch (_) {
      final fallback = '数据规律显示：$insightSummary。明天我们继续从极小一步开始！';
      state = state.copyWith(
        status: AIRequestStatus.fallback,
        lastReplyText: fallback,
      );
      return fallback;
    }
  }
}

final aiCompanionControllerProvider =
    NotifierProvider<AICompanionController, AICompanionState>(
      AICompanionController.new,
    );
