import 'package:flutter/material.dart';
import '../colors.dart';
import '../radius.dart';
import '../shadows.dart';

class StudyCard extends StatelessWidget {
  const StudyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18.0),
    this.backgroundColor = StudyLoopColors.surface,
    this.borderColor = StudyLoopColors.border,
    this.borderWidth = 1.0,
    this.borderRadius = StudyLoopRadius.borderXl,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: StudyLoopShadows.subtle,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Ink(padding: padding, decoration: decoration, child: child),
        ),
      );
    }

    return Container(padding: padding, decoration: decoration, child: child);
  }
}
