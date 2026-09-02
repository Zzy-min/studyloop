import 'package:flutter/material.dart';
import '../../design_system/colors.dart';
import '../../design_system/theme.dart';

class AppTheme {
  const AppTheme._();

  // Natural Sage Green Palette matching UI Mockups
  static const primaryColor = StudyLoopColors.primary;
  static const primaryLight = StudyLoopColors.primaryLight;
  static const primaryContainer = StudyLoopColors.primaryContainer;
  static const primaryDark = StudyLoopColors.primaryDark;

  static const accentAmber = Color(0xfff59e0b);
  static const accentAmberLight = Color(0xfffef3c7);
  static const accentAmberDark = Color(0xffb45309);

  static const sageGreen = StudyLoopColors.primary;
  static const sageGreenLight = StudyLoopColors.primaryLight;
  static const sageGreenDark = StudyLoopColors.primaryDark;

  static const roseRed = StudyLoopColors.endEarlySalmon;
  static const roseRedLight = Color(0xfffef2f2);

  static const textPrimary = StudyLoopColors.textPrimary;
  static const textSecondary = StudyLoopColors.textSecondary;
  static const textTertiary = StudyLoopColors.textTertiary;

  static const cardBorderColor = StudyLoopColors.border;
  static const cardBorderSelected = StudyLoopColors.primary;
  static const backgroundColor = StudyLoopColors.background;
  static const surfaceColor = StudyLoopColors.surface;

  static ThemeData get lightTheme => StudyLoopTheme.lightTheme;
}
