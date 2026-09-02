import 'package:flutter/material.dart';
import '../colors.dart';
import 'cards.dart';

class MetricCardWidget extends StatelessWidget {
  const MetricCardWidget({
    super.key,
    required this.title,
    required this.mainValue,
    this.unit = '',
    this.badgeText,
    this.badgeIsPositive = true,
    this.barValues = const [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.45],
    this.barLabels = const ['5/6', '5/13', '5/20', '5/27', '6/3'],
  });

  final String title;
  final String mainValue;
  final String unit;
  final String? badgeText;
  final bool badgeIsPositive;
  final List<double> barValues;
  final List<String> barLabels;

  @override
  Widget build(BuildContext context) {
    return StudyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: StudyLoopColors.textSecondary,
                ),
              ),
              if (badgeText != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      badgeText!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: badgeIsPositive
                            ? StudyLoopColors.primary
                            : StudyLoopColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainValue,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: StudyLoopColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: StudyLoopColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Simple Bar Chart
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < barValues.length; i++) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: barValues[i].clamp(0.08, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: i == barValues.length - 2
                                      ? StudyLoopColors.primary
                                      : StudyLoopColors.primary.withValues(
                                          alpha: 0.55,
                                        ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Labels
          if (barLabels.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final lbl in barLabels)
                  Text(
                    lbl,
                    style: const TextStyle(
                      fontSize: 11,
                      color: StudyLoopColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
