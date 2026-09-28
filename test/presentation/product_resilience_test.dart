import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/app.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/providers.dart';

void main() {
  testWidgets('core empty states render on a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

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
    expect(find.text('What would you like to tackle today?'), findsOneWidget);
    final homeException = tester.takeException();
    if (homeException != null) debugDumpRenderTree();
    expect(homeException, isNull);

    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your first honest study record will appear here.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Need more study records'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('About StudyLoop'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
