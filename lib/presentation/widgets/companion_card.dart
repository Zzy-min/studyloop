import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../../domain/models.dart';
import '../../providers.dart';
import '../view_models/ai_companion_controller.dart';
import 'corgi_chat_dialog.dart';

class DogCompanion extends ConsumerStatefulWidget {
  const DogCompanion({
    super.key,
    required this.state,
    this.message,
    this.compact = false,
    this.enableChat = true,
  });

  final DogState state;
  final String? message;
  final bool compact;
  final bool enableChat;

  @override
  ConsumerState<DogCompanion> createState() => _DogCompanionState();
}

class _DogCompanionState extends ConsumerState<DogCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    if (!bindingType.contains('Test')) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final label = widget.message ?? strings.dogLabel(widget.state);

    if (widget.compact) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enableChat ? () => showCorgiChatModal(context) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: StudyLoopColors.surface,
            borderRadius: StudyLoopRadius.borderPill,
            border: Border.all(color: StudyLoopColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CorgiPortrait(
                state: widget.state,
                size: CorgiPortraitSize.compact,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: StudyLoopColors.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: '$label ${widget.enableChat ? strings.companionChatBadge : ""}',
      button: widget.enableChat,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enableChat ? () => showCorgiChatModal(context) : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: StudyLoopColors.surface,
            borderRadius: StudyLoopRadius.borderXl,
            border: Border.all(color: StudyLoopColors.border),
            boxShadow: StudyLoopShadows.subtle,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            strings.companionCushionTitle,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: StudyLoopColors.textPrimary,
                            ),
                          ),
                        ),
                        if (widget.enableChat)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: StudyLoopColors.primaryLight,
                              borderRadius: StudyLoopRadius.borderPill,
                            ),
                            child: Text(
                              strings.companionChatBadgeQuiet,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: StudyLoopColors.primaryDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      strings.companionCushionMessage(widget.state),
                      style: const TextStyle(
                        fontSize: 13,
                        color: StudyLoopColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusChip(
                      label: strings.companionStatus(widget.state),
                      dotColor: StudyLoopColors.primary,
                      backgroundColor: StudyLoopColors.primaryLight,
                      textColor: StudyLoopColors.primaryDark,
                    ),
                    if (ref.watch(aiCompanionControllerProvider).activeProposal != null) ...[
                      const SizedBox(height: 10),
                      _buildHomeProposalCard(
                        context,
                        ref,
                        ref.watch(aiCompanionControllerProvider),
                      ),
                    ] else if (widget.enableChat) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: StudyLoopColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            strings.isChinese
                                ? '卡住了吗？和我说一句'
                                : 'Stuck? Talk with Corgi',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: StudyLoopColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final offset = math.sin(_controller.value * math.pi) * 2.5;
                  return Transform.translate(
                    offset: Offset(0, -offset),
                    child: child,
                  );
                },
                child: CorgiPortrait(
                  state: widget.state,
                  size: CorgiPortraitSize.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeProposalCard(
    BuildContext context,
    WidgetRef ref,
    AICompanionState aiState,
  ) {
    final proposal = aiState.activeProposal;
    if (proposal == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 柯基提议：${proposal.title}',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF166534),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {
              ref.read(sessionProvider.notifier).setTask(proposal.title);
              ref
                  .read(sessionProvider.notifier)
                  .chooseDuration(proposal.suggestedDuration.inSeconds);
              if (aiState.inferredBarrier != null) {
                ref
                    .read(sessionProvider.notifier)
                    .chooseBarrier(aiState.inferredBarrier!);
              }
              ref.read(aiCompanionControllerProvider.notifier).clearProposal();
              context.go('/task');
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '就从这一步开始',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
