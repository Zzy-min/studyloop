import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../theme/app_theme.dart';

class BarrierCard extends StatelessWidget {
  const BarrierCard({
    super.key,
    required this.barrier,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final StudyBarrier barrier;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  IconData _iconForBarrier(StudyBarrier barrier) => switch (barrier) {
    StudyBarrier.uncertainStart => Icons.explore_outlined,
    StudyBarrier.overload => Icons.layers_outlined,
    StudyBarrier.phoneDistraction => Icons.phonelink_erase_rounded,
    StudyBarrier.tiredness => Icons.battery_alert_rounded,
    StudyBarrier.perfectionism => Icons.rule_folder_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconForBarrier(barrier);

    return Semantics(
      selected: isSelected,
      button: true,
      label: '$title, $description',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
          color: isSelected ? const Color(0xfff0f7ff) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.cardBorderColor,
                  width: isSelected ? 1.8 : 1.2,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x0e2563eb),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryLight
                          : const Color(0xfff8fafc),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xffbfdbfe)
                            : const Color(0xffe2e8f0),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isSelected
                                ? const Color(0xff3b82f6)
                                : AppTheme.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : const Color(0xffcbd5e1),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
