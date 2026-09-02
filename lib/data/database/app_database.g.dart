// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StudyRecordsTable extends StudyRecords
    with TableInfo<$StudyRecordsTable, StudyRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barrierMeta = const VerificationMeta(
    'barrier',
  );
  @override
  late final GeneratedColumn<String> barrier = GeneratedColumn<String>(
    'barrier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTextMeta = const VerificationMeta(
    'taskText',
  );
  @override
  late final GeneratedColumn<String> taskText = GeneratedColumn<String>(
    'task_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTypeMeta = const VerificationMeta(
    'taskType',
  );
  @override
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
    'task_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examSubtypeMeta = const VerificationMeta(
    'examSubtype',
  );
  @override
  late final GeneratedColumn<String> examSubtype = GeneratedColumn<String>(
    'exam_subtype',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedSecondsMeta = const VerificationMeta(
    'plannedSeconds',
  );
  @override
  late final GeneratedColumn<int> plannedSeconds = GeneratedColumn<int>(
    'planned_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualSecondsMeta = const VerificationMeta(
    'actualSeconds',
  );
  @override
  late final GeneratedColumn<int> actualSeconds = GeneratedColumn<int>(
    'actual_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<int> focus = GeneratedColumn<int>(
    'focus',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moodChangeMeta = const VerificationMeta(
    'moodChange',
  );
  @override
  late final GeneratedColumn<String> moodChange = GeneratedColumn<String>(
    'mood_change',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextActionMeta = const VerificationMeta(
    'nextAction',
  );
  @override
  late final GeneratedColumn<String> nextAction = GeneratedColumn<String>(
    'next_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syntheticMeta = const VerificationMeta(
    'synthetic',
  );
  @override
  late final GeneratedColumn<bool> synthetic = GeneratedColumn<bool>(
    'synthetic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synthetic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    startDate,
    barrier,
    taskText,
    taskType,
    examSubtype,
    plannedSeconds,
    actualSeconds,
    outcome,
    difficulty,
    focus,
    moodChange,
    nextAction,
    synthetic,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('barrier')) {
      context.handle(
        _barrierMeta,
        barrier.isAcceptableOrUnknown(data['barrier']!, _barrierMeta),
      );
    } else if (isInserting) {
      context.missing(_barrierMeta);
    }
    if (data.containsKey('task_text')) {
      context.handle(
        _taskTextMeta,
        taskText.isAcceptableOrUnknown(data['task_text']!, _taskTextMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTextMeta);
    }
    if (data.containsKey('task_type')) {
      context.handle(
        _taskTypeMeta,
        taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTypeMeta);
    }
    if (data.containsKey('exam_subtype')) {
      context.handle(
        _examSubtypeMeta,
        examSubtype.isAcceptableOrUnknown(
          data['exam_subtype']!,
          _examSubtypeMeta,
        ),
      );
    }
    if (data.containsKey('planned_seconds')) {
      context.handle(
        _plannedSecondsMeta,
        plannedSeconds.isAcceptableOrUnknown(
          data['planned_seconds']!,
          _plannedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedSecondsMeta);
    }
    if (data.containsKey('actual_seconds')) {
      context.handle(
        _actualSecondsMeta,
        actualSeconds.isAcceptableOrUnknown(
          data['actual_seconds']!,
          _actualSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualSecondsMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    }
    if (data.containsKey('mood_change')) {
      context.handle(
        _moodChangeMeta,
        moodChange.isAcceptableOrUnknown(data['mood_change']!, _moodChangeMeta),
      );
    }
    if (data.containsKey('next_action')) {
      context.handle(
        _nextActionMeta,
        nextAction.isAcceptableOrUnknown(data['next_action']!, _nextActionMeta),
      );
    }
    if (data.containsKey('synthetic')) {
      context.handle(
        _syntheticMeta,
        synthetic.isAcceptableOrUnknown(data['synthetic']!, _syntheticMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      barrier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barrier'],
      )!,
      taskText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_text'],
      )!,
      taskType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_type'],
      )!,
      examSubtype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_subtype'],
      ),
      plannedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_seconds'],
      )!,
      actualSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_seconds'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      ),
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus'],
      ),
      moodChange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood_change'],
      ),
      nextAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_action'],
      )!,
      synthetic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synthetic'],
      )!,
    );
  }

  @override
  $StudyRecordsTable createAlias(String alias) {
    return $StudyRecordsTable(attachedDatabase, alias);
  }
}

class StudyRecordRow extends DataClass implements Insertable<StudyRecordRow> {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final DateTime startDate;
  final String barrier;
  final String taskText;
  final String taskType;
  final String? examSubtype;
  final int plannedSeconds;
  final int actualSeconds;
  final String outcome;
  final int? difficulty;
  final int? focus;
  final String? moodChange;
  final String nextAction;
  final bool synthetic;
  const StudyRecordRow({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.startDate,
    required this.barrier,
    required this.taskText,
    required this.taskType,
    this.examSubtype,
    required this.plannedSeconds,
    required this.actualSeconds,
    required this.outcome,
    this.difficulty,
    this.focus,
    this.moodChange,
    required this.nextAction,
    required this.synthetic,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['start_date'] = Variable<DateTime>(startDate);
    map['barrier'] = Variable<String>(barrier);
    map['task_text'] = Variable<String>(taskText);
    map['task_type'] = Variable<String>(taskType);
    if (!nullToAbsent || examSubtype != null) {
      map['exam_subtype'] = Variable<String>(examSubtype);
    }
    map['planned_seconds'] = Variable<int>(plannedSeconds);
    map['actual_seconds'] = Variable<int>(actualSeconds);
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<int>(difficulty);
    }
    if (!nullToAbsent || focus != null) {
      map['focus'] = Variable<int>(focus);
    }
    if (!nullToAbsent || moodChange != null) {
      map['mood_change'] = Variable<String>(moodChange);
    }
    map['next_action'] = Variable<String>(nextAction);
    map['synthetic'] = Variable<bool>(synthetic);
    return map;
  }

  StudyRecordsCompanion toCompanion(bool nullToAbsent) {
    return StudyRecordsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      startDate: Value(startDate),
      barrier: Value(barrier),
      taskText: Value(taskText),
      taskType: Value(taskType),
      examSubtype: examSubtype == null && nullToAbsent
          ? const Value.absent()
          : Value(examSubtype),
      plannedSeconds: Value(plannedSeconds),
      actualSeconds: Value(actualSeconds),
      outcome: Value(outcome),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      focus: focus == null && nullToAbsent
          ? const Value.absent()
          : Value(focus),
      moodChange: moodChange == null && nullToAbsent
          ? const Value.absent()
          : Value(moodChange),
      nextAction: Value(nextAction),
      synthetic: Value(synthetic),
    );
  }

  factory StudyRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyRecordRow(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      barrier: serializer.fromJson<String>(json['barrier']),
      taskText: serializer.fromJson<String>(json['taskText']),
      taskType: serializer.fromJson<String>(json['taskType']),
      examSubtype: serializer.fromJson<String?>(json['examSubtype']),
      plannedSeconds: serializer.fromJson<int>(json['plannedSeconds']),
      actualSeconds: serializer.fromJson<int>(json['actualSeconds']),
      outcome: serializer.fromJson<String>(json['outcome']),
      difficulty: serializer.fromJson<int?>(json['difficulty']),
      focus: serializer.fromJson<int?>(json['focus']),
      moodChange: serializer.fromJson<String?>(json['moodChange']),
      nextAction: serializer.fromJson<String>(json['nextAction']),
      synthetic: serializer.fromJson<bool>(json['synthetic']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'startDate': serializer.toJson<DateTime>(startDate),
      'barrier': serializer.toJson<String>(barrier),
      'taskText': serializer.toJson<String>(taskText),
      'taskType': serializer.toJson<String>(taskType),
      'examSubtype': serializer.toJson<String?>(examSubtype),
      'plannedSeconds': serializer.toJson<int>(plannedSeconds),
      'actualSeconds': serializer.toJson<int>(actualSeconds),
      'outcome': serializer.toJson<String>(outcome),
      'difficulty': serializer.toJson<int?>(difficulty),
      'focus': serializer.toJson<int?>(focus),
      'moodChange': serializer.toJson<String?>(moodChange),
      'nextAction': serializer.toJson<String>(nextAction),
      'synthetic': serializer.toJson<bool>(synthetic),
    };
  }

  StudyRecordRow copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? startDate,
    String? barrier,
    String? taskText,
    String? taskType,
    Value<String?> examSubtype = const Value.absent(),
    int? plannedSeconds,
    int? actualSeconds,
    String? outcome,
    Value<int?> difficulty = const Value.absent(),
    Value<int?> focus = const Value.absent(),
    Value<String?> moodChange = const Value.absent(),
    String? nextAction,
    bool? synthetic,
  }) => StudyRecordRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    startDate: startDate ?? this.startDate,
    barrier: barrier ?? this.barrier,
    taskText: taskText ?? this.taskText,
    taskType: taskType ?? this.taskType,
    examSubtype: examSubtype.present ? examSubtype.value : this.examSubtype,
    plannedSeconds: plannedSeconds ?? this.plannedSeconds,
    actualSeconds: actualSeconds ?? this.actualSeconds,
    outcome: outcome ?? this.outcome,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    focus: focus.present ? focus.value : this.focus,
    moodChange: moodChange.present ? moodChange.value : this.moodChange,
    nextAction: nextAction ?? this.nextAction,
    synthetic: synthetic ?? this.synthetic,
  );
  StudyRecordRow copyWithCompanion(StudyRecordsCompanion data) {
    return StudyRecordRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      barrier: data.barrier.present ? data.barrier.value : this.barrier,
      taskText: data.taskText.present ? data.taskText.value : this.taskText,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      examSubtype: data.examSubtype.present
          ? data.examSubtype.value
          : this.examSubtype,
      plannedSeconds: data.plannedSeconds.present
          ? data.plannedSeconds.value
          : this.plannedSeconds,
      actualSeconds: data.actualSeconds.present
          ? data.actualSeconds.value
          : this.actualSeconds,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      focus: data.focus.present ? data.focus.value : this.focus,
      moodChange: data.moodChange.present
          ? data.moodChange.value
          : this.moodChange,
      nextAction: data.nextAction.present
          ? data.nextAction.value
          : this.nextAction,
      synthetic: data.synthetic.present ? data.synthetic.value : this.synthetic,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyRecordRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startDate: $startDate, ')
          ..write('barrier: $barrier, ')
          ..write('taskText: $taskText, ')
          ..write('taskType: $taskType, ')
          ..write('examSubtype: $examSubtype, ')
          ..write('plannedSeconds: $plannedSeconds, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('outcome: $outcome, ')
          ..write('difficulty: $difficulty, ')
          ..write('focus: $focus, ')
          ..write('moodChange: $moodChange, ')
          ..write('nextAction: $nextAction, ')
          ..write('synthetic: $synthetic')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    startDate,
    barrier,
    taskText,
    taskType,
    examSubtype,
    plannedSeconds,
    actualSeconds,
    outcome,
    difficulty,
    focus,
    moodChange,
    nextAction,
    synthetic,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyRecordRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.startDate == this.startDate &&
          other.barrier == this.barrier &&
          other.taskText == this.taskText &&
          other.taskType == this.taskType &&
          other.examSubtype == this.examSubtype &&
          other.plannedSeconds == this.plannedSeconds &&
          other.actualSeconds == this.actualSeconds &&
          other.outcome == this.outcome &&
          other.difficulty == this.difficulty &&
          other.focus == this.focus &&
          other.moodChange == this.moodChange &&
          other.nextAction == this.nextAction &&
          other.synthetic == this.synthetic);
}

class StudyRecordsCompanion extends UpdateCompanion<StudyRecordRow> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<DateTime> startDate;
  final Value<String> barrier;
  final Value<String> taskText;
  final Value<String> taskType;
  final Value<String?> examSubtype;
  final Value<int> plannedSeconds;
  final Value<int> actualSeconds;
  final Value<String> outcome;
  final Value<int?> difficulty;
  final Value<int?> focus;
  final Value<String?> moodChange;
  final Value<String> nextAction;
  final Value<bool> synthetic;
  final Value<int> rowid;
  const StudyRecordsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.startDate = const Value.absent(),
    this.barrier = const Value.absent(),
    this.taskText = const Value.absent(),
    this.taskType = const Value.absent(),
    this.examSubtype = const Value.absent(),
    this.plannedSeconds = const Value.absent(),
    this.actualSeconds = const Value.absent(),
    this.outcome = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.focus = const Value.absent(),
    this.moodChange = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.synthetic = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyRecordsCompanion.insert({
    required String id,
    required DateTime startedAt,
    required DateTime endedAt,
    required DateTime startDate,
    required String barrier,
    required String taskText,
    required String taskType,
    this.examSubtype = const Value.absent(),
    required int plannedSeconds,
    required int actualSeconds,
    required String outcome,
    this.difficulty = const Value.absent(),
    this.focus = const Value.absent(),
    this.moodChange = const Value.absent(),
    this.nextAction = const Value.absent(),
    this.synthetic = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       startDate = Value(startDate),
       barrier = Value(barrier),
       taskText = Value(taskText),
       taskType = Value(taskType),
       plannedSeconds = Value(plannedSeconds),
       actualSeconds = Value(actualSeconds),
       outcome = Value(outcome);
  static Insertable<StudyRecordRow> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<DateTime>? startDate,
    Expression<String>? barrier,
    Expression<String>? taskText,
    Expression<String>? taskType,
    Expression<String>? examSubtype,
    Expression<int>? plannedSeconds,
    Expression<int>? actualSeconds,
    Expression<String>? outcome,
    Expression<int>? difficulty,
    Expression<int>? focus,
    Expression<String>? moodChange,
    Expression<String>? nextAction,
    Expression<bool>? synthetic,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (startDate != null) 'start_date': startDate,
      if (barrier != null) 'barrier': barrier,
      if (taskText != null) 'task_text': taskText,
      if (taskType != null) 'task_type': taskType,
      if (examSubtype != null) 'exam_subtype': examSubtype,
      if (plannedSeconds != null) 'planned_seconds': plannedSeconds,
      if (actualSeconds != null) 'actual_seconds': actualSeconds,
      if (outcome != null) 'outcome': outcome,
      if (difficulty != null) 'difficulty': difficulty,
      if (focus != null) 'focus': focus,
      if (moodChange != null) 'mood_change': moodChange,
      if (nextAction != null) 'next_action': nextAction,
      if (synthetic != null) 'synthetic': synthetic,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyRecordsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<DateTime>? startDate,
    Value<String>? barrier,
    Value<String>? taskText,
    Value<String>? taskType,
    Value<String?>? examSubtype,
    Value<int>? plannedSeconds,
    Value<int>? actualSeconds,
    Value<String>? outcome,
    Value<int?>? difficulty,
    Value<int?>? focus,
    Value<String?>? moodChange,
    Value<String>? nextAction,
    Value<bool>? synthetic,
    Value<int>? rowid,
  }) {
    return StudyRecordsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      startDate: startDate ?? this.startDate,
      barrier: barrier ?? this.barrier,
      taskText: taskText ?? this.taskText,
      taskType: taskType ?? this.taskType,
      examSubtype: examSubtype ?? this.examSubtype,
      plannedSeconds: plannedSeconds ?? this.plannedSeconds,
      actualSeconds: actualSeconds ?? this.actualSeconds,
      outcome: outcome ?? this.outcome,
      difficulty: difficulty ?? this.difficulty,
      focus: focus ?? this.focus,
      moodChange: moodChange ?? this.moodChange,
      nextAction: nextAction ?? this.nextAction,
      synthetic: synthetic ?? this.synthetic,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (barrier.present) {
      map['barrier'] = Variable<String>(barrier.value);
    }
    if (taskText.present) {
      map['task_text'] = Variable<String>(taskText.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (examSubtype.present) {
      map['exam_subtype'] = Variable<String>(examSubtype.value);
    }
    if (plannedSeconds.present) {
      map['planned_seconds'] = Variable<int>(plannedSeconds.value);
    }
    if (actualSeconds.present) {
      map['actual_seconds'] = Variable<int>(actualSeconds.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (focus.present) {
      map['focus'] = Variable<int>(focus.value);
    }
    if (moodChange.present) {
      map['mood_change'] = Variable<String>(moodChange.value);
    }
    if (nextAction.present) {
      map['next_action'] = Variable<String>(nextAction.value);
    }
    if (synthetic.present) {
      map['synthetic'] = Variable<bool>(synthetic.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyRecordsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startDate: $startDate, ')
          ..write('barrier: $barrier, ')
          ..write('taskText: $taskText, ')
          ..write('taskType: $taskType, ')
          ..write('examSubtype: $examSubtype, ')
          ..write('plannedSeconds: $plannedSeconds, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('outcome: $outcome, ')
          ..write('difficulty: $difficulty, ')
          ..write('focus: $focus, ')
          ..write('moodChange: $moodChange, ')
          ..write('nextAction: $nextAction, ')
          ..write('synthetic: $synthetic, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActiveTimersTable extends ActiveTimers
    with TableInfo<$ActiveTimersTable, ActiveTimer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveTimersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _draftJsonMeta = const VerificationMeta(
    'draftJson',
  );
  @override
  late final GeneratedColumn<String> draftJson = GeneratedColumn<String>(
    'draft_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accumulatedSecondsMeta =
      const VerificationMeta('accumulatedSeconds');
  @override
  late final GeneratedColumn<int> accumulatedSeconds = GeneratedColumn<int>(
    'accumulated_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingSecondsMeta = const VerificationMeta(
    'remainingSeconds',
  );
  @override
  late final GeneratedColumn<int> remainingSeconds = GeneratedColumn<int>(
    'remaining_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSavedAtMeta = const VerificationMeta(
    'lastSavedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSavedAt = GeneratedColumn<DateTime>(
    'last_saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singleton,
    draftJson,
    accumulatedSeconds,
    remainingSeconds,
    startedAt,
    lastSavedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_timers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveTimer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    }
    if (data.containsKey('draft_json')) {
      context.handle(
        _draftJsonMeta,
        draftJson.isAcceptableOrUnknown(data['draft_json']!, _draftJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_draftJsonMeta);
    }
    if (data.containsKey('accumulated_seconds')) {
      context.handle(
        _accumulatedSecondsMeta,
        accumulatedSeconds.isAcceptableOrUnknown(
          data['accumulated_seconds']!,
          _accumulatedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accumulatedSecondsMeta);
    }
    if (data.containsKey('remaining_seconds')) {
      context.handle(
        _remainingSecondsMeta,
        remainingSeconds.isAcceptableOrUnknown(
          data['remaining_seconds']!,
          _remainingSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingSecondsMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_saved_at')) {
      context.handle(
        _lastSavedAtMeta,
        lastSavedAt.isAcceptableOrUnknown(
          data['last_saved_at']!,
          _lastSavedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSavedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singleton};
  @override
  ActiveTimer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveTimer(
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
      draftJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}draft_json'],
      )!,
      accumulatedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accumulated_seconds'],
      )!,
      remainingSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_seconds'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      lastSavedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_saved_at'],
      )!,
    );
  }

  @override
  $ActiveTimersTable createAlias(String alias) {
    return $ActiveTimersTable(attachedDatabase, alias);
  }
}

class ActiveTimer extends DataClass implements Insertable<ActiveTimer> {
  final int singleton;
  final String draftJson;
  final int accumulatedSeconds;
  final int remainingSeconds;
  final DateTime startedAt;
  final DateTime lastSavedAt;
  const ActiveTimer({
    required this.singleton,
    required this.draftJson,
    required this.accumulatedSeconds,
    required this.remainingSeconds,
    required this.startedAt,
    required this.lastSavedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton'] = Variable<int>(singleton);
    map['draft_json'] = Variable<String>(draftJson);
    map['accumulated_seconds'] = Variable<int>(accumulatedSeconds);
    map['remaining_seconds'] = Variable<int>(remainingSeconds);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['last_saved_at'] = Variable<DateTime>(lastSavedAt);
    return map;
  }

  ActiveTimersCompanion toCompanion(bool nullToAbsent) {
    return ActiveTimersCompanion(
      singleton: Value(singleton),
      draftJson: Value(draftJson),
      accumulatedSeconds: Value(accumulatedSeconds),
      remainingSeconds: Value(remainingSeconds),
      startedAt: Value(startedAt),
      lastSavedAt: Value(lastSavedAt),
    );
  }

  factory ActiveTimer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveTimer(
      singleton: serializer.fromJson<int>(json['singleton']),
      draftJson: serializer.fromJson<String>(json['draftJson']),
      accumulatedSeconds: serializer.fromJson<int>(json['accumulatedSeconds']),
      remainingSeconds: serializer.fromJson<int>(json['remainingSeconds']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      lastSavedAt: serializer.fromJson<DateTime>(json['lastSavedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singleton': serializer.toJson<int>(singleton),
      'draftJson': serializer.toJson<String>(draftJson),
      'accumulatedSeconds': serializer.toJson<int>(accumulatedSeconds),
      'remainingSeconds': serializer.toJson<int>(remainingSeconds),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'lastSavedAt': serializer.toJson<DateTime>(lastSavedAt),
    };
  }

  ActiveTimer copyWith({
    int? singleton,
    String? draftJson,
    int? accumulatedSeconds,
    int? remainingSeconds,
    DateTime? startedAt,
    DateTime? lastSavedAt,
  }) => ActiveTimer(
    singleton: singleton ?? this.singleton,
    draftJson: draftJson ?? this.draftJson,
    accumulatedSeconds: accumulatedSeconds ?? this.accumulatedSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    startedAt: startedAt ?? this.startedAt,
    lastSavedAt: lastSavedAt ?? this.lastSavedAt,
  );
  ActiveTimer copyWithCompanion(ActiveTimersCompanion data) {
    return ActiveTimer(
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      draftJson: data.draftJson.present ? data.draftJson.value : this.draftJson,
      accumulatedSeconds: data.accumulatedSeconds.present
          ? data.accumulatedSeconds.value
          : this.accumulatedSeconds,
      remainingSeconds: data.remainingSeconds.present
          ? data.remainingSeconds.value
          : this.remainingSeconds,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastSavedAt: data.lastSavedAt.present
          ? data.lastSavedAt.value
          : this.lastSavedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimer(')
          ..write('singleton: $singleton, ')
          ..write('draftJson: $draftJson, ')
          ..write('accumulatedSeconds: $accumulatedSeconds, ')
          ..write('remainingSeconds: $remainingSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastSavedAt: $lastSavedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singleton,
    draftJson,
    accumulatedSeconds,
    remainingSeconds,
    startedAt,
    lastSavedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveTimer &&
          other.singleton == this.singleton &&
          other.draftJson == this.draftJson &&
          other.accumulatedSeconds == this.accumulatedSeconds &&
          other.remainingSeconds == this.remainingSeconds &&
          other.startedAt == this.startedAt &&
          other.lastSavedAt == this.lastSavedAt);
}

class ActiveTimersCompanion extends UpdateCompanion<ActiveTimer> {
  final Value<int> singleton;
  final Value<String> draftJson;
  final Value<int> accumulatedSeconds;
  final Value<int> remainingSeconds;
  final Value<DateTime> startedAt;
  final Value<DateTime> lastSavedAt;
  const ActiveTimersCompanion({
    this.singleton = const Value.absent(),
    this.draftJson = const Value.absent(),
    this.accumulatedSeconds = const Value.absent(),
    this.remainingSeconds = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastSavedAt = const Value.absent(),
  });
  ActiveTimersCompanion.insert({
    this.singleton = const Value.absent(),
    required String draftJson,
    required int accumulatedSeconds,
    required int remainingSeconds,
    required DateTime startedAt,
    required DateTime lastSavedAt,
  }) : draftJson = Value(draftJson),
       accumulatedSeconds = Value(accumulatedSeconds),
       remainingSeconds = Value(remainingSeconds),
       startedAt = Value(startedAt),
       lastSavedAt = Value(lastSavedAt);
  static Insertable<ActiveTimer> custom({
    Expression<int>? singleton,
    Expression<String>? draftJson,
    Expression<int>? accumulatedSeconds,
    Expression<int>? remainingSeconds,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? lastSavedAt,
  }) {
    return RawValuesInsertable({
      if (singleton != null) 'singleton': singleton,
      if (draftJson != null) 'draft_json': draftJson,
      if (accumulatedSeconds != null) 'accumulated_seconds': accumulatedSeconds,
      if (remainingSeconds != null) 'remaining_seconds': remainingSeconds,
      if (startedAt != null) 'started_at': startedAt,
      if (lastSavedAt != null) 'last_saved_at': lastSavedAt,
    });
  }

  ActiveTimersCompanion copyWith({
    Value<int>? singleton,
    Value<String>? draftJson,
    Value<int>? accumulatedSeconds,
    Value<int>? remainingSeconds,
    Value<DateTime>? startedAt,
    Value<DateTime>? lastSavedAt,
  }) {
    return ActiveTimersCompanion(
      singleton: singleton ?? this.singleton,
      draftJson: draftJson ?? this.draftJson,
      accumulatedSeconds: accumulatedSeconds ?? this.accumulatedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      startedAt: startedAt ?? this.startedAt,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (draftJson.present) {
      map['draft_json'] = Variable<String>(draftJson.value);
    }
    if (accumulatedSeconds.present) {
      map['accumulated_seconds'] = Variable<int>(accumulatedSeconds.value);
    }
    if (remainingSeconds.present) {
      map['remaining_seconds'] = Variable<int>(remainingSeconds.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastSavedAt.present) {
      map['last_saved_at'] = Variable<DateTime>(lastSavedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimersCompanion(')
          ..write('singleton: $singleton, ')
          ..write('draftJson: $draftJson, ')
          ..write('accumulatedSeconds: $accumulatedSeconds, ')
          ..write('remainingSeconds: $remainingSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastSavedAt: $lastSavedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StudyRecordsTable studyRecords = $StudyRecordsTable(this);
  late final $ActiveTimersTable activeTimers = $ActiveTimersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    studyRecords,
    activeTimers,
  ];
}

typedef $$StudyRecordsTableCreateCompanionBuilder =
    StudyRecordsCompanion Function({
      required String id,
      required DateTime startedAt,
      required DateTime endedAt,
      required DateTime startDate,
      required String barrier,
      required String taskText,
      required String taskType,
      Value<String?> examSubtype,
      required int plannedSeconds,
      required int actualSeconds,
      required String outcome,
      Value<int?> difficulty,
      Value<int?> focus,
      Value<String?> moodChange,
      Value<String> nextAction,
      Value<bool> synthetic,
      Value<int> rowid,
    });
typedef $$StudyRecordsTableUpdateCompanionBuilder =
    StudyRecordsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<DateTime> startDate,
      Value<String> barrier,
      Value<String> taskText,
      Value<String> taskType,
      Value<String?> examSubtype,
      Value<int> plannedSeconds,
      Value<int> actualSeconds,
      Value<String> outcome,
      Value<int?> difficulty,
      Value<int?> focus,
      Value<String?> moodChange,
      Value<String> nextAction,
      Value<bool> synthetic,
      Value<int> rowid,
    });

class $$StudyRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyRecordsTable> {
  $$StudyRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barrier => $composableBuilder(
    column: $table.barrier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskText => $composableBuilder(
    column: $table.taskText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examSubtype => $composableBuilder(
    column: $table.examSubtype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedSeconds => $composableBuilder(
    column: $table.plannedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moodChange => $composableBuilder(
    column: $table.moodChange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synthetic => $composableBuilder(
    column: $table.synthetic,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyRecordsTable> {
  $$StudyRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barrier => $composableBuilder(
    column: $table.barrier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskText => $composableBuilder(
    column: $table.taskText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskType => $composableBuilder(
    column: $table.taskType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examSubtype => $composableBuilder(
    column: $table.examSubtype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedSeconds => $composableBuilder(
    column: $table.plannedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moodChange => $composableBuilder(
    column: $table.moodChange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synthetic => $composableBuilder(
    column: $table.synthetic,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyRecordsTable> {
  $$StudyRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get barrier =>
      $composableBuilder(column: $table.barrier, builder: (column) => column);

  GeneratedColumn<String> get taskText =>
      $composableBuilder(column: $table.taskText, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<String> get examSubtype => $composableBuilder(
    column: $table.examSubtype,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedSeconds => $composableBuilder(
    column: $table.plannedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);

  GeneratedColumn<String> get moodChange => $composableBuilder(
    column: $table.moodChange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextAction => $composableBuilder(
    column: $table.nextAction,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synthetic =>
      $composableBuilder(column: $table.synthetic, builder: (column) => column);
}

class $$StudyRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyRecordsTable,
          StudyRecordRow,
          $$StudyRecordsTableFilterComposer,
          $$StudyRecordsTableOrderingComposer,
          $$StudyRecordsTableAnnotationComposer,
          $$StudyRecordsTableCreateCompanionBuilder,
          $$StudyRecordsTableUpdateCompanionBuilder,
          (
            StudyRecordRow,
            BaseReferences<_$AppDatabase, $StudyRecordsTable, StudyRecordRow>,
          ),
          StudyRecordRow,
          PrefetchHooks Function()
        > {
  $$StudyRecordsTableTableManager(_$AppDatabase db, $StudyRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String> barrier = const Value.absent(),
                Value<String> taskText = const Value.absent(),
                Value<String> taskType = const Value.absent(),
                Value<String?> examSubtype = const Value.absent(),
                Value<int> plannedSeconds = const Value.absent(),
                Value<int> actualSeconds = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<int?> difficulty = const Value.absent(),
                Value<int?> focus = const Value.absent(),
                Value<String?> moodChange = const Value.absent(),
                Value<String> nextAction = const Value.absent(),
                Value<bool> synthetic = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyRecordsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                startDate: startDate,
                barrier: barrier,
                taskText: taskText,
                taskType: taskType,
                examSubtype: examSubtype,
                plannedSeconds: plannedSeconds,
                actualSeconds: actualSeconds,
                outcome: outcome,
                difficulty: difficulty,
                focus: focus,
                moodChange: moodChange,
                nextAction: nextAction,
                synthetic: synthetic,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                required DateTime endedAt,
                required DateTime startDate,
                required String barrier,
                required String taskText,
                required String taskType,
                Value<String?> examSubtype = const Value.absent(),
                required int plannedSeconds,
                required int actualSeconds,
                required String outcome,
                Value<int?> difficulty = const Value.absent(),
                Value<int?> focus = const Value.absent(),
                Value<String?> moodChange = const Value.absent(),
                Value<String> nextAction = const Value.absent(),
                Value<bool> synthetic = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyRecordsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                startDate: startDate,
                barrier: barrier,
                taskText: taskText,
                taskType: taskType,
                examSubtype: examSubtype,
                plannedSeconds: plannedSeconds,
                actualSeconds: actualSeconds,
                outcome: outcome,
                difficulty: difficulty,
                focus: focus,
                moodChange: moodChange,
                nextAction: nextAction,
                synthetic: synthetic,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyRecordsTable,
      StudyRecordRow,
      $$StudyRecordsTableFilterComposer,
      $$StudyRecordsTableOrderingComposer,
      $$StudyRecordsTableAnnotationComposer,
      $$StudyRecordsTableCreateCompanionBuilder,
      $$StudyRecordsTableUpdateCompanionBuilder,
      (
        StudyRecordRow,
        BaseReferences<_$AppDatabase, $StudyRecordsTable, StudyRecordRow>,
      ),
      StudyRecordRow,
      PrefetchHooks Function()
    >;
typedef $$ActiveTimersTableCreateCompanionBuilder =
    ActiveTimersCompanion Function({
      Value<int> singleton,
      required String draftJson,
      required int accumulatedSeconds,
      required int remainingSeconds,
      required DateTime startedAt,
      required DateTime lastSavedAt,
    });
typedef $$ActiveTimersTableUpdateCompanionBuilder =
    ActiveTimersCompanion Function({
      Value<int> singleton,
      Value<String> draftJson,
      Value<int> accumulatedSeconds,
      Value<int> remainingSeconds,
      Value<DateTime> startedAt,
      Value<DateTime> lastSavedAt,
    });

class $$ActiveTimersTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get draftJson => $composableBuilder(
    column: $table.draftJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accumulatedSeconds => $composableBuilder(
    column: $table.accumulatedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActiveTimersTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get draftJson => $composableBuilder(
    column: $table.draftJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accumulatedSeconds => $composableBuilder(
    column: $table.accumulatedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActiveTimersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveTimersTable> {
  $$ActiveTimersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  GeneratedColumn<String> get draftJson =>
      $composableBuilder(column: $table.draftJson, builder: (column) => column);

  GeneratedColumn<int> get accumulatedSeconds => $composableBuilder(
    column: $table.accumulatedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSavedAt => $composableBuilder(
    column: $table.lastSavedAt,
    builder: (column) => column,
  );
}

class $$ActiveTimersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveTimersTable,
          ActiveTimer,
          $$ActiveTimersTableFilterComposer,
          $$ActiveTimersTableOrderingComposer,
          $$ActiveTimersTableAnnotationComposer,
          $$ActiveTimersTableCreateCompanionBuilder,
          $$ActiveTimersTableUpdateCompanionBuilder,
          (
            ActiveTimer,
            BaseReferences<_$AppDatabase, $ActiveTimersTable, ActiveTimer>,
          ),
          ActiveTimer,
          PrefetchHooks Function()
        > {
  $$ActiveTimersTableTableManager(_$AppDatabase db, $ActiveTimersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveTimersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveTimersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveTimersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singleton = const Value.absent(),
                Value<String> draftJson = const Value.absent(),
                Value<int> accumulatedSeconds = const Value.absent(),
                Value<int> remainingSeconds = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> lastSavedAt = const Value.absent(),
              }) => ActiveTimersCompanion(
                singleton: singleton,
                draftJson: draftJson,
                accumulatedSeconds: accumulatedSeconds,
                remainingSeconds: remainingSeconds,
                startedAt: startedAt,
                lastSavedAt: lastSavedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> singleton = const Value.absent(),
                required String draftJson,
                required int accumulatedSeconds,
                required int remainingSeconds,
                required DateTime startedAt,
                required DateTime lastSavedAt,
              }) => ActiveTimersCompanion.insert(
                singleton: singleton,
                draftJson: draftJson,
                accumulatedSeconds: accumulatedSeconds,
                remainingSeconds: remainingSeconds,
                startedAt: startedAt,
                lastSavedAt: lastSavedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActiveTimersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveTimersTable,
      ActiveTimer,
      $$ActiveTimersTableFilterComposer,
      $$ActiveTimersTableOrderingComposer,
      $$ActiveTimersTableAnnotationComposer,
      $$ActiveTimersTableCreateCompanionBuilder,
      $$ActiveTimersTableUpdateCompanionBuilder,
      (
        ActiveTimer,
        BaseReferences<_$AppDatabase, $ActiveTimersTable, ActiveTimer>,
      ),
      ActiveTimer,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StudyRecordsTableTableManager get studyRecords =>
      $$StudyRecordsTableTableManager(_db, _db.studyRecords);
  $$ActiveTimersTableTableManager get activeTimers =>
      $$ActiveTimersTableTableManager(_db, _db.activeTimers);
}
