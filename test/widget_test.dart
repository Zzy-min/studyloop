import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/app.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/entitlement_repository.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/providers.dart';

ProviderScope appWith(AppDatabase database, {List extra = const []}) {
  return ProviderScope(
    overrides: [databaseProvider.overrideWithValue(database), ...extra],
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
  testWidgets('task name field can receive focus and text', (tester) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    await tester.pumpWidget(appWith(database));
    await tester.pumpAndSettle();
    await tapVisible(tester, 'There is too much to do');
    await tapVisible(tester, 'Write a task');
    final field = find.byKey(const Key('task-name-field'));
    expect(field, findsOneWidget);
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
    await tester.tap(field);
    await tester.pump();
    await tester.enterText(field, 'Calculus');
    await tester.pumpAndSettle();
    expect(find.text('Calculus'), findsWidgets);
    expect(find.text('Available time'), findsOneWidget);
  });
  testWidgets('fresh launch asks about the current barrier', (tester) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    await tester.pumpWidget(appWith(database));
    await tester.pumpAndSettle();
    expect(find.text('What would you like to tackle today?'), findsOneWidget);
    expect(find.text('Unsure'), findsOneWidget);
    expect(find.text('Busy'), findsOneWidget);
  });

  testWidgets('tiredness follow-up routes ordinary study and severe rest', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    await tester.pumpWidget(appWith(database));
    await tester.pumpAndSettle();
    await tapVisible(tester, 'I am too tired to think clearly');
    expect(find.text('Ordinary tiredness'), findsOneWidget);
    await tapVisible(tester, 'Headache or clear physical discomfort');
    await tapVisible(tester, 'Write a task');
    expect(find.text('Rest is a valid next step'), findsOneWidget);
    expect(find.textContaining('not making a diagnosis'), findsOneWidget);
  });

  testWidgets('task reduction reaches the smallest useful action', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    await tester.pumpWidget(appWith(database));
    await tester.pumpAndSettle();
    await tapVisible(tester, 'There is too much to do');
    await tapVisible(tester, 'Write a task');
    await tester.enterText(find.byType(TextField), 'Calculus');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Task type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exam Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revision type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculation').last);
    await tester.pumpAndSettle();
    await tapVisible(tester, 'Create my start card');
    expect(find.textContaining('Calculus'), findsWidgets);
    await tapVisible(tester, 'Make it smaller');
    await tapVisible(tester, 'Make it smaller');
    await tapVisible(tester, 'Make it smaller');
    expect(
      find.text('This smallest useful action is enough for today.'),
      findsOneWidget,
    );
    expect(find.text('Make it smaller'), findsNothing);
  });

  testWidgets('insights stay empty below three records', (tester) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    await tester.pumpWidget(appWith(database));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    expect(find.textContaining('first honest study record'), findsOneWidget);
  });

  testWidgets('paywall cancellation returns quietly to insights', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    final fake = FakeEntitlementRepository(
      state: EntitlementState.free,
      purchaseResult: const PurchaseCancelled(),
    );
    addTearDown(fake.dispose);
    await tester.pumpWidget(
      appWith(
        database,
        extra: [entitlementRepositoryProvider.overrideWithValue(fake)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    await tapVisible(tester, 'View patterns');
    await tapVisible(tester, 'Unlock long-term pattern comparisons');
    await tapVisible(tester, 'Continue with Pro');
    expect(find.text('My insights'), findsOneWidget);
    expect(find.textContaining('unavailable'), findsNothing);
    expect(find.textContaining('error'), findsNothing);
  });
}
