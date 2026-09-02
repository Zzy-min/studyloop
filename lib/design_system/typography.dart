import 'package:flutter/material.dart';
import 'colors.dart';

abstract final class StudyLoopTypography {
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: StudyLoopColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: StudyLoopColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: StudyLoopColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: StudyLoopColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: StudyLoopColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: StudyLoopColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: StudyLoopColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: StudyLoopColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle captionTertiary = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: StudyLoopColors.textTertiary,
    height: 1.4,
  );

  static const TextStyle timerDigits = TextStyle(
    fontSize: 54,
    fontWeight: FontWeight.w700,
    color: StudyLoopColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -1.0,
  );
}
