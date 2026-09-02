import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';
import 'package:studyloop/data/database/app_database.dart';
import 'package:studyloop/domain/models.dart';

void main() {
  group('Drift Schema Migration & Nullable Reflection Tests', () {
    test(
      'Fresh install initializes Schema V2 and supports null reflection ratings',
      () async {
        final db = AppDatabase.memory();
        addTearDown(db.close);

        expect(db.schemaVersion, equals(2));

        // Insert record where reflection was skipped (difficulty, focus, moodChange are null)
        final skippedRecord = StudyRecord(
          id: 'test-skipped-1',
          startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
          endedAt: DateTime.now(),
          startDate: DateTime.now(),
          barrier: StudyBarrier.uncertainStart,
          taskText: 'Study Operating Systems',
          taskType: TaskType.programmingPractice,
          plannedSeconds: 900,
          actualSeconds: 900,
          outcome: SessionOutcome.completed,
          difficulty: null,
          focus: null,
          moodChange: null,
          nextAction: '',
          synthetic: false,
        );

        await db.saveRecord(skippedRecord);
        final records = await db.allRecords();

        expect(records.length, equals(1));
        final loaded = records.first;
        expect(loaded.id, equals('test-skipped-1'));
        expect(loaded.difficulty, isNull);
        expect(loaded.focus, isNull);
        expect(loaded.moodChange, isNull);
      },
    );

    test(
      'Migration from V1 to V2 preserves all existing records and ratings',
      () async {
        // Create raw in-memory SQLite database simulating V1 schema with NOT NULL columns
        final rawDb = sqlite3.openInMemory();

        // Setup V1 tables directly
        rawDb.execute('''
        CREATE TABLE study_records (
          id TEXT NOT NULL PRIMARY KEY,
          started_at INTEGER NOT NULL,
          ended_at INTEGER NOT NULL,
          start_date INTEGER NOT NULL,
          barrier TEXT NOT NULL,
          task_text TEXT NOT NULL,
          task_type TEXT NOT NULL,
          exam_subtype TEXT,
          planned_seconds INTEGER NOT NULL,
          actual_seconds INTEGER NOT NULL,
          outcome TEXT NOT NULL,
          difficulty INTEGER NOT NULL,
          focus INTEGER NOT NULL,
          mood_change TEXT NOT NULL,
          next_action TEXT NOT NULL DEFAULT '',
          synthetic INTEGER NOT NULL DEFAULT 0
        );
      ''');

        rawDb.execute('''
        CREATE TABLE active_timers (
          singleton INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
          draft_json TEXT NOT NULL,
          accumulated_seconds INTEGER NOT NULL,
          remaining_seconds INTEGER NOT NULL,
          started_at INTEGER NOT NULL,
          last_saved_at INTEGER NOT NULL
        );
      ''');

        // Seed 2 legacy V1 records
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        rawDb.execute('''
        INSERT INTO study_records (
          id, started_at, ended_at, start_date, barrier, task_text, task_type,
          planned_seconds, actual_seconds, outcome, difficulty, focus, mood_change, next_action, synthetic
        ) VALUES (
          'v1-record-1', $nowMs, $nowMs, $nowMs, 'overload', 'Legacy Task 1', 'examRevision',
          1800, 1800, 'completed', 4, 5, 'moreAtEase', 'Review Chapter 2', 0
        );
      ''');

        rawDb.execute('''
        INSERT INTO study_records (
          id, started_at, ended_at, start_date, barrier, task_text, task_type,
          planned_seconds, actual_seconds, outcome, difficulty, focus, mood_change, next_action, synthetic
        ) VALUES (
          'v1-record-2', $nowMs, $nowMs, $nowMs, 'phoneDistraction', 'Legacy Task 2', 'programmingPractice',
          900, 850, 'interrupted', 3, 2, 'worse', '', 0
        );
      ''');

        // Set user_version to 1
        rawDb.execute('PRAGMA user_version = 1;');

        // Now open through AppDatabase, which triggers onUpgrade from 1 to 2
        final migratedDb = AppDatabase(NativeDatabase.opened(rawDb));
        addTearDown(migratedDb.close);

        final recordsAfterMigration = await migratedDb.allRecords();
        expect(recordsAfterMigration.length, equals(2));

        final rec1 = recordsAfterMigration.firstWhere(
          (r) => r.id == 'v1-record-1',
        );
        expect(rec1.taskText, equals('Legacy Task 1'));
        expect(rec1.difficulty, equals(4));
        expect(rec1.focus, equals(5));
        expect(rec1.moodChange, equals(MoodChange.moreAtEase));
        expect(rec1.nextAction, equals('Review Chapter 2'));

        final rec2 = recordsAfterMigration.firstWhere(
          (r) => r.id == 'v1-record-2',
        );
        expect(rec2.taskText, equals('Legacy Task 2'));
        expect(rec2.difficulty, equals(3));
        expect(rec2.focus, equals(2));
        expect(rec2.moodChange, equals(MoodChange.worse));

        // Now verify we can insert a new record with NULL reflection ratings into the migrated database
        final newRecord = StudyRecord(
          id: 'v2-new-skipped',
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          startDate: DateTime.now(),
          barrier: StudyBarrier.perfectionism,
          taskText: 'Post-migration Task',
          taskType: TaskType.paperWriting,
          plannedSeconds: 1200,
          actualSeconds: 1200,
          outcome: SessionOutcome.completed,
          difficulty: null,
          focus: null,
          moodChange: null,
        );

        await migratedDb.saveRecord(newRecord);

        final allUpdated = await migratedDb.allRecords();
        expect(allUpdated.length, equals(3));
        final loadedNew = allUpdated.firstWhere(
          (r) => r.id == 'v2-new-skipped',
        );
        expect(loadedNew.difficulty, isNull);
        expect(loadedNew.focus, isNull);
        expect(loadedNew.moodChange, isNull);
      },
    );
  });
}
