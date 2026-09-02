import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../colors.dart';
import '../radius.dart';
import '../shadows.dart';
import 'corgi_portrait.dart';
import 'status_chip.dart';

class CorgiCompanionWidget extends StatelessWidget {
  const CorgiCompanionWidget({
    super.key,
    required this.title,
    required this.body,
    required this.statusLabel,
    this.state = DogState.waiting,
    this.onTap,
  });

  final String title;
  final String body;
  final String statusLabel;
  final DogState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StudyLoopColors.surface,
        borderRadius: StudyLoopRadius.borderXl,
        border: Border.all(color: StudyLoopColors.border),
        boxShadow: StudyLoopShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: StudyLoopRadius.borderXl,
        child: InkWell(
          onTap: onTap,
          borderRadius: StudyLoopRadius.borderXl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: StudyLoopColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: StudyLoopColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      StatusChip(label: statusLabel),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CorgiPortrait(state: state, size: CorgiPortraitSize.medium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
