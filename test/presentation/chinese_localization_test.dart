import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/app.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/providers.dart';

ProviderScope appWithZh(AppDatabase database, {List extra = const []}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      localeProvider.overrideWith(() => LocaleNotifier('zh')),
      ...extra,
    ],
    child: const StudyLoopApp(),
  );
}

Future<void> tapVisible(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test('paywall copy sells long-term insights rather than full history', () {
    expect(
      AppStrings.ofLocale('en').unlockProInsights,
      'Unlock long-term pattern comparisons',
    );
    expect(
      AppStrings.ofLocale('en').paywallFeature2,
      'Long-term trends across 3 months and all records',
    );
    expect(
      AppStrings.ofLocale('en').paywallHeadline.toLowerCase(),
      isNot(contains('full history')),
    );
    expect(AppStrings.ofLocale('zh').paywallFeature2, contains('3 个月'));
    expect(AppStrings.ofLocale('zh').paywallHeadline, contains('全部学习记录永久免费'));
  });

  test('Test Store notice clearly states that the purchase is not charged', () {
    expect(
      AppStrings.ofLocale('zh').paywallTestStoreNotice,
      '此调试版本使用 RevenueCat 测试商店，不会产生真实扣款。',
    );
    expect(
      AppStrings.ofLocale('en').paywallTestStoreNotice,
      'This debug build uses RevenueCat Test Store. No real charge is made.',
    );
  });

  testWidgets('Chinese launch displays complete localized barrier copy', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    await tester.pumpWidget(appWithZh(database));
    await tester.pumpAndSettle();

    expect(find.text('今天想解决什么问题？'), findsOneWidget);
    expect(find.text('我不知道从何开始'), findsOneWidget);
    expect(find.text('要做的事太多了'), findsOneWidget);
    expect(find.text('总是忍不住想看手机'), findsOneWidget);
    expect(find.text('太累了，脑子转不动'), findsOneWidget);
    expect(find.text('一直在做准备，迟迟不开始'), findsOneWidget);
  });

  testWidgets('Chinese task and start card flow with reduction', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    await tester.pumpWidget(appWithZh(database));
    await tester.pumpAndSettle();

    await tapVisible(tester, '要做的事太多了');
    await tapVisible(tester, '写下任务');

    expect(find.text('写下任务'), findsWidgets);
    expect(find.text('哪怕只是写下课程或项目名称也可以'), findsOneWidget);
    final field = find.byKey(const Key('task-name-field'));
    await tester.enterText(field, '微积分期末复习');
    await tester.pumpAndSettle();

    await tester.tap(find.text('任务类型'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('考试复习'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('复习类型'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('记忆与背诵').last);
    await tester.pumpAndSettle();

    await tapVisible(tester, '生成我的起步卡片');
    expect(find.text('迈出极小的一步'), findsOneWidget);
    expect(find.text('今日微行动'), findsOneWidget);
    expect(find.textContaining('微积分期末复习'), findsWidgets);

    // Reduction steps in Chinese
    expect(find.text('行动拆解：第 1 级 / 共 4 级'), findsOneWidget);
    await tapVisible(tester, '还可以更小一点');
    expect(find.text('行动拆解：第 2 级 / 共 4 级'), findsOneWidget);
    await tapVisible(tester, '还可以更小一点');
    expect(find.text('行动拆解：第 3 级 / 共 4 级'), findsOneWidget);
    await tapVisible(tester, '还可以更小一点');
    expect(find.text('这个最小的行动对今天已经足够了。'), findsWidgets);
    expect(find.text('还可以更小一点'), findsNothing);
  });

  testWidgets(
    'Chinese fatigue severe path routes to rest screen with valid copy',
    (tester) async {
      final database = AppDatabase.memory();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await database.close();
      });
      await tester.pumpWidget(appWithZh(database));
      await tester.pumpAndSettle();

      await tapVisible(tester, '太累了，脑子转不动');
      expect(find.text('普通疲惫'), findsOneWidget);
      expect(find.text('头痛或明显身体不适'), findsOneWidget);

      await tapVisible(tester, '头痛或明显身体不适');
      await tapVisible(tester, '写下任务');

      expect(find.text('休息也是有效的一步'), findsOneWidget);
      expect(find.textContaining('身体明显不适'), findsOneWidget);
      expect(find.text('返回首页'), findsOneWidget);
    },
  );

  testWidgets('Dynamic language toggle switches between English and Chinese', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    // Start with English
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          localeProvider.overrideWith(() => LocaleNotifier('en')),
        ],
        child: const StudyLoopApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('What would you like to tackle today?'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('首页'));
    await tester.pumpAndSettle();

    expect(find.text('今天想解决什么问题？'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('What would you like to tackle today?'), findsOneWidget);
  });
}
