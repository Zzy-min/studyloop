import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/hybrid_ai_companion_repository.dart';
import '../../domain/ai_companion_repository.dart';
import '../../domain/corgi_chat_engine.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import 'ai_companion_controller.dart';

class CorgiChatState {
  const CorgiChatState({
    required this.messages,
    this.isThinking = false,
    this.hasAcceptedPrivacy = false,
  });

  final List<CorgiChatMessage> messages;
  final bool isThinking;
  final bool hasAcceptedPrivacy;

  CorgiChatState copyWith({
    List<CorgiChatMessage>? messages,
    bool? isThinking,
    bool? hasAcceptedPrivacy,
  }) => CorgiChatState(
    messages: messages ?? this.messages,
    isThinking: isThinking ?? this.isThinking,
    hasAcceptedPrivacy: hasAcceptedPrivacy ?? this.hasAcceptedPrivacy,
  );
}

class CorgiChatViewModel extends Notifier<CorgiChatState> {
  AICompanionRepository get _repository =>
      ref.read(aiCompanionRepositoryProvider);

  @override
  CorgiChatState build() {
    final locale = ref.watch(localeProvider);
    final draft = ref.watch(sessionProvider);
    final initialGreeting = const CorgiChatEngine().getInitialGreeting(
      locale: locale,
      barrier: draft.barrier,
      taskText: draft.taskText,
      context: _buildCompanionContext(),
    );

    return CorgiChatState(
      messages: initialGreeting,
      isThinking: false,
      hasAcceptedPrivacy: false,
    );
  }

  void acceptPrivacy() {
    state = state.copyWith(hasAcceptedPrivacy: true);
  }

  CompanionContext _buildCompanionContext() {
    final draft = ref.read(sessionProvider);
    final timer = ref.read(timerProvider);
    final records = [
      ...(ref.read(recordsProvider).value ?? const <StudyRecord>[]),
    ]..sort((a, b) => b.endedAt.compareTo(a.endedAt));
    final last = records.isEmpty ? null : records.first;
    final companionState = timer.snapshot != null
        ? (timer.running
              ? DogState.focusing
              : timer.outcome == SessionOutcome.completed
              ? DogState.completed
              : DogState.resting)
        : DogState.waiting;

    return CompanionContext(
      currentBarrier: draft.barrier,
      taskType: draft.taskType,
      currentTaskTitle: draft.taskText,
      companionState: companionState,
      currentSessionDuration: timer.snapshot == null
          ? null
          : Duration(seconds: timer.snapshot!.accumulatedSeconds),
      lastSessionDuration: last == null
          ? null
          : Duration(seconds: last.actualSeconds),
      lastDifficulty: last?.difficulty,
      lastFocus: last?.focus,
      lastMood: last?.moodChange,
      recentSessionCount: records.length,
      lastEndedEarly: last?.outcome == SessionOutcome.interrupted,
    );
  }

  AICompanionContext buildAIContext() {
    final draft = ref.read(sessionProvider);
    final timer = ref.read(timerProvider);
    final records = ref.read(recordsProvider).value ?? const <StudyRecord>[];
    final now = DateTime.now();

    // Locally aggregate recent 7-day summary (minimal privacy footprint)
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
      primaryBarrier: draft.barrier,
    );

    final companionState = timer.snapshot != null
        ? (timer.running
              ? DogState.focusing
              : timer.outcome == SessionOutcome.completed
              ? DogState.completed
              : DogState.resting)
        : DogState.waiting;

    return AICompanionContext(
      barrier: draft.barrier,
      taskType: draft.taskType,
      currentTask: draft.taskText,
      state: companionState,
      currentFocusDuration: timer.snapshot == null
          ? null
          : Duration(seconds: timer.snapshot!.accumulatedSeconds),
      recentSummary: recentSummary,
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isThinking) return;

    final now = DateTime.now();
    final userMsg = CorgiChatMessage(
      id: 'user-${now.millisecondsSinceEpoch}',
      isUser: true,
      text: trimmed,
      timestamp: now,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    final locale = ref.read(localeProvider);
    final aiContext = buildAIContext();

    try {
      final reply = await _repository.sendMessage(
        userMessage: trimmed,
        context: aiContext,
        locale: locale,
      );

      final corgiMsg = CorgiChatMessage(
        id: 'corgi-${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: reply.text,
        timestamp: DateTime.now(),
        suggestedAction: reply.suggestedAction?.title,
        actionType: reply.suggestedAction?.actionType,
      );

      if (reply.suggestedAction != null) {
        ref
            .read(aiCompanionControllerProvider.notifier)
            .setExternalProposal(
              reply.suggestedAction!,
              barrier: reply.detectedBarrier,
            );
      }

      state = state.copyWith(
        messages: [...state.messages, corgiMsg],
        isThinking: false,
      );
    } catch (_) {
      // Robust safety fallback
      final fallbackReply = const CorgiChatEngine().respond(
        userText: trimmed,
        locale: locale,
        barrier: aiContext.barrier,
        currentTask: aiContext.currentTask ?? '',
        context: _buildCompanionContext(),
      );

      state = state.copyWith(
        messages: [...state.messages, fallbackReply],
        isThinking: false,
      );
    }
  }
}

final aiCompanionRepositoryProvider = Provider<AICompanionRepository>((ref) {
  return HybridAICompanionRepository();
});

final corgiChatViewModelProvider =
    NotifierProvider<CorgiChatViewModel, CorgiChatState>(
      CorgiChatViewModel.new,
    );
