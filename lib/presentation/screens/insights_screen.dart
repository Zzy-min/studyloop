import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';
import '../../domain/ai_companion_repository.dart';
import '../../domain/insights_repository.dart';
import '../../providers.dart';
import '../view_models/ai_companion_controller.dart';
import '../view_models/insights_view_model.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(insightsControllerProvider);
    final strings = ref.watch(stringsProvider);
    final isChinese = strings.isChinese;

    return Scaffold(
      backgroundColor: StudyLoopColors.background,
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: StudyLoopColors.primary),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isChinese
                      ? '洞察暂时无法加载，请稍后重试'
                      : 'Insights could not be loaded. Please try again.',
                  style: const TextStyle(color: StudyLoopColors.textSecondary),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  onPressed: () => ref.invalidate(insightsControllerProvider),
                  label: isChinese ? '重试' : 'Retry',
                  isFullWidth: false,
                ),
              ],
            ),
          ),
          data: (state) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                    children: [
                      // Page Title & Subtitle
                      Text(
                        strings.insightsTitle,
                        style: StudyLoopTypography.pageTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.insightsSubtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: StudyLoopColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Range Selector Segmented Pills: 周 | 月 | 3月 | 全部
                      _buildRangeSelector(context, ref, state, strings),
                      const SizedBox(height: 18),

                      if (!state.hasEnoughData) ...[
                        EmptyStateWidget(
                          title: strings.insightsNeedMoreRecordsTitle,
                          progressValue: (state.recentRecordCount / 3).clamp(
                            0.0,
                            1.0,
                          ),
                          progressText: strings.insightProgress(
                            state.recentRecordCount,
                            3,
                          ),
                          description: strings.insightsNeedMoreRecordsDesc,
                        ),
                      ] else ...[
                        MetricCardWidget(
                          title: strings.focusDuration,
                          mainValue: state.focusDuration.totalHours
                              .toStringAsFixed(1),
                          unit: strings.hoursUnit,
                          badgeText: state.focusDuration.changePercent == null
                              ? null
                              : '${strings.comparedToLastMonth} ${state.focusDuration.changePercent! >= 0 ? '+' : '-'}${state.focusDuration.changePercent!.abs().toStringAsFixed(0)}%',
                          badgeIsPositive:
                              (state.focusDuration.changePercent ?? 0) >= 0,
                          barValues: state.focusDuration.points
                              .map((p) => p.value)
                              .toList(),
                          barLabels: state.focusDuration.points
                              .map((p) => p.dateLabel)
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                        if (state.bestDuration != null) ...[
                          PatternCardWidget(
                            title: strings.bestFocusDurationTitle,
                            value: state.bestDuration!.durationLabel,
                            subtitle: strings.bestFocusDurationSubtitle,
                            iconData: Icons.access_time_filled_rounded,
                            iconColor: StudyLoopColors.primary,
                            iconBgColor: StudyLoopColors.primaryLight,
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (state.bestTime != null) ...[
                          PatternCardWidget(
                            title: strings.bestTimeSlotTitle,
                            value: state.bestTime!.timeWindowLabel,
                            subtitle: strings.bestTimeSlotSubtitle,
                            iconData: Icons.wb_sunny_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            iconBgColor: const Color(0xFFFEF3C7),
                          ),
                          const SizedBox(height: 14),
                        ],
                        DonutDistributionCard(
                          title: strings.taskDistributionTitle,
                          items: state.taskDistribution.categories
                              .map(
                                (cat) => DonutSliceData(
                                  label: cat.categoryName,
                                  percentage: cat.percentage,
                                  color: Color(cat.colorHex),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildCorgiInsightInterpretationCard(
                          context,
                          ref,
                          state,
                          strings,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Deterministic Rule Explanation Accordion
                      StudyCard(
                        onTap: () => _showRuleExplanation(
                          context,
                          state.explanation,
                          strings,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: StudyLoopColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.explanation.title,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: StudyLoopColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    isChinese
                                        ? '点击查看本地确定性计算规则与样本依据'
                                        : 'Tap to view local calculation rules and sample data',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: StudyLoopColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: StudyLoopColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (state.isPro &&
                          state.hasEnoughData &&
                          state.longTermInsights.isNotEmpty) ...[
                        Text(
                          strings.longTermPatterns,
                          style: StudyLoopTypography.sectionTitle,
                        ),
                        const SizedBox(height: 10),
                        for (final insight in state.longTermInsights) ...[
                          StudyCard(
                            child: Text(
                              insight.text,
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                color: StudyLoopColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                      if (!state.isPro)
                        SecondaryButton(
                          onPressed: () => context.push('/paywall'),
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: StudyLoopColors.primary,
                          ),
                          label: strings.unlockProInsights,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRangeSelector(
    BuildContext context,
    WidgetRef ref,
    InsightsViewState state,
    AppStrings strings,
  ) {
    final ranges = [
      (InsightRange.week, strings.insightsRangeWeek, false),
      (InsightRange.month, strings.insightsRangeMonth, false),
      (InsightRange.threeMonths, strings.insightsRange3Months, !state.isPro),
      (InsightRange.all, strings.insightsRangeAll, !state.isPro),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2EB),
        borderRadius: StudyLoopRadius.borderPill,
      ),
      child: Row(
        children: [
          for (final (range, label, locked) in ranges) ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (locked) {
                    ref
                        .read(paywallOriginProvider.notifier)
                        .setOrigin('/insights');
                    context.push('/paywall');
                  } else {
                    ref
                        .read(insightsControllerProvider.notifier)
                        .selectRange(range);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: state.selectedRange == range
                        ? StudyLoopColors.surface
                        : Colors.transparent,
                    borderRadius: StudyLoopRadius.borderPill,
                    boxShadow: state.selectedRange == range
                        ? StudyLoopShadows.subtle
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (locked) ...[
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: StudyLoopColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: state.selectedRange == range
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: locked
                                ? StudyLoopColors.textTertiary
                                : state.selectedRange == range
                                ? StudyLoopColors.textPrimary
                                : StudyLoopColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRuleExplanation(
    BuildContext context,
    InsightExplanation explanation,
    AppStrings strings,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StudyLoopColors.surface,
        shape: RoundedRectangleBorder(borderRadius: StudyLoopRadius.borderXl),
        title: Text(
          explanation.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: StudyLoopColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${explanation.description}\n\n当前包含样本：${explanation.sampleSize} 次\n\n${explanation.ruleDescription}',
              style: const TextStyle(
                fontSize: 13,
                color: StudyLoopColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: StudyLoopColors.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: StudyLoopRadius.borderPill,
              ),
            ),
            child: Text(strings.isChinese ? '我知道了' : 'Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildCorgiInsightInterpretationCard(
    BuildContext context,
    WidgetRef ref,
    InsightsViewState state,
    AppStrings strings,
  ) {
    final aiState = ref.watch(aiCompanionControllerProvider);
    final isExplaining = aiState.status == AIRequestStatus.sending;
    final interpretation = aiState.lastReplyText;
    final isChinese = strings.isChinese;

    final summaryText =
        '累计专注 ${state.focusDuration.totalHours.toStringAsFixed(1)} 小时，'
        '最佳时段 ${state.bestTime?.timeWindowLabel ?? "暂无"}，'
        '最佳单次时长 ${state.bestDuration?.durationLabel ?? "暂无"}。';

    return StudyCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: StudyLoopColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isChinese ? '柯基解读规律 (Explain with Corgi)' : 'Explain with Corgi',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: StudyLoopColors.textPrimary,
                  ),
                ),
              ),
              if (interpretation == null && !isExplaining)
                FilledButton.tonal(
                  onPressed: () {
                    ref
                        .read(aiCompanionControllerProvider.notifier)
                        .explainInsight(summaryText);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: StudyLoopColors.primaryLight,
                    foregroundColor: StudyLoopColors.primaryDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isChinese ? '让柯基解读' : 'Explain',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (isExplaining)
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      StudyLoopColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '柯基正在为你解读规律...',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: StudyLoopColors.textSecondary,
                  ),
                ),
              ],
            )
          else
            Text(
              interpretation ??
                  (isChinese
                      ? '柯基可以根据你的专注时长与时段，用通俗好懂的语言为你提炼学习规律和明日建议。点击右上方“让柯基解读”即可生成。'
                      : 'Corgi can explain your learning patterns in friendly terms with 1 actionable suggestion.'),
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: StudyLoopColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
