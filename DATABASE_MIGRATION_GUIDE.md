# StudyLoop Database Migration Guide

## 1. Current Schema Status

- **Current `schemaVersion`**: `2`
- **Database Engine**: SQLite via Drift (`drift: ^2.24.2`, `drift_dev: ^2.24.2`)
- **Default Database Path**: `studyloop.sqlite` in Application Documents Directory (`getApplicationDocumentsDirectory()`)

---

## 2. Version History

| Version | Released In | Changes | Migration Logic |
| :--- | :--- | :--- | :--- |
| **V1** | Initial MVP / Beta | Initial schema containing `study_records` (with NOT NULL `difficulty`, `focus`, `mood_change`) and `active_timers` singleton table. | Initial database creation via `createAll()`. |
| **V2** | Release Candidate | Made `difficulty`, `focus`, and `mood_change` nullable in `study_records` to strictly distinguish "Skipped Reflection / Unrated" from user rating choices (1-5). | Table rebuild preserving 100% of existing rows and column values. |

---

## 3. Upgrade Architecture & Implementation

### SQLite Column Nullability Constraint Migration

SQLite does not support altering column constraints directly via `ALTER TABLE ... ALTER COLUMN`. Therefore, the canonical, fail-safe migration rebuilds the table:

```dart
// lib/data/database/app_database.dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
  },
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      // 1. Create temporary v2 table with nullable ratings
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

      // 2. Copy all legacy records into v2 table
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

      // 3. Drop legacy table and rename v2 table
      await customStatement('DROP TABLE study_records;');
      await customStatement('ALTER TABLE study_records_v2 RENAME TO study_records;');
    }
  },
);
```

---

## 4. Prohibited Database Operations

1. **NEVER drop tables without migrating**: Do not use `database.delete()` or drop existing tables in production `onUpgrade`.
2. **NEVER insert fake values instead of `NULL`**: If a user skips a prompt, write `null`, not `0`, `-1`, or `3`.
3. **NEVER assume `user_version` increments automatically**: Every schema change must increment `schemaVersion` by 1 and provide an explicit `if (from < N)` block.
4. **NEVER ship without running migration tests**: Every upgrade branch must have an automated test asserting legacy records survive untouched.

---

## 5. Automated Verification & Testing

Migration tests are maintained in [`test/data/app_database_migration_test.dart`](file:///C:/Users/Lenovo/Documents/Codex/2026-08-08/revenuecat-shipaton-2026-2026-10-01/test/data/app_database_migration_test.dart).

To run migration verification:
```powershell
flutter test test/data/app_database_migration_test.dart
```

Key test cases verified:
1. **Fresh Install Test**: Schema V2 installs cleanly from empty state; inserts records with null ratings.
2. **V1 -> V2 Migration Test**: Raw V1 schema with pre-populated records is upgraded to V2; asserts 100% of historical records and their ratings are preserved intact, and new null-rating records can be written.

---

## 6. Pre-Release Migration Checklist

- [x] Drift `schemaVersion` matches latest specification (`2`).
- [x] Drift generated code re-compiled with `build_runner`.
- [x] All migration unit tests pass with zero errors.
- [x] Full test suite passes (`flutter test`).
- [x] Static analyzer clean (`flutter analyze`).
- [x] Verified on real device without cold-boot migration crashes.
