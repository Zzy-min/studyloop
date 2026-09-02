import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/app.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/providers.dart';

void main() {
  testWidgets('bottom tabs switch without stacking back history', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const StudyLoopApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Why can’t you study right now?'), findsOneWidget);

    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    expect(find.textContaining('first honest study record'), findsOneWidget);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your patterns'), findsWidgets);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Why can’t you study right now?'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Why can’t you study right now?'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
