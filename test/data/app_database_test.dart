import 'package:flutter_test/flutter_test.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  test('record insert, delete, and active timer singleton work', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final now = DateTime(2026, 8, 14, 23, 58);
    final record = StudyRecord(
      id: 'one',
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 5)),
      startDate: DateTime(2026, 8, 14),
      barrier: StudyBarrier.overload,
      taskText: 'Exam',
      taskType: TaskType.examRevision,
      examSubtype: ExamSubtype.calculation,
      plannedSeconds: 300,
      actualSeconds: 240,
      outcome: SessionOutcome.interrupted,
      difficulty: 4,
      focus: 3,
      moodChange: MoodChange.unchanged,
    );
    await db.saveRecord(record);
    expect((await db.allRecords()).single.startDate, DateTime(2026, 8, 14));
    final draft = SessionDraft(
      barrier: StudyBarrier.overload,
      taskText: 'Exam',
      taskType: TaskType.examRevision,
      examSubtype: ExamSubtype.calculation,
      plannedSeconds: 300,
    );
    await db.saveSnapshot(
      ActiveTimerSnapshot(
        draft: draft,
        accumulatedSeconds: 2,
        remainingSeconds: 298,
        startedAt: now,
        lastSavedAt: now,
      ),
    );
    await db.saveSnapshot(
      ActiveTimerSnapshot(
        draft: draft,
        accumulatedSeconds: 3,
        remainingSeconds: 297,
        startedAt: now,
        lastSavedAt: now,
      ),
    );
    expect((await db.readSnapshot())!.accumulatedSeconds, 3);
    await db.deleteRecord('one');
    expect(await db.allRecords(), isEmpty);
  });
}
