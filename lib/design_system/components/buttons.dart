import 'package:flutter/material.dart';
import '../colors.dart';
import '../radius.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor = StudyLoopColors.primary,
    this.foregroundColor = Colors.white,
    this.height = 52.0,
    this.isFullWidth = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: StudyLoopColors.border,
          disabledForegroundColor: StudyLoopColors.textDisabled,
          shape: const RoundedRectangleBorder(
            borderRadius: StudyLoopRadius.borderPill,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: child,
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.height = 50.0,
    this.isFullWidth = true,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final double height;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: StudyLoopColors.surface,
          foregroundColor: StudyLoopColors.textPrimary,
          side: const BorderSide(color: StudyLoopColors.border, width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: StudyLoopRadius.borderPill,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: StudyLoopColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
