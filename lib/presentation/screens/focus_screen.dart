import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../view_models/ai_companion_controller.dart';
import '../view_models/focus_view_model.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusState = ref.watch(focusControllerProvider);
    final focusCtrl = ref.read(focusControllerProvider.notifier);
    final strings = ref.watch(stringsProvider);

    ref.listen(focusControllerProvider, (previous, next) {
      if (next.status == FocusStatus.completed) {
        context.go('/reflection');
      }
    });

    if (!focusState.hasActiveSession) {
      return Scaffold(
        backgroundColor: StudyLoopColors.background,
        appBar: AppBar(title: Text(strings.focusTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                strings.noActiveSession,
                style: const TextStyle(color: StudyLoopColors.textSecondary),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                onPressed: () => context.go('/'),
                label: strings.returnHome,
                isFullWidth: false,
              ),
            ],
          ),
        ),
      );
    }

    final actionText = focusState.actionInstruction;
    final plannedMinutes = focusState.plannedMinutes;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmEndEarly(context, focusCtrl, strings);
        }
      },
      child: Scaffold(
        backgroundColor: StudyLoopColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar: ✕ , 专注中 (仅统计前台时间) , 🎵
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: strings.closeFocusTooltip,
                      onPressed: () =>
                          _confirmEndEarly(context, focusCtrl, strings),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: StudyLoopColors.textPrimary,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          strings.focusingTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: StudyLoopColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.onlyForeground,
                          style: const TextStyle(
                            fontSize: 11,
                            color: StudyLoopColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: strings.isChinese ? '白噪音' : 'White noise',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              strings.isChinese
                                  ? '白噪音伴读功能将在下一版本呈现'
                                  : 'White noise coming soon',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.music_note_rounded,
                        size: 22,
                        color: StudyLoopColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  children: [
                    const SizedBox(height: 12),

                    // Central Large Circular Progress Ring with Headphones Corgi & Digits
                    FocusTimerWidget(
                      remainingSeconds: focusState.remainingSeconds,
                      totalPlannedSeconds: plannedMinutes * 60,
                      isRunning: !focusState.isPaused,
                      onTogglePlayPause: () {
                        if (!focusState.isPaused) {
                          focusCtrl.pause();
                        } else {
                          focusCtrl.resume();
                        }
                      },
                      corgiState: focusState.isPaused
                          ? DogState.resting
                          : DogState.focusing,
                      pauseLabel: strings.pause,
                      resumeLabel: strings.resume,
                    ),

                    const SizedBox(height: 28),

                    // Current Task Card with Green Accent Line
                    StudyCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      onTap: () => context.push('/task'),
                      child: Row(
                        children: [
                          Container(
                            width: 3.5,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: StudyLoopColors.primary,
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              actionText,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: StudyLoopColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: StudyLoopColors.textTertiary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Focus Goal Setting Row
                    StudyCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.focusTarget,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: StudyLoopColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strings.minutesUnit(plannedMinutes),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: StudyLoopColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.push('/task'),
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              strings.edit,
                              style: const TextStyle(
                                color: StudyLoopColors.primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Non-punitive reassurance notice
                    Center(
                      child: Text(
                        strings.endEarlyFriendlyNotice,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: StudyLoopColors.textTertiary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCorgiFocusCompanionSheet(
                          context,
                          ref,
                          focusCtrl,
                          strings,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: StudyLoopColors.primaryDark,
                          side: const BorderSide(color: StudyLoopColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(
                          Icons.pets_rounded,
                          size: 16,
                          color: StudyLoopColors.primary,
                        ),
                        label: const Text(
                          '陪我一下 (AI 陪伴)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom CTA: 结束并保存 (Warm Salmon Red pill button)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SecondaryButton(
                  onPressed: () =>
                      _confirmEndEarly(context, focusCtrl, strings),
                  label: strings.endAndSaveBtn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmEndEarly(
    BuildContext context,
    FocusController focusCtrl,
    AppStrings strings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StudyLoopColors.surface,
        shape: RoundedRectangleBorder(borderRadius: StudyLoopRadius.borderXl),
        title: Text(
          strings.endEarlyDialogTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: StudyLoopColors.textPrimary,
          ),
        ),
        content: Text(
          strings.endEarlyDialogContent,
          style: const TextStyle(
            fontSize: 14,
            color: StudyLoopColors.textSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.returnToTimer),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: StudyLoopColors.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: StudyLoopRadius.borderPill,
              ),
            ),
            child: Text(strings.saveFocusedTime),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await focusCtrl.finishEarly();
      if (context.mounted) context.go('/reflection');
    }
  }

  void _showCorgiFocusCompanionSheet(
    BuildContext context,
    WidgetRef ref,
    FocusController focusCtrl,
    AppStrings strings,
  ) {
    final timer = ref.read(timerProvider);
    final elapsed = timer.snapshot != null
        ? Duration(seconds: timer.snapshot!.accumulatedSeconds)
        : Duration.zero;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return FutureBuilder<String>(
          future: ref
              .read(aiCompanionControllerProvider.notifier)
              .accompanyFocus(elapsed),
          builder: (context, snapshot) {
            final text = snapshot.data;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: StudyLoopColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const CorgiPortrait(
                          state: DogState.focusing,
                          size: CorgiPortraitSize.compact,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '柯基在安静陪着你',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: StudyLoopColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '已经专注了 ${elapsed.inMinutes} 分钟，已算入学习成果',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: StudyLoopColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: StudyLoopColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: StudyLoopColors.border),
                      ),
                      child: isLoading
                          ? const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      StudyLoopColors.primary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '柯基正轻轻贴近你...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: StudyLoopColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              text ?? '慢慢来，我们不慌。已经做得很好了！',
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: StudyLoopColors.textPrimary,
                              ),
                            ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(sheetCtx).pop();
                              focusCtrl.finishEarly();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: StudyLoopColors.endEarlySalmon,
                              side: const BorderSide(
                                color: StudyLoopColors.border,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('保存并休息'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(sheetCtx).pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: StudyLoopColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('继续专注'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
