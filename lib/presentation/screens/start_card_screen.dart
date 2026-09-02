import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models.dart';
import '../../providers.dart';
import '../theme/app_theme.dart';
import '../widgets/page_frame.dart';

class StartCardScreen extends ConsumerWidget {
  const StartCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(sessionProvider);
    final strings = ref.watch(stringsProvider);
    final card = draft.card;

    if (card == null) {
      return PageFrame(
        title: strings.startCardTitle,
        onBack: () => context.go('/task'),
        child: Column(
          children: [
            Text(strings.startCardFallback),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/task'),
              child: Text(strings.editTask),
            ),
          ],
        ),
      );
    }

    final minutes = (draft.plannedSeconds / 60).round();

    return PageFrame(
      title: strings.startCardTitle,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/task');
        }
      },
      dogState: DogState.waiting,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x145FAF68),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            strings.startCardBadge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfff1f5f9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            strings.plannedMinutesText(minutes),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  card.action,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8fafc),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe2e8f0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppTheme.accentAmberDark,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.rationale,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.reductionStep(draft.reductionLevel),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (draft.reductionLevel < 3) ...[
            OutlinedButton.icon(
              onPressed: () => ref.read(sessionProvider.notifier).reduce(),
              icon: const Icon(Icons.compress_rounded, size: 18),
              label: Text(strings.makeItSmaller),
            ),
            const SizedBox(height: 10),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xfff0fdf4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xffbbf7d0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.sageGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.smallestActionReached,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.sageGreenDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          FilledButton.icon(
            onPressed: () async {
              await ref.read(timerProvider.notifier).start(draft);
              if (context.mounted) context.go('/focus');
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: Text(strings.startFocusing),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => context.go('/task'),
            child: Text(strings.editTask),
          ),
        ],
      ),
    );
  }
}
