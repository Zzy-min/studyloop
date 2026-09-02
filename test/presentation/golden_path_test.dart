import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/app.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/providers.dart';

ProviderScope appWith(AppDatabase database, {DateTime Function()? clock}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(database),
      if (clock != null) clockProvider.overrideWithValue(clock),
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
  testWidgets('golden path saves actual focused time into history', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    var now = DateTime(2026, 9, 1, 10, 0, 0);

    await tester.pumpWidget(appWith(database, clock: () => now));
    await tester.pumpAndSettle();

    await tapVisible(tester, 'There is too much to do');
    await tapVisible(tester, 'Write a task');
    await tester.enterText(
      find.byKey(const Key('task-name-field')),
      'Calculus',
    );
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
    await tapVisible(tester, 'Start focusing');

    expect(find.text('Focusing'), findsWidgets);
    expect(find.text('Only foreground time counted'), findsOneWidget);

    now = now.add(const Duration(seconds: 5));
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);

    now = now.add(const Duration(seconds: 20));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    now = now.add(const Duration(seconds: 5));
    await tapVisible(tester, 'End & Save');
    await tapVisible(tester, 'Save focused time');

    expect(find.text('How did that feel?'), findsOneWidget);
    await tapVisible(tester, 'Skip reflection and save this session');

    expect(find.text('A real start'), findsOneWidget);
    await tapVisible(tester, 'See history');
    expect(find.text('Calculus'), findsWidgets);
    expect(find.textContaining('Ended early'), findsOneWidget);

    final records = await database.allRecords();
    expect(records, hasLength(1));
    expect(records.single.taskText, 'Calculus');
    expect(records.single.actualSeconds, 10);
    expect(records.single.plannedSeconds, 900);
  });
}
