import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/models.dart';
import 'package:studyloop/presentation/screens/history_detail_screen.dart';
import 'package:studyloop/providers.dart';

void main() {
  testWidgets('long Chinese task title does not overflow record details', (
    tester,
  ) async {
    final database = AppDatabase.memory();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await database.close();
    });

    final now = DateTime(2026, 9, 2, 22, 0);
    await database.saveRecord(
      StudyRecord(
        id: 'long-title',
        startedAt: now,
        endedAt: now.add(const Duration(seconds: 13)),
        startDate: DateTime(2026, 9, 2),
        barrier: StudyBarrier.uncertainStart,
        taskText: '先快速浏览或写下【打开学习任务】相关文件，只读第一小节',
        taskType: TaskType.homework,
        plannedSeconds: 600,
        actualSeconds: 13,
        outcome: SessionOutcome.interrupted,
        difficulty: 3,
        focus: 3,
        moodChange: MoodChange.unchanged,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          localeProvider.overrideWith(() => LocaleNotifier('zh')),
        ],
        child: const MaterialApp(
          home: Scaffold(body: HistoryDetailScreen(id: 'long-title')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('先快速浏览或写下'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
