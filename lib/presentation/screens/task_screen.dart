import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ime_helper.dart';
import '../../domain/ai_companion_repository.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../theme/app_theme.dart';
import '../view_models/ai_companion_controller.dart';
import '../widgets/page_frame.dart';
import '../widgets/task_type_selector.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  late final TextEditingController controller;
  late final FocusNode taskFocus;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: ref.read(sessionProvider).taskText,
    );
    taskFocus = FocusNode(debugLabel: 'task-name-field');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      taskFocus.requestFocus();
      await ImeHelper.showSoftInput();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    taskFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(sessionProvider);
    final strings = ref.watch(stringsProvider);
    final plannedMinutes = draft.plannedSeconds ~/ 60;

    if (!taskFocus.hasFocus && controller.text != draft.taskText) {
      controller.text = draft.taskText;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }

    return PageFrame(
      title: strings.taskScreenShortTitle,
      subtitle: strings.taskScreenSubtitle,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      dogState: draft.taskText.isEmpty ? DogState.prompting : DogState.waiting,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('task-name-field'),
            controller: controller,
            focusNode: taskFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            enableInteractiveSelection: true,
            onTap: () {
              if (!taskFocus.hasFocus) {
                taskFocus.requestFocus();
              }
              Future<void>.delayed(Duration.zero, ImeHelper.showSoftInput);
            },
            decoration: InputDecoration(
              labelText: strings.taskFieldLabel,
              hintText: strings.taskFieldHint,
              prefixIcon: const Icon(
                Icons.edit_note_rounded,
                color: AppTheme.primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: ref.read(sessionProvider.notifier).setTask,
          ),
          const SizedBox(height: 10),
          _buildAIMicroActionSection(context, draft, strings),
          const SizedBox(height: 16),
          TaskTypeSelector(
            selected: draft.taskType,
            strings: strings,
            onSelected: ref.read(sessionProvider.notifier).chooseType,
          ),
          if (draft.taskType == TaskType.examRevision) ...[
            const SizedBox(height: 14),
            ExamSubtypeSelector(
              selected: draft.examSubtype,
              strings: strings,
              onSelected: ref.read(sessionProvider.notifier).chooseSubtype,
            ),
          ],
          const SizedBox(height: 20),
          Text(
            strings.availableTimeLabel,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in const [5, 10, 15, 25])
                ChoiceChip(
                  label: Text(
                    strings.minutesUnit(minutes),
                    style: TextStyle(
                      fontWeight: plannedMinutes == minutes
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: plannedMinutes == minutes
                          ? Colors.white
                          : AppTheme.textPrimary,
                    ),
                  ),
                  selected: plannedMinutes == minutes,
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: plannedMinutes == minutes
                          ? AppTheme.primaryColor
                          : AppTheme.cardBorderColor,
                      width: plannedMinutes == minutes ? 1.5 : 1.0,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(sessionProvider.notifier)
                          .chooseDuration(minutes * 60);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: draft.isValid
                ? () {
                    ref.read(sessionProvider.notifier).generateCard();
                    context.go('/card');
                  }
                : null,
            child: Text(strings.createStartCardBtn),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMicroActionSection(
    BuildContext context,
    SessionDraft draft,
    AppStrings strings,
  ) {
    final aiState = ref.watch(aiCompanionControllerProvider);
    final isSending = aiState.status == AIRequestStatus.sending;
    final proposal = aiState.activeProposal;

    if (isSending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                strings.aiMicroActionLoading,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (proposal != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    strings.aiMicroActionSuggestion,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => ref
                      .read(aiCompanionControllerProvider.notifier)
                      .clearProposal(),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              proposal.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF166534),
              ),
            ),
            if (proposal.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                proposal.description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        strings.minutesUnit(
                          proposal.suggestedDuration.inMinutes,
                        ),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    controller.text = proposal.title;
                    ref.read(sessionProvider.notifier).setTask(proposal.title);
                    ref
                        .read(sessionProvider.notifier)
                        .chooseDuration(proposal.suggestedDuration.inSeconds);
                    ref
                        .read(aiCompanionControllerProvider.notifier)
                        .clearProposal();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(strings.aiMicroActionAdopted),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 14),
                  label: Text(
                    strings.aiMicroActionAdopt,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          final query = controller.text.trim();
          ref
              .read(aiCompanionControllerProvider.notifier)
              .proposeMicroAction(query, barrier: draft.barrier);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              Text(
                strings.aiMicroActionCta,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
