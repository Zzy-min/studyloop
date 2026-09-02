import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/presentation/widgets/barrier_card.dart';
import 'package:studyloop/presentation/widgets/circular_timer.dart';
import 'package:studyloop/presentation/widgets/rating_pill.dart';
import 'package:studyloop/providers.dart';

void main() {
  testWidgets(
    'RatingPillGroup updates value and displays descriptive labels in Chinese',
    (tester) async {
      var current = 3;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [localeProvider.overrideWith(() => LocaleNotifier('zh'))],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => RatingPillGroup(
                  value: current,
                  isDifficulty: true,
                  onChanged: (v) => setState(() => current = v),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 分 · 中等'), findsOneWidget);

      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(current, 5);
      expect(find.text('5 分 · 极吃力'), findsOneWidget);
    },
  );

  testWidgets(
    'CircularTimerWidget shows action banner, formatted time, and status badge',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [localeProvider.overrideWith(() => LocaleNotifier('zh'))],
          child: const MaterialApp(
            home: Scaffold(
              body: CircularTimerWidget(
                remainingSeconds: 845,
                totalPlannedSeconds: 900,
                accumulatedSeconds: 55,
                isRunning: true,
                actionText: '写下微积分第一道习题的已知数值',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🎯 当前极小行动'), findsOneWidget);
      expect(find.text('写下微积分第一道习题的已知数值'), findsOneWidget);
      expect(find.text('14:05'), findsOneWidget);
      expect(find.text('正在专注'), findsOneWidget);
    },
  );

  testWidgets('BarrierCard responds to tap and displays semantic description', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarrierCard(
            barrier: StudyBarrier.phoneDistraction,
            title: '总是忍不住想看手机',
            description: '注意力分散，下意识寻找即时反馈',
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('总是忍不住想看手机'), findsOneWidget);
    expect(find.text('注意力分散，下意识寻找即时反馈'), findsOneWidget);

    await tester.tap(find.text('总是忍不住想看手机'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
