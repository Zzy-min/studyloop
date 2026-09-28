import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:studyloop/app.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/providers.dart';

void main() {
  const captureDir = String.fromEnvironment('UI_CAPTURE_DIR');
  const fontPath = String.fromEnvironment('UI_FONT');

  Future<void> capture(WidgetTester tester, String name) async {
    if (captureDir.isEmpty) {
      expect(tester.takeException(), isNull);
      return;
    }
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('reference-capture')),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(captureDir).create(recursive: true);
      await File(
        '$captureDir/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    expect(tester.takeException(), isNull);
  }

  for (final width in [390.0, 320.0]) {
    testWidgets('reference screens and focus controls work at width $width', (
      tester,
    ) async {
      tester.view.reset();
      final previousShadows = debugDisableShadows;
      if (captureDir.isNotEmpty) debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = previousShadows);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 390 ? 844 : 640);
      addTearDown(tester.view.reset);
      if (fontPath.isNotEmpty) {
        await tester.runAsync(() async {
          final bytes = ByteData.sublistView(
            await File(fontPath).readAsBytes(),
          );
          for (final family in ['Ahem', 'Roboto', 'Microsoft YaHei']) {
            await (FontLoader(family)..addFont(Future.value(bytes))).load();
          }
          final emoji = File('${File(fontPath).parent.path}/seguiemj.ttf');
          if (await emoji.exists()) {
            await (FontLoader(
              'Segoe UI Emoji',
            )..addFont(emoji.readAsBytes().then(ByteData.sublistView))).load();
          }
        });
      }
      if (captureDir.isNotEmpty) {
        await tester.runAsync(() async {
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
        });
      }
      final db = AppDatabase.memory();
      final now = DateTime(2026, 9, 22, 10);
      // In-memory fixtures only: never seed or replace a user's study history.
      await tester.runAsync(() async {
        for (var i = 0; i < 18; i++) {
          final start = now.subtract(Duration(days: i));
          await db.saveRecord(
            StudyRecord(
              id: 'ui-fixture-$i',
              startedAt: start,
              endedAt: start.add(Duration(minutes: 25 + i)),
              startDate: DateTime(start.year, start.month, start.day),
              barrier: StudyBarrier.uncertainStart,
              taskText: '复习线性代数：向量空间的定义',
              taskType: TaskType.values[i % TaskType.values.length],
              plannedSeconds: 3600,
              actualSeconds: (25 + i) * 60,
              outcome: SessionOutcome.completed,
              difficulty: 3,
              focus: 4,
            ),
          );
        }
      });
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          localeProvider.overrideWith(() => LocaleNotifier('zh')),
        ],
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await db.close();
      });
      final session = container.read(sessionProvider.notifier);
      session.chooseBarrier(StudyBarrier.uncertainStart);
      session.setTask('复习线性代数：向量空间的定义');
      session.chooseType(TaskType.examRevision);
      session.chooseSubtype(ExamSubtype.calculation);
      session.chooseDuration(1500);
      expect(session.generateCard(), isTrue);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RepaintBoundary(
            key: Key('reference-capture'),
            child: StudyLoopApp(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final router = GoRouter.of(tester.element(find.byType(EntryScreen)));
      await tester.runAsync(() async {
        final context = tester.element(find.byType(EntryScreen));
        for (final asset in ['corgi_welcome', 'corgi_focus', 'corgi_resting']) {
          await precacheImage(AssetImage('assets/images/$asset.png'), context);
        }
      });
      router.go('/welcome');
      await tester.pumpAndSettle();
      await capture(tester, 'welcome-${width.toInt()}');
      router.go('/');
      await tester.pumpAndSettle();
      await capture(tester, 'home-${width.toInt()}');
      final strings = container.read(stringsProvider);
      await tester.ensureVisible(find.text(strings.startFocusCTA));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.startFocusCTA));
      await tester.pumpAndSettle();
      expect(find.byType(FocusScreen), findsOneWidget);
      await capture(tester, 'focus-${width.toInt()}');
      await tester.tap(find.text(strings.pause));
      await tester.pumpAndSettle();
      expect(find.text(strings.resume), findsOneWidget);
      await tester.tap(find.text(strings.resume));
      await tester.pumpAndSettle();
      expect(find.text(strings.pause), findsOneWidget);
      await tester.tap(find.text(strings.pause));
      await tester.pumpAndSettle();
      router.go('/insights');
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 150)),
      );
      await tester.pumpAndSettle();
      expect(find.text(strings.focusDuration), findsOneWidget);
      await capture(tester, 'insights-${width.toInt()}');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      debugDisableShadows = previousShadows;
    });
  }
}
