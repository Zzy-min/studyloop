import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../domain/models.dart';
import '../../l10n/app_strings.dart';

class TaskTypeSelector extends StatelessWidget {
  const TaskTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.strings,
  });

  final TaskType? selected;
  final ValueChanged<TaskType> onSelected;
  final AppStrings strings;

  IconData _iconFor(TaskType type) => switch (type) {
    TaskType.examRevision => Icons.school_rounded,
    TaskType.homework => Icons.assignment_outlined,
    TaskType.programmingPractice => Icons.code_rounded,
    TaskType.paperWriting => Icons.edit_note_rounded,
    TaskType.reading => Icons.menu_book_outlined,
    TaskType.memorization => Icons.psychology_alt_outlined,
    TaskType.preview => Icons.preview_outlined,
    TaskType.project => Icons.account_tree_outlined,
    TaskType.other => Icons.more_horiz_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.taskTypeLabel,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: StudyLoopColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in TaskType.values)
              FilterChip(
                avatar: Icon(
                  _iconFor(type),
                  size: 16,
                  color: selected == type
                      ? StudyLoopColors.primaryDark
                      : StudyLoopColors.textSecondary,
                ),
                label: Text(strings.taskTypeTitle(type)),
                selected: selected == type,
                showCheckmark: true,
                checkmarkColor: StudyLoopColors.primaryDark,
                selectedColor: StudyLoopColors.primaryLight,
                backgroundColor: StudyLoopColors.surface,
                side: BorderSide(
                  color: selected == type
                      ? StudyLoopColors.borderSelected
                      : StudyLoopColors.border,
                  width: selected == type ? 1.5 : 1,
                ),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: selected == type
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selected == type
                      ? StudyLoopColors.primaryDark
                      : StudyLoopColors.textPrimary,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => onSelected(type),
              ),
          ],
        ),
      ],
    );
  }
}

class ExamSubtypeSelector extends StatelessWidget {
  const ExamSubtypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.strings,
  });

  final ExamSubtype? selected;
  final ValueChanged<ExamSubtype> onSelected;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.revisionTypeLabel,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: StudyLoopColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final subtype in ExamSubtype.values)
              ChoiceChip(
                label: Text(strings.examSubtypeTitle(subtype)),
                selected: selected == subtype,
                selectedColor: StudyLoopColors.primaryLight,
                backgroundColor: StudyLoopColors.surface,
                showCheckmark: true,
                checkmarkColor: StudyLoopColors.primaryDark,
                side: BorderSide(
                  color: selected == subtype
                      ? StudyLoopColors.borderSelected
                      : StudyLoopColors.border,
                  width: selected == subtype ? 1.5 : 1,
                ),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: selected == subtype
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selected == subtype
                      ? StudyLoopColors.primaryDark
                      : StudyLoopColors.textPrimary,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => onSelected(subtype),
              ),
          ],
        ),
      ],
    );
  }
}
