import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../../domain/task_breakdown_repository.dart';
import '../../providers.dart';

class BarrierViewData {
  const BarrierViewData({
    required this.barrier,
    required this.title,
    required this.icon,
    required this.selected,
  });

  final StudyBarrier barrier;
  final String title;
  final IconData icon;
  final bool selected;
}

class MinimumActionViewData {
  const MinimumActionViewData({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.difficultyLabel,
    required this.canStart,
  });

  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final String difficultyLabel;
  final bool canStart;
}

class HomeViewState {
  const HomeViewState({
    required this.greeting,
    required this.barriers,
    this.selectedBarrier,
    this.suggestedAction,
    required this.companionState,
    this.isChinese = true,
    this.isLoading = false,
    this.errorMessage,
  });

  final String greeting;
  final List<BarrierViewData> barriers;
  final StudyBarrier? selectedBarrier;
  final MinimumActionViewData? suggestedAction;
  final DogState companionState;
  final bool isChinese;
  final bool isLoading;
  final String? errorMessage;
}

class HomeController extends Notifier<HomeViewState> {
  TaskBreakdownRepository get _breakdownRepo =>
      const DeterministicTaskBreakdownRepository();

  String _calculateGreeting(bool isChinese) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return isChinese ? '早上好！👋' : 'Good morning! 👋';
    } else if (hour >= 12 && hour < 18) {
      return isChinese ? '下午好！👋' : 'Good afternoon! 👋';
    } else {
      return isChinese ? '晚上好！👋' : 'Good evening! 👋';
    }
  }

  @override
  HomeViewState build() {
    final draft = ref.watch(sessionProvider);
    final strings = ref.watch(stringsProvider);
    final isChinese = strings.isChinese;

    final actionItem = _breakdownRepo.getSuggestedAction(
      barrier: draft.barrier,
      taskText: draft.taskText,
      taskType: draft.taskType,
      card: draft.card,
      plannedSeconds: draft.plannedSeconds,
      isChinese: isChinese,
    );

    final barrierList = [
      BarrierViewData(
        barrier: StudyBarrier.uncertainStart,
        title: strings.barrierShortLabel(StudyBarrier.uncertainStart),
        icon: Icons.filter_center_focus_rounded,
        selected: draft.barrier == StudyBarrier.uncertainStart,
      ),
      BarrierViewData(
        barrier: StudyBarrier.overload,
        title: strings.barrierShortLabel(StudyBarrier.overload),
        icon: Icons.layers_outlined,
        selected: draft.barrier == StudyBarrier.overload,
      ),
      BarrierViewData(
        barrier: StudyBarrier.phoneDistraction,
        title: strings.barrierShortLabel(StudyBarrier.phoneDistraction),
        icon: Icons.phone_android_rounded,
        selected: draft.barrier == StudyBarrier.phoneDistraction,
      ),
      BarrierViewData(
        barrier: StudyBarrier.tiredness,
        title: strings.barrierShortLabel(StudyBarrier.tiredness),
        icon: Icons.battery_charging_full_rounded,
        selected: draft.barrier == StudyBarrier.tiredness,
      ),
      BarrierViewData(
        barrier: StudyBarrier.perfectionism,
        title: strings.barrierShortLabel(StudyBarrier.perfectionism),
        icon: Icons.search_rounded,
        selected: draft.barrier == StudyBarrier.perfectionism,
      ),
    ];

    return HomeViewState(
      greeting: _calculateGreeting(isChinese),
      barriers: barrierList,
      selectedBarrier: draft.barrier,
      suggestedAction: MinimumActionViewData(
        id: actionItem.id,
        title: actionItem.title,
        description: actionItem.description,
        estimatedMinutes: actionItem.estimatedMinutes,
        difficultyLabel: actionItem.difficultyLabel,
        canStart: actionItem.canStart,
      ),
      companionState: DogState.waiting,
      isChinese: isChinese,
    );
  }

  void selectBarrier(StudyBarrier barrier) {
    ref.read(sessionProvider.notifier).chooseBarrier(barrier);
  }

  void toggleLanguage() {
    ref.read(localeProvider.notifier).toggle();
  }

  Future<bool> startFocusSession() async {
    final draft = ref.read(sessionProvider);
    if (draft.barrier == null) return false;
    await ref.read(timerProvider.notifier).start(draft);
    return true;
  }
}

final homeControllerProvider = NotifierProvider<HomeController, HomeViewState>(
  HomeController.new,
);
