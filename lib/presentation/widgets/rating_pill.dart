import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../theme/app_theme.dart';

class RatingPillGroup extends ConsumerWidget {
  const RatingPillGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isDifficulty,
    this.minValue = 1,
    this.maxValue = 5,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool isDifficulty;
  final int minValue;
  final int maxValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final desc = isDifficulty
        ? strings.difficultyRating(value)
        : strings.focusRating(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = minValue; i <= maxValue; i++) ...[
              Expanded(
                child: _RatingPill(
                  number: i,
                  isSelected: value == i,
                  onTap: () => onChanged(i),
                ),
              ),
              if (i < maxValue) const SizedBox(width: 8),
            ],
          ],
        ),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              strings.isChinese ? '$value 分 · $desc' : desc,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.cardBorderColor,
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x145FAF68),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
