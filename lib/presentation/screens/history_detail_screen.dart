import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models.dart';
import '../../providers.dart';
import '../theme/app_theme.dart';
import '../view_models/history_view_model.dart';
import '../widgets/page_frame.dart';

class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsProvider);
    final strings = ref.watch(stringsProvider);

    return PageFrame(
      title: strings.historyDetailTitle,
      child: recordsAsync.when(
        data: (records) {
          final record = records.where((r) => r.id == id).firstOrNull;
          if (record == null) {
            return Center(
              child: Column(
                children: [
                  Text(strings.recordNotFound),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/history'),
                    child: Text(strings.back),
                  ),
                ],
              ),
            );
          }

          final isCompleted = record.outcome == SessionOutcome.completed;
          final plannedMin = (record.plannedSeconds / 60).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            record.taskText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xffecfdf5)
                                : const Color(0xfffffbeb),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCompleted
                                ? strings.statusCompleted
                                : strings.statusInterrupted,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isCompleted
                                  ? AppTheme.sageGreenDark
                                  : AppTheme.accentAmberDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      label: strings.taskTypeLabel,
                      value: strings.taskTypeTitle(record.taskType),
                    ),
                    _DetailRow(
                      label: strings.entryTitle,
                      value: strings.barrierLabel(record.barrier),
                    ),
                    _DetailRow(
                      label: strings.plannedTimeLabel,
                      value: strings.minutesUnit(plannedMin),
                    ),
                    _DetailRow(
                      label: strings.actualFocusLabel,
                      value: strings.focusedSecondsDetail(record.actualSeconds),
                    ),
                    _DetailRow(
                      label: strings.actualDifficultyLabel,
                      value: record.difficulty == null
                          ? (strings.isChinese
                                ? '未评价 (已跳过)'
                                : 'Not rated (skipped)')
                          : '${record.difficulty}/5 (${strings.difficultyRating(record.difficulty!)})',
                    ),
                    _DetailRow(
                      label: strings.focusLevelLabel,
                      value: record.focus == null
                          ? (strings.isChinese
                                ? '未评价 (已跳过)'
                                : 'Not rated (skipped)')
                          : '${record.focus}/5 (${strings.focusRating(record.focus!)})',
                    ),
                    _DetailRow(
                      label: strings.emotionalChangeLabel,
                      value: record.moodChange == null
                          ? (strings.isChinese
                                ? '未评价 (已跳过)'
                                : 'Not rated (skipped)')
                          : strings.moodName(record.moodChange!),
                    ),
                    if (record.nextAction.isNotEmpty)
                      _DetailRow(
                        label: strings.nextActionLabel,
                        value: record.nextAction,
                      ),
                    if (record.synthetic)
                      _DetailRow(
                        label: strings.completionStatusLabel,
                        value: strings.statusSynthetic,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, ref, strings, record),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.roseRed,
                ),
                label: Text(
                  strings.deleteRecordBtn,
                  style: const TextStyle(color: AppTheme.roseRed),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, stack) => Center(child: Text(strings.historyUnavailable)),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    StudyRecord record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteRecordTitle),
        content: Text(strings.deleteRecordContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.roseRed),
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(historyControllerProvider.notifier)
          .deleteRecord(record.id);
      if (context.mounted) context.go('/history');
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
