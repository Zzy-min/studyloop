import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models.dart';
import '../../providers.dart';
import '../theme/app_theme.dart';
import '../widgets/page_frame.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsProvider);
    final strings = ref.watch(stringsProvider);

    return PageFrame(
      title: strings.historyTitle,
      child: recordsAsync.when(
        data: (records) {
          final sorted = [...records]
            ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => context.go('/insights'),
                icon: const Icon(Icons.insights_rounded, size: 20),
                label: Text(strings.viewPatterns),
              ),
              const SizedBox(height: 16),
              if (records.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.cardBorderColor),
                          ),
                          child: const Icon(
                            Icons.auto_stories_outlined,
                            color: AppTheme.primaryColor,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          strings.historyEmpty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => context.go('/'),
                          child: Text(strings.beginFirstSession),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final record in sorted) ...[
                  _HistoryRecordCard(record: record),
                  const SizedBox(height: 10),
                ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, stack) => Center(child: Text(strings.historyUnavailable)),
      ),
    );
  }
}

class _HistoryRecordCard extends ConsumerWidget {
  const _HistoryRecordCard({required this.record});
  final StudyRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isCompleted = record.outcome == SessionOutcome.completed;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => context.push('/history/${record.id}'),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xffecfdf5)
                      : const Color(0xfffffbeb),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xffa7f3d0)
                        : const Color(0xfffde68a),
                  ),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                  color: isCompleted
                      ? AppTheme.sageGreenDark
                      : AppTheme.accentAmberDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.taskText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.historySubtitle(
                        record.actualSeconds,
                        isCompleted,
                        record.synthetic,
                      ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
