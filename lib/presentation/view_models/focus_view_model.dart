import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../../providers.dart';

enum FocusStatus { idle, running, paused, completed, interrupted }

class FocusViewState {
  const FocusViewState({
    required this.taskTitle,
    required this.actionInstruction,
    required this.plannedMinutes,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.formattedRemaining,
    required this.progress,
    required this.status,
    required this.companionState,
    required this.isPaused,
    required this.hasActiveSession,
  });

  final String taskTitle;
  final String actionInstruction;
  final int plannedMinutes;
  final int elapsedSeconds;
  final int remainingSeconds;
  final String formattedRemaining;
  final double progress;
  final FocusStatus status;
  final DogState companionState;
  final bool isPaused;
  final bool hasActiveSession;
}

class FocusController extends Notifier<FocusViewState> {
  String _formatSeconds(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  FocusViewState build() {
    final timer = ref.watch(timerProvider);
    final snapshot = timer.snapshot;

    if (snapshot == null) {
      return const FocusViewState(
        taskTitle: '',
        actionInstruction: '',
        plannedMinutes: 0,
        elapsedSeconds: 0,
        remainingSeconds: 0,
        formattedRemaining: '00:00',
        progress: 0.0,
        status: FocusStatus.idle,
        companionState: DogState.waiting,
        isPaused: false,
        hasActiveSession: false,
      );
    }

    final totalSeconds = snapshot.draft.plannedSeconds > 0
        ? snapshot.draft.plannedSeconds
        : 900;
    final remaining = snapshot.remainingSeconds;
    final elapsed = snapshot.accumulatedSeconds;
    final progress = (elapsed / totalSeconds).clamp(0.0, 1.0);

    final status = switch (timer.outcome) {
      SessionOutcome.completed => FocusStatus.completed,
      SessionOutcome.interrupted => FocusStatus.interrupted,
      null => timer.running ? FocusStatus.running : FocusStatus.paused,
    };

    return FocusViewState(
      taskTitle: snapshot.draft.taskText,
      actionInstruction: snapshot.draft.card?.action ?? snapshot.draft.taskText,
      plannedMinutes: (totalSeconds / 60).round(),
      elapsedSeconds: elapsed,
      remainingSeconds: remaining,
      formattedRemaining: _formatSeconds(remaining),
      progress: progress,
      status: status,
      companionState:
          status == FocusStatus.paused || status == FocusStatus.interrupted
          ? DogState.resting
          : status == FocusStatus.completed
          ? DogState.completed
          : DogState.focusing,
      isPaused: !timer.running,
      hasActiveSession: true,
    );
  }

  void pause() {
    ref.read(timerProvider.notifier).pauseByUser();
  }

  void resume() {
    ref.read(timerProvider.notifier).continueSession();
  }

  Future<void> finishEarly() async {
    await ref.read(timerProvider.notifier).finishEarly();
  }
}

final focusControllerProvider =
    NotifierProvider<FocusController, FocusViewState>(FocusController.new);
