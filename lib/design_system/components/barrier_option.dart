import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../colors.dart';
import '../radius.dart';

class BarrierOptionItem extends StatelessWidget {
  const BarrierOptionItem({
    super.key,
    required this.barrier,
    required this.label,
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
    required this.isSelected,
    required this.onTap,
  });

  final StudyBarrier barrier;
  final String label;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? StudyLoopColors.primaryLight
                : StudyLoopColors.surface,
            borderRadius: StudyLoopRadius.borderLg,
            border: Border.all(
              color: isSelected
                  ? StudyLoopColors.primary
                  : StudyLoopColors.border,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : iconBgColor,
                  borderRadius: StudyLoopRadius.borderMd,
                ),
                child: Icon(iconData, size: 22, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? StudyLoopColors.primaryDark
                      : StudyLoopColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
