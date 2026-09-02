import 'package:flutter/material.dart';
import '../colors.dart';
import '../radius.dart';
import 'cards.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.progressValue,
    this.progressText,
  });

  final String title;
  final String description;
  final double? progressValue;
  final String? progressText;

  @override
  Widget build(BuildContext context) {
    return StudyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: StudyLoopColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: StudyLoopColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: StudyLoopColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (progressValue != null) ...[
            ClipRRect(
              borderRadius: StudyLoopRadius.borderSm,
              child: LinearProgressIndicator(
                value: progressValue!.clamp(0.0, 1.0),
                backgroundColor: StudyLoopColors.surfaceSecondary,
                color: StudyLoopColors.primary,
                minHeight: 8,
              ),
            ),
            if (progressText != null) ...[
              const SizedBox(height: 8),
              Text(
                progressText!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: StudyLoopColors.primaryDark,
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: StudyLoopColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
