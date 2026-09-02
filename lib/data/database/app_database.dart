import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/models.dart';

part 'app_database.g.dart';

@DataClassName('StudyRecordRow')
class StudyRecords extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get barrier => text()();
  TextColumn get taskText => text()();
  TextColumn get taskType => text()();
  TextColumn get examSubtype => text().nullable()();
  IntColumn get plannedSeconds => integer()();
  IntColumn get actualSeconds => integer()();
  TextColumn get outcome => text()();
  IntColumn get difficulty => integer().nullable()();
  IntColumn get focus => integer().nullable()();
  TextColumn get moodChange => text().nullable()();
  TextColumn get nextAction => text().withDefault(const Constant(''))();
  BoolColumn get synthetic => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ActiveTimers extends Table {
  IntColumn get singleton => integer().withDefault(const Constant(1))();
  TextColumn get draftJson => text()();
  IntColumn get accumulatedSeconds => integer()();
  IntColumn get remainingSeconds => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get lastSavedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {singleton};
}

@DriftDatabase(tables: [StudyRecords, ActiveTimers])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.open() => AppDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(
        File(p.join(dir.path, 'studyloop.sqlite')),
      );
    }),
  );

  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await customStatement('''
              CREATE TABLE study_records_v2 (
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
                difficulty INTEGER,
                focus INTEGER,
                mood_change TEXT,
                next_action TEXT NOT NULL DEFAULT '',
                synthetic INTEGER NOT NULL DEFAULT 0
              );
            ''');
        await customStatement('''
              INSERT INTO study_records_v2 (
                id, started_at, ended_at, start_date, barrier, task_text, task_type,
                exam_subtype, planned_seconds, actual_seconds, outcome, difficulty,
                focus, mood_change, next_action, synthetic
              )
              SELECT
                id, started_at, ended_at, start_date, barrier, task_text, task_type,
                exam_subtype, planned_seconds, actual_seconds, outcome, difficulty,
                focus, mood_change, next_action, synthetic
              FROM study_records;
            ''');
        await customStatement('DROP TABLE study_records;');
        await customStatement(
          'ALTER TABLE study_records_v2 RENAME TO study_records;',
        );
      }
    },
  );

  Stream<List<StudyRecord>> watchRecords() =>
      (select(studyRecords)..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .watch()
          .map((rows) => rows.map(_rowToDomain).toList());

  Future<List<StudyRecord>> allRecords() async =>
      (await (select(
            studyRecords,
          )..orderBy([(t) => OrderingTerm.desc(t.startedAt)])).get())
          .map(_rowToDomain)
          .toList();

  Future<void> saveRecord(StudyRecord record) =>
      into(studyRecords).insertOnConflictUpdate(
        StudyRecordsCompanion.insert(
          id: record.id,
          startedAt: record.startedAt,
          endedAt: record.endedAt,
          startDate: record.startDate,
          barrier: record.barrier.name,
          taskText: record.taskText,
          taskType: record.taskType.name,
          examSubtype: Value(record.examSubtype?.name),
          plannedSeconds: record.plannedSeconds,
          actualSeconds: record.actualSeconds,
          outcome: record.outcome.name,
          difficulty: Value(record.difficulty),
          focus: Value(record.focus),
          moodChange: Value(record.moodChange?.name),
          nextAction: Value(record.nextAction),
          synthetic: Value(record.synthetic),
        ),
      );

  Future<void> deleteRecord(String id) =>
      (delete(studyRecords)..where((table) => table.id.equals(id))).go();

  Future<void> clearSynthetic() => (delete(
    studyRecords,
  )..where((table) => table.synthetic.equals(true))).go();

  Future<void> saveSnapshot(ActiveTimerSnapshot snapshot) =>
      into(activeTimers).insertOnConflictUpdate(
        ActiveTimersCompanion.insert(
          singleton: const Value(1),
          draftJson: jsonEncode(_draftToJson(snapshot.draft)),
          accumulatedSeconds: snapshot.accumulatedSeconds,
          remainingSeconds: snapshot.remainingSeconds,
          startedAt: snapshot.startedAt,
          lastSavedAt: snapshot.lastSavedAt,
        ),
      );

  Future<ActiveTimerSnapshot?> readSnapshot() async {
    final row = await select(activeTimers).getSingleOrNull();
    if (row == null) return null;
    return ActiveTimerSnapshot(
      draft: _draftFromJson(jsonDecode(row.draftJson) as Map<String, dynamic>),
      accumulatedSeconds: row.accumulatedSeconds,
      remainingSeconds: row.remainingSeconds,
      startedAt: row.startedAt,
      lastSavedAt: row.lastSavedAt,
    );
  }

  Future<void> clearSnapshot() => delete(activeTimers).go();

  Future<void> commit(StudyRecord record) => transaction(() async {
    await saveRecord(record);
    await clearSnapshot();
  });
}

StudyRecord _rowToDomain(StudyRecordRow row) => StudyRecord(
  id: row.id,
  startedAt: row.startedAt,
  endedAt: row.endedAt,
  startDate: row.startDate,
  barrier: StudyBarrier.values.byName(row.barrier),
  taskText: row.taskText,
  taskType: parseTaskType(row.taskType),
  examSubtype: row.examSubtype == null
      ? null
      : ExamSubtype.values.byName(row.examSubtype!),
  plannedSeconds: row.plannedSeconds,
  actualSeconds: row.actualSeconds,
  outcome: SessionOutcome.values.byName(row.outcome),
  difficulty: row.difficulty,
  focus: row.focus,
  moodChange: row.moodChange == null
      ? null
      : MoodChange.values.byName(row.moodChange!),
  nextAction: row.nextAction,
  synthetic: row.synthetic,
);

Map<String, Object?> _draftToJson(SessionDraft draft) => {
  'version': 1,
  'barrier': draft.barrier?.name,
  'fatigueSeverity': draft.fatigueSeverity?.name,
  'taskText': draft.taskText,
  'taskType': draft.taskType?.name,
  'examSubtype': draft.examSubtype?.name,
  'plannedSeconds': draft.plannedSeconds,
  'reductionLevel': draft.reductionLevel,
  'cardAction': draft.card?.action,
  'cardRationale': draft.card?.rationale,
};

SessionDraft _draftFromJson(Map<String, dynamic> json) => SessionDraft(
  barrier: json['barrier'] == null
      ? null
      : StudyBarrier.values.byName(json['barrier'] as String),
  fatigueSeverity: json['fatigueSeverity'] == null
      ? null
      : FatigueSeverity.values.byName(json['fatigueSeverity'] as String),
  taskText: json['taskText'] as String? ?? '',
  taskType: json['taskType'] == null
      ? null
      : parseTaskType(json['taskType'] as String),
  examSubtype: json['examSubtype'] == null
      ? null
      : ExamSubtype.values.byName(json['examSubtype'] as String),
  plannedSeconds: json['plannedSeconds'] as int? ?? 900,
  reductionLevel: json['reductionLevel'] as int? ?? 0,
  card: json['cardAction'] == null
      ? null
      : StartCard(
          action: json['cardAction'] as String,
          rationale: json['cardRationale'] as String? ?? '',
        ),
);
