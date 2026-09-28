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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: StudyLoopColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                mainValue,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: StudyLoopColors.textPrimary,
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
              if (badgeText != null) ...[
                const Spacer(),
                Flexible(
                  child: Text(
                    badgeText!,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: badgeIsPositive
                          ? StudyLoopColors.primary
                          : StudyLoopColors.textSecondary,
                    ),
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
                              heightFactor: barValues[i].clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFBDD5AA),
                                      StudyLoopColors.primary,
                                    ],
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
          const Divider(
            height: 1,
            thickness: .7,
            color: StudyLoopColors.border,
          ),
          const SizedBox(height: 8),

          // Labels
          if (barLabels.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < barLabels.length; i++)
                  if (i == 0 ||
                      i == barLabels.length - 1 ||
                      i %
                              ((barLabels.length / 4).ceil().clamp(
                                1,
                                barLabels.length,
                              )) ==
                          0)
                    Flexible(
                      child: Text(
                        barLabels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: StudyLoopColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              ],
            ),
        ],
      ),
    );
  }
}
