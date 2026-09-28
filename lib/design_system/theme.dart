import 'package:flutter/material.dart';
import 'colors.dart';
import 'radius.dart';
import 'typography.dart';

abstract final class StudyLoopTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: StudyLoopColors.background,
      colorScheme: const ColorScheme.light(
        primary: StudyLoopColors.primary,
        onPrimary: Colors.white,
        primaryContainer: StudyLoopColors.primaryContainer,
        onPrimaryContainer: StudyLoopColors.primaryDark,
        surface: StudyLoopColors.surface,
        onSurface: StudyLoopColors.textPrimary,
        surfaceContainerHighest: StudyLoopColors.surfaceSecondary,
        outline: StudyLoopColors.border,
        error: StudyLoopColors.endEarlySalmon,
        onError: Colors.white,
      ),
      fontFamilyFallback: const [
        'PingFang SC',
        'Microsoft YaHei',
        'Segoe UI',
        'Noto Sans SC',
        'Segoe UI Emoji',
        'Roboto',
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: StudyLoopColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: StudyLoopTypography.pageTitle,
        iconTheme: IconThemeData(color: StudyLoopColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: StudyLoopColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: StudyLoopRadius.borderXl,
          side: const BorderSide(color: StudyLoopColors.border, width: 1.0),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: StudyLoopColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: const RoundedRectangleBorder(
            borderRadius: StudyLoopRadius.borderPill,
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: StudyLoopColors.surface,
        indicatorColor: StudyLoopColors.primaryLight,
        elevation: 2,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: StudyLoopColors.primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: StudyLoopColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: StudyLoopColors.primary,
              size: 24,
            );
          }
          return const IconThemeData(
            color: StudyLoopColors.textSecondary,
            size: 24,
          );
        }),
      ),
    );
  }
}
